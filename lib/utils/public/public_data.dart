import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;

import 'package:rxdart/rxdart.dart';

import '../entity/incident.dart';

class PublicData {
  // 給影像管理的異常事件Drawer使用
  static GlobalKey<ScaffoldState> incidentScaffoldKey = GlobalKey<ScaffoldState>();
  static BehaviorSubject<IncidentEntity> selectIncidentSubject = BehaviorSubject<IncidentEntity>();

  // 異常狀態
  static List<String> stateListName = ['未處理', '已處理', '作廢'];
  // 案場狀態
  static List<String> locationType = ['未開工', '執行中', '暫停施工', '已結案'];
  // 攝影機狀態
  static List<String> cameraType = ['未連線', '已連線'];

  static String getDateTimeForm(int createDatetime) {
    return DateFormat('yyyy/MM/dd HH:mm:ss').format(
      DateTime.fromMillisecondsSinceEpoch(createDatetime),
    );
  }

  // 將日期毫秒轉換成年月日毫秒，把時間捨去
  static int truncateToDateMilliseconds(int inputMilliseconds) {
    // 將毫秒轉換為 DateTime
    DateTime inputDate = DateTime.fromMillisecondsSinceEpoch(inputMilliseconds);

    // 建立只保留年月日的 DateTime
    DateTime dateOnly = DateTime(inputDate.year, inputDate.month, inputDate.day);

    // 返回毫秒
    return dateOnly.millisecondsSinceEpoch;
  }

  static String getDateForm(int createDatetime) {
    return DateFormat('yyyy/MM/dd').format(
      DateTime.fromMillisecondsSinceEpoch(createDatetime),
    );
  }

  static String getTimeForm(int createDatetime) {
    return DateFormat('HH:mm:ss').format(
      DateTime.fromMillisecondsSinceEpoch(createDatetime),
    );
  }

  // 直接下載方法
  static directDownload(String fireUrl, String fileName) {
    final anchor = html.AnchorElement(href: fireUrl)
      ..setAttribute("download", fileName)
      ..setAttribute("target", "_blank");

    // 某些瀏覽器需要將元素加入到 DOM 中
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
  }

  // 根據物件的名字取得ID
  static String? findIdByName(String name, Map<String, dynamic> map) {
    for (var entry in map.entries) {
      if (entry.value.name == name) {
        return entry.value.id;
      }
    }
    return null;
  }

    // 判斷有無關鍵字錯誤
 static bool hasErrorMessage(String text) {
    // 定義需要偵測的錯誤訊息
    const errorIndicator = '處理您的問題時發生錯誤。請稍後再試或聯繫系統管理員。';
    // 如果字串中包含 errorIndicator 就回傳 true
    return text.contains(errorIndicator);
  }

  ///處理詢問歷史的UI時間
 static String formatRecordDate(int timestamp) {
    // 取得現在的時間與今天的日期（只保留年月日）
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // 將 timestamp 轉換為 DateTime 物件
    DateTime record = DateTime.fromMillisecondsSinceEpoch(timestamp);
    // 只保留年月日部分，用來進行日期比對
    DateTime recordDate = DateTime(record.year, record.month, record.day);

    // 計算今天與該筆資料日期相差幾天
    int diffDays = today.difference(recordDate).inDays;

    if (diffDays == 0) {
      // 今天：僅回傳時間
      return DateFormat('HH:mm').format(record);
    } else if (diffDays == 1) {
      // 昨天：回傳「昨天」加上時間
      return "昨天 ${DateFormat('HH:mm').format(record)}";
    } else {
      // 前天或更早：回傳完整的日期加時間
      return DateFormat('yyyy/MM/dd HH:mm').format(record);
    }
  }

  // 輔助函數：將 Duration 格式化為 mm:ss
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // 擷取url中的第一部分，舉例：camera-1/1241241ji124.mp4 第一部分為 camera-1
  static List<String> splitByFirstSlash(String input) {
    int index = input.indexOf('/');
    if (index != -1) {
      return [
        input.substring(0, index), // 第一部分
        input.substring(index + 1), // 第二部分
      ];
    } else {
      throw ArgumentError('Input string does not contain "/"');
    }
  }

  // 把文字輸入的內容，轉換特地的異常狀態
  static int getTextToincidentState(String text) {
    switch (text.trim()) {
      case '未處理':
        {
          return 0;
        }
      case '已處理':
        {
          return 1;
        }
      case '作廢':
        {
          return 2;
        }
      default:
        {
          return 0;
        }
    }
  }

  // 產生Excel並下載
  static void generateAndDownloadExcel() {
    List<dynamic> lists = [
      {"time": 1734838505949, "cameraName": "camera-2", "engineeringName": "臺灣桃園國際機場第三航站區主體航廈土建工程", "locationName": "第三航廈主體工區", "incidentType": "A2-1", "incidentState": 0},
      {"time": 1734838505624, "cameraName": "camera-2", "engineeringName": "臺灣桃園國際機場第三航站區主體航廈土建工程", "locationName": "第三航廈主體工區", "incidentType": "A2-1", "incidentState": 0},
      {"time": 1734838505598, "cameraName": "camera-2", "engineeringName": "臺灣桃園國際機場第三航站區主體航廈土建工程", "locationName": "第三航廈主體工區", "incidentType": "A1", "incidentState": 0},
      {"time": 1734838502905, "cameraName": "camera-2", "engineeringName": "臺灣桃園國際機場第三航站區主體航廈土建工程", "locationName": "第三航廈主體工區", "incidentType": "A1", "incidentState": 0},
      {"time": 1734838436574, "cameraName": "camera-2", "engineeringName": "臺灣桃園國際機場第三航站區主體航廈土建工程", "locationName": "第三航廈主體工區", "incidentType": "A1", "incidentState": 0},
      {"time": 1734838148656, "cameraName": "camera-2", "engineeringName": "臺灣桃園國際機場第三航站區主體航廈土建工程", "locationName": "第三航廈主體工區", "incidentType": "A1", "incidentState": 0},
      {"time": 1734838145131, "cameraName": "camera-2", "engineeringName": "臺灣桃園國際機場第三航站區主體航廈土建工程", "locationName": "第三航廈主體工區", "incidentType": "A1", "incidentState": 0},
      {"time": 1734838142477, "cameraName": "camera-2", "engineeringName": "臺灣桃園國際機場第三航站區主體航廈土建工程", "locationName": "第三航廈主體工區", "incidentType": "A1", "incidentState": 0},
      {"time": 1734837884439, "cameraName": "camera-2", "engineeringName": "臺灣桃園國際機場第三航站區主體航廈土建工程", "locationName": "第三航廈主體工區", "incidentType": "A1", "incidentState": 0},
      {"time": 1734837878568, "cameraName": "camera-2", "engineeringName": "臺灣桃園國際機場第三航站區主體航廈土建工程", "locationName": "第三航廈主體工區", "incidentType": "A1", "incidentState": 0}
    ];

    // 1. 建立 Excel
    var excel = Excel.createExcel(); // 建立新的 Excel
    Sheet sheetObject = excel['Sheet1']; // 取得工作表
    sheetObject.appendRow(
      [
        TextCellValue('工程名稱'),
        TextCellValue('案場名稱'),
        TextCellValue('時間'),
        TextCellValue('攝影機名稱'),
        TextCellValue('異常類型'),
        TextCellValue('是否已處理'),
      ],
    ); // 添加標題行

    for (var data in lists) {
      // DateTime utcDate = DateTime.fromMillisecondsSinceEpoch(data['time'] as int, isUtc: true);
      // DateTime taiwanDate = utcDate.toLocal();
      // String formattedDate = "${taiwanDate.year}-${taiwanDate.month.toString().padLeft(2, '0')}-${taiwanDate.day.toString().padLeft(2, '0')} "
      //     "${taiwanDate.hour.toString().padLeft(2, '0')}:${taiwanDate.minute.toString().padLeft(2, '0')}:${taiwanDate.second.toString().padLeft(2, '0')}";

      // print(formattedDate);
      sheetObject.appendRow(
        [
          TextCellValue(data['engineeringName']),
          TextCellValue(data['locationName']),
          TextCellValue(data['time'].toString()),
          TextCellValue(data['cameraName']),
          TextCellValue(data['incidentType'].toString()),
          TextCellValue(data['incidentState'].toString()),
        ],
      ); // 添加數據行
    }

    // 2. 轉換為二進制格式
    final List<int>? fileBytes = excel.save();
    if (fileBytes == null) {
      print('Excel file creation failed.');
      return;
    }

    // 3. 在 Flutter Web 中下載文件
    final blob = html.Blob([Uint8List.fromList(fileBytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'example.xlsx'; // 指定檔案名稱
    anchor.click();
    html.Url.revokeObjectUrl(url); // 釋放 URL
  }

  // 條文轉變
  static String getArticles(String type) {
    switch (type) {
      case 'A1':
        {
          return '「 一般作業人員是否穿戴安全帽」';
        }
      case 'A2':
        {
          return '「 道路作業人員是否穿戴安全帽、反光背心 」';
        }
      case 'A2-1':
        {
          return '「 道路作業人員是否穿戴安全帽 」';
        }
      case 'A2-2':
        {
          return '「 道路作業人員是否穿戴反光背心 」';
        }
      case 'A3':
        {
          return '「 梯上作業人員是否穿戴安全帽 」';
        }
      case 'A4':
        {
          return '「 直臂式高空作業人員是否穿戴安全帽、背負式安全帶 」';
        }
      case 'A4-1':
        {
          return '「 直臂式高空作業人員是否穿戴安全帽 」';
        }
      case 'A4-2':
        {
          return '「 直臂式高空作業人員是否穿戴背負式安全帶 」';
        }
      case 'A5':
        {
          return '「 剪刀車作業人員是否穿戴安全帽、背負式安全帶 」';
        }
      case 'A5-1':
        {
          return '「 剪刀車作業人員是否穿戴安全帽 」';
        }
      case 'A5-2':
        {
          return '「 剪刀車作業人員是否穿戴背負式安全帶 」';
        }
      case 'C1':
        {
          return '「 工作梯需要有人扶著 」';
        }
      case 'C2':
        {
          return '「 梯子不得高於2公尺 」';
        }
      case 'C3':
        {
          return '「 挖土機作業安全行為辨識-不能從事吊掛作業 」';
        }
      case 'C4':
        {
          return '「 吊臂車需有安全裝置-外伸撐座 」';
        }
      case 'C5':
        {
          return '「 人員不得進入營建系車輛危險範圍 」';
        }
      default:
        {
          return '「 超過條款範圍 」';
        }
    }
  }
}
