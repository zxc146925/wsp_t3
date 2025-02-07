import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'config.dart';

class MessageService {
  // 取得聊天內容
  static Future<http.Response> getMessageList({required int skip, required int size, required String chatroomId}) async {
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/message?skip=$skip&size=$size&chatroomId=$chatroomId');
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
      return http.Response('getMessageList Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during getMessageList request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // message
  static Future<Map<String, dynamic>> sendMessageRequest({required String userId, required String text, required String chatroomId, required bool isFirst}) async {
    print('sendMessageRequest-------text:$text----chatroomId:$chatroomId---userId:$userId');

    final url = Uri.parse('${Config.mediaSocketUrl}/message');

    Map data = {
      "message": {
        "content": text,
        "type": "text",
        "data": "",
      },
      "chatroomId": chatroomId,
      "senderId": userId,
      "isFirst": isFirst,
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('sendMessageRequest succ------${jsonDecode(utf8.decode(response.bodyBytes))}}');
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      print('sendMessageRequest response Fail---${response.statusCode}');
      return {};
    }
  }
}
