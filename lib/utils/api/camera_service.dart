import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'config.dart';

class CameraService {
  // 發送 GET 請求取得工程資訊
  static Future<http.Response> getLocationCamera(int skip, int size, String locationId) async {
    print('getLocationCamera-----skip: $skip----size: $size----locationId: $locationId');
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/camera/location?skip=$skip&size=$size&locationId=$locationId');
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
      print('Error during getLocationCamera request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 取得攝影機管理
  static Future<http.Response> getCameraList(int skip, int size) async {
    print('getCameraList-----skip: $skip----size: $size');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/camera?skip=$skip&size=$size');
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
      print('Error during getCameraList request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 影像管理-影像紀錄中間部分搜尋
  static Future<http.Response> getCameraListStatisticSearch({required int skip, required int size, required String cameraId, required int startDatetime, required int endDatetime}) async {
    print('getCameraListStatisticSearch-----skip: $skip----size: $size---cameraId:$cameraId---------startDatetime:$startDatetime--------endDatetime:$endDatetime');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/camera/list/statistic/search?skip=$skip&size=$size&cameraId=$cameraId&startDatetime=$startDatetime&endDatetime=$endDatetime');
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
      print('Error during getCameraListStatisticSearch request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 編輯攝影機
  static Future<http.Response> updateCamera(String id, String name, String ip, int port, String protocol, String web, String urlPath, String account, String password) async {
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/camera');
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
          {
            "camera": {"id": id, "name": name, "ip": ip, "port": port, "protocol": protocol, "web": web, "urlPath": urlPath, "account": account, "password": password},
          },
        ),
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

  // 取得案場中未使用的攝影機
  static Future<http.Response> getCameraIdle(int skip, int size) async {
    print('getCameraIdle-----skip: $skip----size: $size');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/camera/idle?skip=$skip&size=$size');
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
      return http.Response('getCameraIdle Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      return http.Response('getCameraIdle Unknown error', HttpStatus.internalServerError);
    }
  }

  // 取得影像紀錄的中間區塊
  static Future<http.Response> getCameraListStatistic(int skip, int size, String cameraId) async {
    print('getCameraListStatistic-----skip: $skip----size: $size----cameraId: $cameraId');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/camera/list/statistic?skip=$skip&size=$size&cameraId=$cameraId');
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
      return http.Response('getCameraListStatistic Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      return http.Response('getCameraListStatistic Unknown error', HttpStatus.internalServerError);
    }
  }
}
