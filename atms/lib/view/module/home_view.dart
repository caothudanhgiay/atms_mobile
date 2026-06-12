import 'package:flutter/material.dart';
import 'package:loadweb/Util/common_util.dart';
import 'package:loadweb/config/constants.dart';
import 'package:loadweb/view/module/custom_webview.dart';
import 'package:loadweb/view/module/no_internet_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeView createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  bool _isNavigated = false; // Flag to prevent multiple navigations

  @override
  void initState() {
    super.initState();
    _checkNetwork();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _checkNetwork(); // Check network connection when dependencies change
  // }

  // Asynchronous method to check the network connection
  Future<void> _checkNetwork() async {
    if (_isNavigated) return; // Exit early if navigation has already occurred

    var status = await CommonUtil.checkInternetConnection(); // Check internet connection status

    setState(() {
      _isNavigated = true; // Set the flag to true after navigation
    });

    if (status) {
      // Navigate to the WebView if the device is connected to the internet
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CustomWebView(Constants.URL_ATMS)),
      );
    } else {
      // Navigate to the NoInternetView if there is no internet connection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NoInternetView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator while checking the network status
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
