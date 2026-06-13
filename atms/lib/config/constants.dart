class Constants {
  // URL
  static const String URL_ATMS = "https://atms.vn/?m=app";

  // API
  static const String URL_API = "http://api.atms.vn:9393/api/logs";

  static const String APP_TOKEN = "sf!@#@!#vbc%^";

  // Languages
  static const String LANG_DEFAULT = "vi";
  static const String LANG_VOICE_DEFAULT = "vi_VN";

  // Dialog behavior
  static const String DIALOG_OPENED = "OPENED";
  static const String DIALOG_CLOSED = "CLOSED";

  // *****  function ajax in html - start  *****
  static const String JS_SET_DEVICE_INFO = "setDeviceInfo";
  static const String JS_GET_DEFAULT_LAN = "getDefaultLan";
  static const String JS_GET_DEFAULT_LAN_VOICE = "getDefaultLanVoice";

  static const String JS_BAR_CODE_CHANNEL = "BarcodeScanner";
  static const String JS_BAR_CODE_OPEN_SCAN = "openBarCode";
  static const String JS_BAR_CODE_HANDLE = "handleBarcodeScanResult";
  static const String JS_BAR_CODE_CANCEL = "cancelBarcodeScan";

  static const String JS_APP_INFO_CHANNEL = "AppInfoChannel";
  static const String JS_SEND_DATA_APP_INFO_CHANNEL = "AppSendDataInfoChannel";

  static const String JS_APP_INFO_GET = "getAppInfo";
  static const String JS_APP_INFO_HANDLE = "handleAppInfo";

  static const String JS_APP_INFO_UPDATE_LAN = "updateLan";
  static const String JS_APP_INFO_RELOAD = "Reload";

  static const String JS_APP_INFO_OPEN_VOICE_SEARCH = "openVoiceSearch";
  static const String JS_APP_INFO_HANDLE_VOICE_SEARCH = "handleVoiceSearchResult";

  static const String JS_APP_INFO_OPEN_VOICE_TEXT_PAGE = "openVoiceTextPage";
  static const String JS_APP_INFO_HANDLE_VOICE_TEXT_PAGE = "handleVoiceResultTextPage";

  static const String JS_APP_INFO_GET_TYPE_KEYBOARD = "getTypeKeyBoard";
  static const String JS_APP_INFO_HANDLE_TYPE_KEYBOARD = "handleTypeKeyBoard";

  static const String JS_APP_INFO_KEYBOARD = "getKeyboardInfo";
  static const String JS_APP_INFO_HANDLE_KEYBOARD = "handleKeyboardHeightResult";

  static const String JS_FILE_CHANNEL = "FileChannel";
  static const String JS_FILE_OPEN = "getAppOpenFile";
  static const String JS_FILE_GET_URL = "getAppURL";
  static const String JS_OPEN_WEB = "FlutterOpenWeb";
  static const String JS_OPEN_FILE = "FlutterOpenFile";
  static const String JS_OPEN_PHONE = "FlutterOpenPhone";

  static const String JS_APP_REQUEST_LOCATION = "appResquestLocation";

  // *****  function ajax in html - end  *****

  // punctuation
  static const String PIPE = "|";

  // SharedPreferences
  static const String SHARED_LANG = "lang";
  static const String SHARED_LANG_VOICE = "lang_voice";
  static const String NO_THING = "N/A";
}
