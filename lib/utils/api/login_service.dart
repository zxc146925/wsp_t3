import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'config.dart';

class LoginService {
  // 登入
  static Future<http.Response> login(String mail, String password) async {
    print('login-----$mail----$password');

    try {
      Map data = {
        "mail": mail,
        "password": password,
      };

      final url = Uri.https(
        Config.apiUrl, // 替換成你的主機名
        '/user/login',
        {'mail': mail, 'password': password},
      );

      var header = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var body = json.encode(data);

      return await http.post(
        url,
        headers: header,
        body: body,
      );
    } on SocketException {
      return http.Response('', HttpStatus.networkConnectTimeoutError);
    }
  }

  // 忘記密碼
  // static Future<http.Response> forgetPassword(String account) async {

  // }
}
