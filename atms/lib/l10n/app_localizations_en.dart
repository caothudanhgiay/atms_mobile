// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Atms';

  @override
  String get no_internet => 'No internet, please check again.';

  @override
  String get camera_request_title => 'Camera permission required.';

  @override
  String get camera_request_content =>
      'The app needs camera permission to scan codes. Please grant permission in Settings.';

  @override
  String get btn_cancel => 'Cancel';

  @override
  String get btn_open_setting => 'Open Settings';

  @override
  String get btn_delete => 'Delete';

  @override
  String get btn_ok => 'OK';

  @override
  String get let_say => 'Please speak...';

  @override
  String get i_am_listening => 'I\'m listening...';

  @override
  String get speak_or_type => 'Speak or type';

  @override
  String get hint_content => 'Content...';
}
