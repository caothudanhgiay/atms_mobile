import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loadweb/Util/common_util.dart';
import 'package:loadweb/config/constants.dart';
import 'package:loadweb/config/locator.dart';
import 'package:loadweb/model/device_info.dart';
import 'package:loadweb/model/network_info_plus.dart';
import 'package:loadweb/service/APIService.dart';
import 'package:loadweb/view/module/scan_page.dart';
import 'package:loadweb/view/module/voice_dialog.dart';
import 'package:loadweb/view/module/voice_text_page.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../l10n/app_localizations.dart';

/// Webview load file in directory
class CustomWebView extends StatefulWidget {
  const CustomWebView(this.filePath, {super.key});

  final String filePath;

  @override
  State<CustomWebView> createState() => CustomWebViewState();
}

/// Webview state
class CustomWebViewState extends State<CustomWebView> with WidgetsBindingObserver {
  late WebViewController _controller;
  late Timer timer;
  var isInit = true;
  bool hasCalled = false;
  final ImagePicker _picker = ImagePicker();
  bool isControllerReady = false;
  bool sentKeyboardHeight = false;

  /// FocusNode cho WebView widget — dùng để focus WebView ở Flutter/native level
  /// trước khi JS gọi element.focus(), giúp Android cho phép hiện keyboard.
  final FocusNode _webViewFocusNode = FocusNode();


  /// Start.
  ///
  /// Return type [void]
  @override
  void initState() {
    super.initState();
    initWebView();
    timerUpdateNetworkInfo();
    WidgetsBinding.instance.addObserver(this); // tracking app
  }

  @override
  void dispose() {
    timer.cancel();
    _webViewFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this); // cancel tracking app
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isControllerReady) {
      print("app resume");
      callFcReloadPage(); // Gọi reload khi ứng dụng mở lại
    }
  }

  /// init and setup for Android, IOS.
  ///
  /// Return type [void]
  initWebView() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadRequest(Uri.parse(widget.filePath));
    controller.setNavigationDelegate(NavigationDelegate(onPageFinished: (url) {
      callFcSetDeviceInfo();
      callFcGetDefaultLan();
    }));

    // webview get chanel from js
    // js call fn flutter
    // flutter call fn js
    handleCallJs(controller);

    // setting android
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);

      final androidController = controller.platform as AndroidWebViewController;
      await configureAndroidWebView(androidController, context);
    }

    setState(() {
      _controller = controller;
      isControllerReady = true;
    });
  }

  /// Timer get network information.
  ///
  /// Return type [void]
  void timerUpdateNetworkInfo() {
    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        await locator<NetworkInfoPlus>().getNetworkInfo();
      } catch (e, stack) {
        APIService.writeLogError('timerUpdateNetworkInfo crash: $e\n$stack');
      }
    });
  }

  /// Configure for Android.
  ///
  /// Params: AndroidWebViewController [androidController], BuildContext [context]
  ///
  /// Return type [Future<void>]
  Future<void> configureAndroidWebView(AndroidWebViewController androidController, BuildContext context) async {
    // access file
    androidController.setOnShowFileSelector((params) async {
      return await showFileSourceSelection(context);
    });

    // access camera
    androidController.setMediaPlaybackRequiresUserGesture(false);

    // allow access location in webview
    androidController.setGeolocationPermissionsPromptCallbacks(
      onShowPrompt: (request) async {
        // request location permission
        final locationPermissionStatus = await Permission.locationWhenInUse.request();

        // return the response
        return GeolocationPermissionsResponse(
          allow: locationPermissionStatus == PermissionStatus.granted,
          retain: false,
        );
      },
    );
  }

  /// Call function js in webview.
  ///
  /// Params: String [functionName]
  ///
  /// Return type [void]
  callFunctionJS(String functionName) async {
    await _controller.runJavaScript(functionName);
  }

  /// Call function js and return data in webview.
  ///
  /// Params: String [functionName]
  ///
  /// Return type [void]
  callFunctionJSReturnData(String functionName) async {
    final result = await _controller.runJavaScriptReturningResult(functionName);
    return result;
  }

  /// Send device information into webview.
  ///
  /// Return type [void]
  callFcGetDefaultLan() async {
    var lan = await callFunctionJSReturnData("${Constants.JS_GET_DEFAULT_LAN}()");
    var lanVoice = await callFunctionJSReturnData("${Constants.JS_GET_DEFAULT_LAN_VOICE}()");
    lan = lan!.replaceAll('\"', '');
    lanVoice = lanVoice!.replaceAll('\"', '');
    CommonUtil.appUpdateLocale(lan);
    await CommonUtil.saveSharedPreferences(Constants.SHARED_LANG, lan);
    await CommonUtil.saveSharedPreferences(Constants.SHARED_LANG_VOICE, lanVoice);
  }

  /// Send device information into webview.
  ///
  /// Return type [void]
  callFcSetDeviceInfo() {
    String? param = locator<DeviceInfo>().getDeviceInfo();
    if (param == null) {
      return;
    }
    String functionName = "${Constants.JS_SET_DEVICE_INFO}('$param')";
    callFunctionJS(functionName);
  }

  /// Open scan bar code.
  ///
  /// Params: BuildContext [context]
  ///
  /// Return type [Future<void>]
  Future<void> startBarcodeScan(BuildContext context) async {
    final barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanPage()),
    );

    if (barcode != null && barcode.toString().isNotEmpty) {
      _controller.runJavaScript('${Constants.JS_BAR_CODE_HANDLE}("$barcode")');
    } else {
      _controller.runJavaScript('${Constants.JS_BAR_CODE_CANCEL}()');
    }
  }

  /// Request permission when open camera.
  ///
  /// Params: BuildContext [context]
  ///
  /// Return type [void]
  void _showCameraPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.camera_request_title),
        content: Text(AppLocalizations.of(context)!.camera_request_content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.btn_cancel),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // Mở cài đặt hệ thống
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.btn_open_setting),
          ),
        ],
      ),
    );
  }

  /// The function javascript call into the flutter.
  ///
  /// Params: WebViewController [controller]
  ///
  /// Return type [void]
  void handleCallJs(WebViewController controller) {
    handleJsScanBarcode(controller);
    handleJsAppInfo(controller);
    handleJsSendData(controller);
    handleJsOpenFile(controller);
  }

  /// When click the button "Check in" in webview
  /// received js "openBarCode"
  /// open camera and scan barcode.
  /// If success => call js "handleBarcodeScanResult".
  /// If cancel => call js "cancelBarcodeScan".
  ///
  /// Params: WebViewController [controller]
  ///
  /// Return type [void]
  void handleJsScanBarcode(WebViewController controller) {
    // setting bar code scan
    controller.addJavaScriptChannel(
      Constants.JS_BAR_CODE_CHANNEL,
      onMessageReceived: (message) async {
        // call function javascript
        if (message.message == Constants.JS_BAR_CODE_OPEN_SCAN) {
          await startBarcodeScan(context);
        }
      },
    );
  }

  /// When click the button "Check in" in webview
  /// received js "getNetworkInfo"
  /// send network information to js "handleNetworkInfo".
  ///
  /// Params: WebViewController [controller]
  ///
  /// Return type [void]
  void handleJsAppInfo(WebViewController controller) {
    controller.addJavaScriptChannel(
      Constants.JS_APP_INFO_CHANNEL,
      onMessageReceived: (message) async {
        switch (message.message) {
          case Constants.JS_APP_INFO_GET:
            await sendAppInfo();
            break;

          case Constants.JS_APP_INFO_UPDATE_LAN:
            await callFcGetDefaultLan();
            break;

          case Constants.JS_APP_INFO_OPEN_VOICE_SEARCH:
            await openVoiceSearch();
            break;

          case Constants.JS_APP_INFO_KEYBOARD:
            await getKeyboardHeight();
            break;
        }
      },
    );
  }

  /// Js send data into flutter.
  ///
  /// Params: WebViewController [controller]
  ///
  /// Return type [void]
  void handleJsSendData(WebViewController controller) {
    controller.addJavaScriptChannel(
      Constants.JS_SEND_DATA_APP_INFO_CHANNEL,
      onMessageReceived: (message) async {
        final data = jsonDecode(message.message);
        final action = data['action'];

        switch (action) {
          case Constants.JS_APP_INFO_OPEN_VOICE_TEXT_PAGE:
            await openVoiceTextPage(data);
            break;

          case Constants.JS_APP_INFO_GET_TYPE_KEYBOARD:
            await checkAndShowKeyboard(data);
            break;
        }

      },
    );
  }

  /// View file on app.
  ///
  /// Params: WebViewController [controller]
  ///
  /// Return type [void]
  void handleJsOpenFile(WebViewController controller) {
    controller.addJavaScriptChannel(
      Constants.JS_FILE_CHANNEL,
      onMessageReceived: (message) async {
        // call function javascript
        final msg = jsonDecode(message.message);
        final action = msg['action'];
        final data = msg['data'];

        if (message.message == Constants.JS_FILE_OPEN && !hasCalled) {
          await callFcGetOpenFile();
        } else if (action == Constants.JS_OPEN_WEB && !hasCalled) {
          await openInBrowser(data);
        } else if (action == Constants.JS_OPEN_FILE && !hasCalled) {
          await openAndViewFile(data);
        } else if (action == Constants.JS_OPEN_PHONE && !hasCalled) {
          await openPhone(data);
        }
      },
    );
  }

  /// Send device information into webview.
  ///
  /// Return type [void]
  callFcGetOpenFile() async {
    var filePath = await callFunctionJSReturnData("${Constants.JS_FILE_GET_URL}()");

    if (filePath == null || filePath.isEmpty) return;

    filePath = filePath.replaceAll('\"', '');

    final uri = Uri.tryParse(filePath);
    if (uri == null) {
      APIService.writeLogInfo("callFcGetOpenFile", "Không thể phân tích URI: $filePath");
      return;
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'http' || scheme == 'https') {
      final lowerPath = uri.path.toLowerCase();
      if (CommonUtil.checkIsImageFile(lowerPath)) {
        print("openAndViewFile: $lowerPath");
        await openAndViewFile(filePath);
      } else {
        print("openInBrowser: $lowerPath");
        await openInBrowser(filePath);
      }
    } else {
      APIService.writeLogInfo("callFcGetOpenFile", "Định dạng URI không hỗ trợ: $filePath");
    }
  }

  /// Reload page when app resume.
  ///
  /// Return type [void]
  callFcReloadPage() async {
    print("reload page");
    _controller.runJavaScript('${Constants.JS_APP_INFO_RELOAD}()');
  }

  /// Open and view file.
  ///
  /// Params: String [uri]
  ///
  /// Return type [void]
  openAndViewFile(uri) async {
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = Uri.parse(uri).pathSegments.last;
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Mở file
      await OpenFile.open(filePath);
    } else {
      print('Không thể tải file: ${response.statusCode}');
    }
  }

  /// Open phone
  ///
  /// Params: String [phoneNumber]
  ///
  /// Return type [void]
  openPhone(phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      APIService.writeLogInfo("callFcGetOpenFile", "Không thể gọi số $phoneNumber");
    }
  }

  /// Open browser
  ///
  /// Params: String [url]
  ///
  /// Return type [Future<void>]
  Future<void> openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Không thể mở $url';
    }
  }

  /// Open page voice search and return data for js handleVoiceSearchResult in the webview.
  ///
  /// Return type [Future<void>]
  Future<void> openVoiceSearch() async {
    var result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => const VoiceDialog(),
      ),
    );

    // return NA if null or ""
    if (result == null || result == "") {
      result = CommonUtil.returnNoThing();
    }
    final safeResult = jsonEncode(result);

    _controller.runJavaScript('${Constants.JS_APP_INFO_HANDLE_VOICE_SEARCH}($safeResult)');
  }

  /// Open page voice text and return data for js handleVoiceResultTextPage in the webview.
  ///
  /// Return type [Future<void>]
  Future<void> openVoiceTextPage(data) async {
    String textFromJs = data['text'];
    textFromJs = textFromJs.replaceAll('NEW_LINE', '\n');

    var result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => VoiceTextPage(textFromJs),
      ),
    );

    // return NA if null or ""
    if (result == null || result == "") {
      result = CommonUtil.returnNoThing();
    }
    final safeResult = jsonEncode(result);

    _controller.runJavaScript('${Constants.JS_APP_INFO_HANDLE_VOICE_TEXT_PAGE}($safeResult)');
  }

  /// Map keyboard type to HTML inputmode attribute.
  ///
  /// Params: String [type]
  ///
  /// Return type [String]
  String _mapInputMode(String type) {
    switch (type) {
      case 'number': return 'numeric';
      case 'email':  return 'email';
      case 'text':
      default:       return 'text';
    }
  }

  /// Open keyboard and check keyboard type.
  ///
  /// Tất cả xử lý từ Flutter (không sửa file JS):
  /// 1. Flutter set inputmode trên HTML element (qua runJavaScript)
  /// 2. Flutter gọi handleTypeKeyBoard gốc (JS chỉ focus)
  /// 3. WKWebViewKeyboardHelper (iOS native) cho phép keyboard hiện
  ///
  /// Return type [Future<void>]
  Future<void> checkAndShowKeyboard(data) async {
    String type = data['type'];
    String idTxtText = data['idTxtText'];
    String inputMode = _mapInputMode(type);

    // JavaScript to set inputmode and return status/errors
    String jsCode = """
      (function() {
        try {
          var element = findControlById('$idTxtText');
          if (!element) return "Error: Element '$idTxtText' not found in masterFrame";
          
          element.setAttribute("inputmode", "$inputMode");
          return "Success: set inputmode to " + "$inputMode" + " for " + "$idTxtText";
        } catch (e) {
          return "JS Error: " + e.message;
        }
      })()
    """;

    final result = await _controller.runJavaScriptReturningResult(jsCode);

    // Focus WebView widget ở Flutter/native level TRƯỚC
    _webViewFocusNode.requestFocus();
    await Future.delayed(const Duration(milliseconds: 100));

    // Gọi handleTypeKeyBoard gốc
    _controller.runJavaScript(
      '${Constants.JS_APP_INFO_HANDLE_TYPE_KEYBOARD}("$idTxtText")',
    );
  }

  /// Get network information and call js "handleNetworkInfo" to webview.
  ///
  /// Return type [Future<void>]
  Future<void> getKeyboardHeight() async {
    final current = WidgetsBinding.instance.window.viewInsets.bottom;

    // keyboard chưa mở
    if (current == 0) return;

    // chờ animation kết thúc
    await Future.delayed(const Duration(milliseconds: 150));

    final window = WidgetsBinding.instance.window;

    final keyboardCssPx = window.viewInsets.bottom / window.devicePixelRatio;

    if (keyboardCssPx > 0) {
      _controller.runJavaScript(
        '${Constants.JS_APP_INFO_HANDLE_KEYBOARD}(${keyboardCssPx.toInt()})',
      );
    }
  }

  /// Get network information and call js "handleNetworkInfo" to webview.
  ///
  /// Return type [Future<void>]
  Future<void> sendAppInfo() async {
    String? wifi = await locator<NetworkInfoPlus>().customNetworkInfo();
    String location = await CommonUtil.getCurrentLocation();
    String data = location + Constants.PIPE + wifi!;

    _controller.runJavaScript('${Constants.JS_APP_INFO_HANDLE}("$data")');
  }

  /// Show the selection between photo library and take a photo.
  ///
  /// Params: BuildContext [context]
  ///
  /// Return [Future<List<String>>]
  Future<List<String>> showFileSourceSelection(BuildContext context) async {
    return await showModalBottomSheet<List<String>>(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from library'),
                    onTap: () async {
                      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        Navigator.pop(context, [File(pickedFile.path).uri.toString()]);
                      } else {
                        Navigator.pop(context, []); // If no image is selected
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take a photo'),
                    onTap: () async {
                      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        Navigator.pop(context, [File(pickedFile.path).uri.toString()]);
                      } else {
                        Navigator.pop(context, []); // If the user does not take a photo
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('Upload file'),
                    onTap: () async {
                      // Pick a file (any type)
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.any, // Allow any type of file
                      );
                      if (result != null && result.files.single.path != null) {
                        Navigator.pop(context, [File(result.files.single.path!).uri.toString()]);
                      } else {
                        Navigator.pop(context, []); // If no file is selected
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ) ??
        []; // Return an empty list if no file is selected
  }

  @override
  Widget build(BuildContext context) {
    if (!isControllerReady) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 0.0),
          child: AppBar(),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          // Go back to the previous page in the WebView
          _controller.goBack();
          return false; // Prevent exiting the app
        } else {
          return true; // Allow exiting the app
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 0.0),
          child: AppBar(),
        ),
        body: Stack(
          children: [
            Focus(
              focusNode: _webViewFocusNode,
              child: WebViewWidget(
                controller: _controller,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
