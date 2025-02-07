import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'config.dart';

class ChatroomService {


  static Future<Map<String, dynamic>> createChatRoom(String userId) async {
    print('createChatRoom');
    final url = Uri.parse('${Config.mediaSocketUrl}/chatroom');

    try {
      Map data = {
        "userId": userId,
      };

      var header = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var body = json.encode(data);

      final response = await http.post(
        url,
        headers: header,
        body: body,
      );

      // 驗證狀態碼並解析回應
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('createChatRoomRequest succ------${response.body}---${response.runtimeType}----${jsonDecode(response.body)}');
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print('createChatRoomRequest response Fail---${response.statusCode}');
        throw Exception('Failed to POST to $url: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      // 捕捉錯誤並回傳
      print('createChatRoom Error in POST request: $e');
      rethrow; // 或自訂錯誤回應
    }
  }


  // 取得詢問歷史前三筆
  static Future<http.Response> getChatroomByUser(int skip, int size, String userId) async {
    print('getChatroomByUser-----skip: $skip----size: $size----userId: $userId');
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/chatroom/user?skip=$skip&size=$size&userId=$userId');
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
      print('Error during getChatroomByUser request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }
}
