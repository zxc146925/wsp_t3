import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'config.dart';

class EngineeringService {
  // 發送 GET 請求取得工程資訊
  static Future<http.Response> getEngineering(int skip, int size, String userId) async {
    print('getEngineering-----skip: $skip----size: $size----userId: $userId');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/engineering?skip=$skip&size=$size&userId=$userId');
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
      print('Error during getEngineering request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  //編輯工程
  static Future<http.Response> updateEngineering(String id, String name, String inspector, String contractor, String engineer, String phone, int startDatetime, int endDatetime, String description) async {
    print('updateEngineering-----id: $id----name: $name----inspector: $inspector----contractor: $contractor----engineer: $engineer----phone: $phone----startDatetime: $startDatetime----endDatetime: $endDatetime----description: $description');
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/engineering');
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
          "engineering": {"id": id, "name": name, "inspector": inspector, "contractor": contractor, "engineer": engineer, "phone": phone, "description": description, "startDatetime": startDatetime, "endDatetime": endDatetime}
        }),
      );
      return response;
    } on SocketException {
      // 返回網路連接超時錯誤
      return http.Response('updateEngineering Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during updateEngineering request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }
}
