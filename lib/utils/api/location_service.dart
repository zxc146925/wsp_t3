import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'config.dart';

class LocationService {
  // 取得案場List
  static Future<http.Response> getLocation(int skip, int size, String engineeringId) async {
    print('getLocation-----skip: $skip----size: $size----userId: $engineeringId');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/location?skip=$skip&size=$size&engineeringId=$engineeringId');
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
      print('Error during getLocation request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 取得案場-異常List
  static Future<http.Response> getLocationIncidentList(int skip, int size, String locationId) async {
    print('getLocation-----skip: $skip----size: $size----userId: $locationId');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/incident/location?skip=$skip&size=$size&locationId=$locationId');
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
      return http.Response('getLocationIncidentList Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('getLocationIncidentList Error during getLocation request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 新增案場
  static Future<http.Response> createLocation(String engineeringId, String name, String manager, String phone, int state, String description, int startDatetime, int endDatetime) async {
    print('createLocation-----$engineeringId----$name----$manager----$phone----$state----$description----$startDatetime----$endDatetime');
    try {
      Map data = {
        "location": {
          "name": name,
          "manager": manager,
          "phone": phone,
          "state": state,
          "startDatetime": startDatetime,
          "endDatetime": endDatetime,
          "description": description,
        },
        "engineeringId": engineeringId,
      };
      final url = Uri.https(
        Config.apiUrl,
        '/location',
        {
          "location": json.encode({"name": name, "manager": manager, "phone": phone, "state": state, "startDatetime": startDatetime, "endDatetime": endDatetime, "description": description}),
          'engineeringId': engineeringId
        },
      );
      // 設定標頭
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      // 設定請求內容
      final body = json.encode(data);
      // 发送請求
      return await http.post(
        url,
        headers: headers,
        body: body,
      );
    } on SocketException {
      return http.Response('', HttpStatus.networkConnectTimeoutError);
    }
  }

  // 新增案場攝影機
  static Future<http.Response> createLocationCamera(String locationId, String cameraId) async {
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/location/add-camera');
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
          {"locationId": locationId, "cameraId": cameraId},
        ),
      );
      return response;
    } on SocketException {
      // 返回網路連接超時錯誤
      return http.Response('createLocationCamera Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during createLocationCamera request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  //刪除案場攝影機
  static Future<http.Response> deleteLocationCamera(String locationId, String cameraId) async {
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/location/remove-camera');
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
          {"locationId": locationId, "cameraId": cameraId},
        ),
      );
      return response;
    } on SocketException {
      // 返回網路連接超時錯誤
      return http.Response('deleteCamera Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during deleteCamera request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  //編輯案場
  static Future<http.Response> updateLocation(String id, String name, String manager, String phone, int state, int startDatetime, int endDatetime, String description) async {
    print('updateLocation-----$id----$name----$manager----$phone----$state----$startDatetime----$endDatetime');
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/location');
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
          "location": {"id": id, "name": name, "manager": manager, "phone": phone, "state": state, "startDatetime": startDatetime, "endDatetime": endDatetime, "description": description}
        }),
      );
      return response;
    } on SocketException {
      // 返回網路連接超時錯誤
      return http.Response('updateLocation Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during updateLocation request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }
}
