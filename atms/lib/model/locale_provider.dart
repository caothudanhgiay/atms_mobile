import 'package:flutter/cupertino.dart';

import '../config/constants.dart';

class LocaleProvider extends ChangeNotifier {
  String _lang = Constants.LANG_DEFAULT;

  String get lang => _lang;

  void setLang(String newLang) {
    _lang = newLang;
    notifyListeners();
  }
}