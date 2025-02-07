import 'package:http/http.dart' as http;
import 'dart:io';
import 'config.dart';

class RecordService {
  // 取得案場管理的影像紀錄
  static Future<http.Response> getRecordCameraAndLocation({required int skip, required int size, required String cameraId, required String locationId}) async {
    print('getRecordCameraAndLocation-----skip: $skip----size: $size----cameraId: $cameraId----locationId: $locationId');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/record/camera-and-location?skip=$skip&size=$size&cameraId=$cameraId&locationId=$locationId');
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

  // 取得影像管理-影像紀錄-影像紀錄
  static Future<http.Response> getRecordCamera({required int startDatetime, required int endDatetime, required String cameraId}) async {
    print('getRecordCamera------cameraId: $cameraId----startDatetime: $startDatetime----endDatetime: $endDatetime');

    try {
      final url = Uri.parse('${Config.mediaSocketUrl}/record/camera?startDatetime=$startDatetime&endDatetime=$endDatetime&cameraId=$cameraId');
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
