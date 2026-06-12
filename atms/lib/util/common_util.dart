import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loadweb/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/locator.dart';
import '../model/locale_provider.dart';

class CommonUtil {
  /// Save value into SharedPreferences.
  ///
  /// Params: [key], [value]
  ///
  /// Return type [Future<void>]
  static Future<void> saveSharedPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Save value into SharedPreferences.
  ///
  /// Return type [Future<void>]
  static Future<String?> getSharedPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Check connection to the internet.
  /// Look up address [BASE_URL]
  ///
  /// Return type [bool]
  static Future<bool> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  /// Get location
  ///
  /// Return type [Future<void>]
  static Future<String> getCurrentLocation() async {
    String result = "";
    String separator = Constants.PIPE;

    // check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // open setting
    if (permission == LocationPermission.deniedForever) {
      AppSettings.openAppSettings();
      return result;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // get location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      result = '${position.latitude}$separator${position.longitude}';
    }

    return result;
  }

  /// Check file image
  ///
  /// Return type [bool]
  static bool checkIsImageFile(String lowerPath) {
    if (lowerPath.endsWith(".pdf") ||
        lowerPath.endsWith(".txt") ||
        lowerPath.endsWith(".csv") ||
        lowerPath.endsWith(".xls") ||
        lowerPath.endsWith(".xlsx") ||
        lowerPath.endsWith(".doc") ||
        lowerPath.endsWith(".docx") ||
        lowerPath.endsWith(".ppt") ||
        lowerPath.endsWith(".pptx") ||
        lowerPath.endsWith(".ini") ||
        lowerPath.endsWith(".sql") ||
        lowerPath.endsWith(".jpg") ||
        lowerPath.endsWith(".jpeg") ||
        lowerPath.endsWith(".jpe") ||
        lowerPath.endsWith(".jfif") ||
        lowerPath.endsWith(".png") ||
        lowerPath.endsWith(".gif") ||
        lowerPath.endsWith(".webp")) {
      return true;
    }

    return false;
  }

  static Future<String> getLocale() async {
    String? savedLang =
        await CommonUtil.getSharedPreferences(Constants.SHARED_LANG);
    String lang = (savedLang != null && savedLang.isNotEmpty)? savedLang : Constants.LANG_DEFAULT;
    return lang;
  }

  static Future<String> getLocaleVoice() async {
    String? savedLang =
    await CommonUtil.getSharedPreferences(Constants.SHARED_LANG_VOICE);
    String lang = (savedLang != null && savedLang.isNotEmpty)? savedLang : Constants.LANG_VOICE_DEFAULT;
    return lang;
  }

  static String returnNoThing(){
    return Constants.NO_THING;
  }

  static String getLocaleVoiceByLang(String lang) {
    switch (lang) {
      case "vi":
        return "vi_VN";
      case "ja":
        return "ja_JP";
      case "en":
        return "en_US";
      default:
        return "vi_VN";
    }
  }

  static appUpdateLocale(String lang){
    final provider = locator<LocaleProvider>();
    provider.setLang(lang);
  }
}
