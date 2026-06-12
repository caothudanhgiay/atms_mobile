// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get app_name => 'Atms';

  @override
  String get no_internet => 'インターネットがありません。もう一度確認してください。';

  @override
  String get camera_request_title => 'カメラの許可が必要です。';

  @override
  String get camera_request_content =>
      'コードをスキャンするためにアプリがカメラの許可を必要としています。設定で許可を付与してください。';

  @override
  String get btn_cancel => 'キャンセル';

  @override
  String get btn_open_setting => '設定を開く';

  @override
  String get btn_delete => '消去';

  @override
  String get btn_ok => '同意する';

  @override
  String get let_say => '話してください。。。';

  @override
  String get i_am_listening => '聞いてますよ。。。';

  @override
  String get speak_or_type => '話すか入力する';

  @override
  String get hint_content => 'コンテンツ。。。';
}
