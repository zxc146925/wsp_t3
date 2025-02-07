class VideoRecordViewModel {
  final String thumbnail;
  final String aiThumbnail;
  final String filename;
  final String aiFilename;
  final int startDatetime;
  final int endDatetime;

  VideoRecordViewModel({
    required this.thumbnail,
    required this.aiThumbnail,
    required this.filename,
    required this.aiFilename,
    required this.startDatetime,
    required this.endDatetime,
  });

  factory VideoRecordViewModel.fromJson(Map<String, dynamic> json) => VideoRecordViewModel(
        thumbnail: json['thumbnail'] ?? '',
        aiThumbnail: json['aiThumbnail'] ?? '',
        filename: json['filename'] ?? '',
        aiFilename: json['aiFilename'] ?? '',
        startDatetime: json['startDatetime'] ?? 0,
        endDatetime: json['endDatetime'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'thumbnail': thumbnail,
        'aiThumbnail': aiThumbnail,
        'filename': filename,
        'aiFilename': aiFilename,
        'startDatetime': startDatetime,
        'endDatetime': endDatetime,
      };
}
