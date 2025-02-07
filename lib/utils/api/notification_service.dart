import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'config.dart';

class NotificationService {
  // 發送 GET 請求取得工程資訊
  static Future<http.Response> getNotifaiction(int skip, int size, String userId) async {
    // print('getNotifaiction-----skip: $skip----size: $size----userId: $userId');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/notification?skip=$skip&size=$size&userId=$userId');
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
      print('Error during getNotifaiction request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  static Future<http.Response> updateNotifaictionRead(String notificationId, String userId) async {
    print('updateNotifaictionRead-----notificationId: $notificationId------userId: $userId');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/notification/read');
      // 設定標頭
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      // 發送 GET 請求
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(
          {'notificationId': notificationId, 'userId': userId},
        ),
      );
      return response;
    } on SocketException {
      // 返回網路連接超時錯誤
      return http.Response('Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during getNotifaiction request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }
}
