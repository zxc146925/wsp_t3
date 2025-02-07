import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'config.dart';

class UserService {
  // 發送 GET 請求取得工程資訊
  static Future<http.Response> getUser(int skip, int size) async {
    print('getUser-----skip: $skip----size: $size');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/user?skip=$skip&size=$size');
      // 設定標頭
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      // 發送 GET 請求
      final response = await http.get(url, headers: headers);
      return response;
    } on SocketException {
      // 返回網路連接超時錯誤
      return http.Response('Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during getUser request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 編輯使用者
  static Future<http.Response> updateUser(String id, String mail, String name, String phone, int permission) async {
    print('編輯使用者-----$id----$mail----$name----$phone----$permission');
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/user');
      // 設定標頭
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      // 發送 GET 請求
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({
          "user": {"id": id, "mail": mail, "name": name, "phone": phone, "permission": permission}
        }),
      );
      return response;
    } on SocketException {
      // 返回網路連接超時錯誤
      return http.Response('updateCamera Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during updateCamera request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 新增使用者
  static Future<http.Response> registerUser(String mail, String password, String name, String phone, int permission, String engineeringId) async {
    print('registerUser-----$mail----$password----$name----$phone----$permission----$engineeringId');
    final url = Uri.parse('${Config.mediaSocketUrl}/user/register');

    try {
      Map data = {
        "user": {"mail": mail, "password": password, "name": name, "phone": phone, "permission": permission},
        "engineeringId": engineeringId
      };

      var header = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var body = json.encode(data);

      return await http.post(
        Config.isLocal
            ? url
            : Uri.https(
                Config.mediaSocketUrl,
                '/user/register',
              ),
        headers: header,
        body: body,
      );
    } on SocketException {
      return http.Response('', HttpStatus.networkConnectTimeoutError);
    }
  }
}
