// https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4

// var dataList = [
//   {"id": "2", "title": "file Video 1", "url": "https://download.samplelib.com/mp4/sample-30s.mp4"},
//   {"id": "3", "title": "file Video 2", "url": "https://download.samplelib.com/mp4/sample-20s.mp4"},
//   {"id": "4", "title": "file Video 3", "url": "https://download.samplelib.com/mp4/sample-15s.mp4"},
//   {"id": "5", "title": "file Video 4", "url": "https://download.samplelib.com/mp4/sample-10s.mp4"},
//   {"id": "6", "title": "file PDF 6", "url": "https://www.iso.org/files/live/sites/isoorg/files/store/en/PUB100080.pdf"},
//   {"id": "10", "title": "file PDF 7", "url": "https://www.tutorialspoint.com/javascript/javascript_tutorial.pdf"},
//   {"id": "10", "title": "C++ Tutorial", "url": "https://www.tutorialspoint.com/cplusplus/cpp_tutorial.pdf"},
//   {"id": "11", "title": "file PDF 9", "url": "https://www.iso.org/files/live/sites/isoorg/files/store/en/PUB100431.pdf"},
//   {"id": "12", "title": "file PDF 10", "url": "https://www.tutorialspoint.com/java/java_tutorial.pdf"},
//   {"id": "13", "title": "file PDF 12", "url": "https://www.irs.gov/pub/irs-pdf/p463.pdf"},
//   {"id": "14", "title": "file PDF 11", "url": "https://www.tutorialspoint.com/css/css_tutorial.pdf"},
// ];

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:path/path.dart' as path;

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  var dataList = [
    {"id": "2", "title": "圖片1", "url": "https://hk-media.apjonlinecdn.com/magefan_blog/25-best-hd-wallpapers-laptops159561982840438.jpg"},
    {"id": "3", "title": "m3u8 video", "url": "http://playertest.longtailvideo.com/adaptive/wowzaid3/playlist.m3u8"},
    {"id": "4", "title": "file Video 3", "url": "https://download.samplelib.com/mp4/sample-15s.mp4"},
    {"id": "5", "title": "file Video 4", "url": "https://download.samplelib.com/mp4/sample-10s.mp4"},
    {"id": "6", "title": "file PDF 6", "url": "https://www.iso.org/files/live/sites/isoorg/files/store/en/PUB100080.pdf"},
    {"id": "10", "title": "file PDF 7", "url": "https://www.tutorialspoint.com/javascript/javascript_tutorial.pdf"},
    {"id": "10", "title": "C++ Tutorial", "url": "https://www.tutorialspoint.com/cplusplus/cpp_tutorial.pdf"},
    {"id": "11", "title": "file PDF 9", "url": "https://www.iso.org/files/live/sites/isoorg/files/store/en/PUB100431.pdf"},
    {"id": "12", "title": "file PDF 10", "url": "https://www.tutorialspoint.com/java/java_tutorial.pdf"},
    {"id": "13", "title": "file PDF 12", "url": "https://www.irs.gov/pub/irs-pdf/p463.pdf"},
    {"id": "14", "title": "file PDF 11", "url": "https://www.tutorialspoint.com/css/css_tutorial.pdf"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (BuildContext context, int index) {
          var data = dataList[index];
          return TileList(
            fileUrl: data['url']!,
            title: data['title']!,
          );
        },
      ),
    );
  }
}

class TileList extends StatefulWidget {
  const TileList({super.key, required this.fileUrl, required this.title});
  final String fileUrl;
  final String title;

  @override
  State<TileList> createState() => _TileListState();
}

class _TileListState extends State<TileList> {
  bool downloading = false;
  double progress = 0;
  late CancelToken cancelToken;

  // 取得檔案副檔名
  String getFileExtension() {
    return path.extension(widget.fileUrl).toLowerCase();
  }

  // 取得檔案類型圖示
  IconData getFileTypeIcon() {
    final extension = getFileExtension();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.mp4':
      case '.avi':
      case '.mov':
        return Icons.video_file;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image;
      case '.csv':
      case '.xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  // 取得 MIME 類型
  String getMimeType() {
    final extension = getFileExtension();
    switch (extension) {
      case '.pdf':
        return 'application/pdf';
      case '.mp4':
        return 'video/mp4';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.csv':
        return 'text/csv';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> startDownload() async {
    cancelToken = CancelToken();
    setState(() {
      downloading = true;
      progress = 0;
    });

    try {
      // 方法1：使用直接下載（適用於簡單情況）
      // if (widget.fileUrl.startsWith('http')) {
      //   directDownload();
      //   setState(() {
      //     downloading = false;
      //   });
      //   return;
      // }

      // 方法2：使用 Dio 下載（需要顯示進度或特殊處理時）
      final response = await Dio().get(
        widget.fileUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': '*/*',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress = received / total;
            });
          }
        },
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final blob = html.Blob(
          [response.data],
          getMimeType(),
        );
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "${widget.title}${getFileExtension()}")
          ..style.display = 'none';

        html.document.body!.children.add(anchor);
        anchor.click();
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }

      setState(() {
        downloading = false;
      });
    } catch (e) {
      print('Download error: $e');
      // 如果 Dio 下載失敗，嘗試直接下載
      directDownload();
      setState(() {
        downloading = false;
      });
    }
  }

  // 直接下載方法
  void directDownload() {
    final anchor = html.AnchorElement(href: widget.fileUrl)
      ..setAttribute("download", "${widget.title}${getFileExtension()}")
      ..setAttribute("target", "_blank");

    // 某些瀏覽器需要將元素加入到 DOM 中
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
  }

  void cancelDownload() {
    cancelToken.cancel();
    setState(() {
      downloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.grey.shade100,
      child: ListTile(
        title: Text(widget.title),
        trailing: IconButton(
          onPressed: downloading ? cancelDownload : startDownload,
          icon: downloading
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: Colors.grey,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    Text(
                      (progress * 100).toStringAsFixed(2),
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                )
              : const Icon(Icons.download),
        ),
      ),
    );
  }
}
