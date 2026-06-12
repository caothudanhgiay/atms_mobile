import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:loadweb/config/constants.dart';
import 'package:loadweb/config/images.dart';
import 'package:loadweb/view/module/custom_webview.dart';

import '../../l10n/app_localizations.dart';

/// Page no internet
class NoInternetView extends StatefulWidget {
  const NoInternetView({super.key});

  @override
  NoInternetViewState createState() => NoInternetViewState();
}

class NoInternetViewState extends State<NoInternetView> {
  bool isConnected = false;
  late Connectivity connectivity;

  @override
  void initState() {
    super.initState();
    connectivity = Connectivity();
    checkConnection();
  }

  /// Event listen turn on or off internet on device
  ///
  /// Return type [void]
  void checkConnection() async {
    var connectivityResult = await connectivity.checkConnectivity();
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });

    // listen turn on or off internet
    connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        isConnected = result != ConnectivityResult.none;
      });

      // open WebView
      if (isConnected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const CustomWebView(Constants.URL_ATMS)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Images.ATMS_ICON_DISCONNECT, // image disconnect
              width: 70,
              height: 70,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                AppLocalizations.of(context)!.no_internet,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.5,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
