import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loadweb/config/constants.dart';

class APIService {
  static void sendData(logLevel, fncName, logMsg, memberName) async {
    final response = await http.post(
      Uri.parse(Constants.URL_API),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "token": Constants.APP_TOKEN,
        "log_level": logLevel,
        "function_name": fncName,
        "log_message": logMsg,
        "member_name": memberName
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('Đã gửi: $data');
    } else {
      print('Gửi thất bại: ${response.statusCode}');
    }
  }

  static void writeLogInfo(func, msg) {
    int logLevel = 3;
    String fncName = "[APP_MOBILE] " + func;
    String logMsg = "[INFO]: " + msg;
    String memberName = "[APP_MOBILE]";

    sendData(logLevel, fncName, logMsg, memberName);
  }

  static void writeLogError(msg) {
    int logLevel = 3;
    String fncName = "[APP_MOBILE] ";
    String logMsg = "[ERROR]: " + msg;
    String memberName = "[APP_MOBILE]";

    sendData(logLevel, fncName, logMsg, memberName);
  }
}
