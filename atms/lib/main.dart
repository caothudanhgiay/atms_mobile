import 'dart:async';
import 'dart:io';

import 'package:loadweb/service/APIService.dart';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loadweb/model/device_info.dart';
import 'package:loadweb/model/network_info_plus.dart';
import 'package:loadweb/view/module/home_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'config/locator.dart';
import 'l10n/app_localizations.dart';
import 'model/locale_provider.dart';

/// Main function
main() async {
  // Bắt lỗi toàn cục của Dart
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    setupLocator();

    try {
      await requestPermissionAppTracking();
    } catch (e, stack) {
      APIService.writeLogError("requestPermissionAppTracking crash: $e\n$stack");
    }

    try {
      await requestPermission();
    } catch (e, stack) {
      APIService.writeLogError("requestPermission crash: $e\n$stack");
    }

    // Allow (Portrait)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Bắt lỗi toàn cục của Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      APIService.writeLogError("FlutterError: ${details.exception}\n${details.stack}");
    };

    runApp(
      ChangeNotifierProvider(
        create: (_) => locator<LocaleProvider>(), // auto change locale
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    APIService.writeLogError("runZonedGuarded Uncaught Error: $error\n$stack");
  });
}

/// Access permission
requestPermission() async {
  try {
    if (Platform.isIOS) {
      await [
        Permission.camera,
        Permission.photos,
        Permission.location,
        Permission.locationWhenInUse,
        Permission.microphone,
        Permission.speech,
      ].request();
    } else {
      await [
        Permission.storage,
        Permission.camera,
        Permission.photos,
        Permission.location,
        Permission.locationAlways,
        Permission.locationWhenInUse,
        Permission.accessMediaLocation,
        Permission.microphone,
      ].request();
    }
  } catch (e, stack) {
    APIService.writeLogError('requestPermission request crash: $e\n$stack');
  }
}

/// Request permission app tracking.
///
/// Return type [void]
Future<void> requestPermissionAppTracking() async {
  if (Platform.isIOS) {
    final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
    debugPrint("Current tracking status: $status");
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 2000));
      final TrackingStatus newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint("requestTrackingAuthorization status: $newStatus");
    } else if (status == TrackingStatus.denied || status == TrackingStatus.restricted) {
      debugPrint("Tracking permission already denied or restricted.");
    } else {
      debugPrint("Tracking permission already granted.");
    }
  }
}

/// Main app
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  /// Start my app
  ///
  /// Return type [void]
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

/// Page main app
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? timer;

  /// Start init.
  ///
  /// Return type [void]
  @override
  initState() {
    super.initState();
    // Dùng Future để xử lý async trong initState an toàn
    // Không await trực tiếp vì initState không phải async
    // Nếu thiếu try-catch, exception trong Release mode sẽ crash app
    Future(() async {
      try {
        await locator<DeviceInfo>().initPlatformState();
      } catch (e, stack) {
        APIService.writeLogError('initPlatformState crash: $e\n$stack');
        debugPrint('initPlatformState error: $e');
      }
      try {
        await locator<NetworkInfoPlus>().getNetworkInfo();
      } catch (e, stack) {
        APIService.writeLogError('getNetworkInfo crash: $e\n$stack');
        debugPrint('getNetworkInfo error: $e');
      }
    });
  }

  /// Create page
  ///
  /// Params: [context]
  ///
  /// Return type [void]
  @override
  Widget build(BuildContext context) {

    // auto change locale when webview change locale
    // webview click icon flag => flutter call callFcGetDefaultLan change language
    // update lang
    final localeProvider = Provider.of<LocaleProvider>(context);
    return GestureDetector(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.app_name,
        // multiple language
        locale: Locale(localeProvider.lang), // auto change locale
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // theme
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.black),
            color: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              // Status bar color
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
        ),
        home: Semantics(
          child: HomeView(),
        ),
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }
}
