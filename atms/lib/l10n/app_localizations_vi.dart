// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get app_name => 'Atms';

  @override
  String get no_internet => 'Không có internet, vui lòng kiểm tra lại.';

  @override
  String get camera_request_title => 'Cần quyền camera.';

  @override
  String get camera_request_content =>
      'Ứng dụng cần quyền camera để quét mã. Hãy cấp quyền trong phần Cài đặt.';

  @override
  String get btn_cancel => 'Hủy';

  @override
  String get btn_open_setting => 'Mở cài đặt';

  @override
  String get btn_delete => 'Xóa';

  @override
  String get btn_ok => 'Đồng ý';

  @override
  String get let_say => 'Bạn nói đi...';

  @override
  String get i_am_listening => 'Mình đang lắng nghe…';

  @override
  String get speak_or_type => 'Nói hoặc nhập nội dung';

  @override
  String get hint_content => 'Nội dung...';
}
