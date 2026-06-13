import 'dart:async';

import 'package:network_info_plus/network_info_plus.dart';

/// Get network information.
class NetworkInfoPlus {
  final NetworkInfo networkInfo = NetworkInfo();
  String? wifiName, wifiBSSID, wifiIPv4, wifiIPv6, wifiGatewayIP, wifiBroadcast, wifiSubmask;

  /// Init
  ///
  /// Return type[Future<void>]
  Future<void> getNetworkInfo() async {
    wifiName = await networkInfo.getWifiName();
    // wifiBSSID = await networkInfo.getWifiBSSID();
    // wifiIPv4 = await networkInfo.getWifiIP();
    // wifiIPv6 = await networkInfo.getWifiIPv6();
    // wifiSubmask = await networkInfo.getWifiSubmask();
    // wifiBroadcast = await networkInfo.getWifiBroadcast();
    // wifiGatewayIP = await networkInfo.getWifiGatewayIP();
  }

  /// Get network information
  ///
  /// Return type [String]
  Future<String> customNetworkInfo() async {
    if (wifiName == null) {
      await getNetworkInfo();
    }

    return wifiName?.replaceAll('"', '') ?? '';
  }

  /// Get network information
  ///
  /// Return type [String]
  Future<String?> getWifiName() async {
    if (wifiName == null) {
      await getNetworkInfo();
    }

    return wifiName?.replaceAll('"', '');
  }
}
