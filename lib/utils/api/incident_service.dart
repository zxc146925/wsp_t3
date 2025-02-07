import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'config.dart';

class IncidentService {
  // 發送 GET 請求取得工程資訊
  static Future<http.Response> getIncident(int skip, int size) async {
    print('getIncident-----skip: $skip----size: $size');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/incident/list?skip=$skip&size=$size');
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
      print('Error during getIncident request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 編輯為最愛
  static Future<http.Response> updateIncidentFavorite(String incidentId, int state, bool isPinned) async {
    print('updateIncidentFavorite-----incidentId: $incidentId------state: $state------isPinned: $isPinned');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/incident');
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
            "incident": {'id': incidentId, 'state': state, 'isPinned': isPinned}
          },
        ),
      );
      return response;
    } on SocketException {
      // 返回網路連接超時錯誤
      return http.Response('updateIncidentFavorite Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during updateIncidentFavorite request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 下載檔案
  static Future<http.Response> getExcelData(int startDatetime, int endDatetime) async {
    print('getExcelData------startDatetime: $startDatetime----endDatetime: $endDatetime');
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/incident/report?startDatetime=1734796800000&endDatetime=1734883199000');
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
      return http.Response('getExcelData Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during getExcelData request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  //異常事件搜尋
  static Future<http.Response> getIncidentSearch(int skip, int size, String? keyword, int? startDatetime, int? endDatetime, int? incidentState) async {
    print('getIncidentSearch-----skip: $skip----size: $size----startDatetime: ${startDatetime.toString()}----endDatetime: $endDatetime-----incidentState: $incidentState');
    Map<String, dynamic> data = {
      'skip': skip.toString(),
      'size': size.toString(),
      if (keyword != null) 'keyword': (keyword.trim() == '未處理' || keyword.trim() == '已處理' || keyword.trim() == '作廢') ? '' : keyword.toString(),
      if (startDatetime != null) 'startDatetime': startDatetime.toString(),
      if (endDatetime != null) 'endDatetime': endDatetime.toString(),
      'incidentState': incidentState.toString(),
    };

    try {
      final url = Uri.https(
        'mycena.com.tw:4000',
        '/incident/list/search',
        data,
      );

      print('url----$url');

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
      return http.Response('getIncidentSearch Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during getIncidentSearch request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 影像管理-影像紀錄-異常事件-搜尋
  static Future<http.Response> getIncidentCameraSearch(int skip, int size, String cameraId, int startDatetime, int endDatetime, int? incidentState, String? keyword) async {
    print('getIncidentCameraSearch-----skip: $skip----size: $size----cameraId: $cameraId----startDatetime: $startDatetime----endDatetime: $endDatetime----incidentState: $incidentState----keyword: $keyword');
    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/incident/camera/search?skip=$skip&size=$size&cameraId=$cameraId&startDatetime=$startDatetime&endDatetime=$endDatetime&incidentState=$incidentState&keyword=$keyword');
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
      return http.Response('getIncidentCameraSearch Network connection timeout', HttpStatus.networkConnectTimeoutError);
    } catch (e) {
      // 捕捉其他例外情況
      print('Error during getIncidentCameraSearch request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }

  // 影像管理-影像紀錄-異常事件
  static Future<http.Response> getIncidentCamera(int skip, int size, String cameraId, int startDatetime, int endDatetime) async {
    print('getIncidentCamera-----skip: $skip----size: $size----cameraId: $cameraId----startDatetime: $startDatetime----endDatetime: $endDatetime');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/incident/camera?skip=$skip&size=$size&cameraId=$cameraId&startDatetime=$startDatetime&endDatetime=$endDatetime');
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
      print('Error during getIncident request: $e');
      return http.Response('Unknown error', HttpStatus.internalServerError);
    }
  }
}
