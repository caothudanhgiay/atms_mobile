import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:loadweb/config/constants.dart';

/// Get current device information.
class DeviceInfo {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  /// Init.
  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      _deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      _deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  /// Get device information.
  ///
  /// Return type [String]
  String getDeviceInfo() {
    String info = "";
    String separator = Constants.PIPE;

    if (Platform.isAndroid) {
      info = _deviceData['id'] +
          separator +
          _deviceData['model'] +
          separator +
          _deviceData['version.release'] +
          separator +
          Platform.operatingSystem +
          separator +
          _deviceData['version.incremental'] +
          separator +
          _deviceData['host'];
    } else if (Platform.isIOS) {
      info = _deviceData['identifierForVendor'] +
          separator +
          _deviceData['model'] +
          separator +
          _deviceData['systemVersion'] +
          separator +
          Platform.operatingSystem +
          separator +
          _deviceData['identifierForVendor'] +
          separator +
          _deviceData['systemName'] +
          separator +
          _deviceData['name'];
    }

    return info;
  }
}
