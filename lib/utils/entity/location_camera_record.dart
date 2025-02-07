class LocationCameraRecordEntity {
  final String thumbnail;
  final String aiThumbnail;
  final String filename;
  final String aiFilename;
  final int startDatetime;
  final int endDatetime;

  LocationCameraRecordEntity({
    required this.thumbnail,
    required this.aiThumbnail,
    required this.filename,
    required this.aiFilename,
    required this.startDatetime,
    required this.endDatetime,
  });

  factory LocationCameraRecordEntity.fromJson(Map<String, dynamic> json) {
    return LocationCameraRecordEntity(
      thumbnail: json['thumbnail'] ?? '',
      aiThumbnail: json['aiThumbnail'] ?? '',
      filename: json['filename'] ?? '',
      aiFilename: json['aiFilename'] ?? '',
      startDatetime: json['startDatetime'] ?? 0,
      endDatetime: json['endDatetime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['thumbnail'] = thumbnail;
    data['aiThumbnail'] = aiThumbnail;
    data['filename'] = filename;
    data['aiFilename'] = aiFilename;
    data['startDatetime'] = startDatetime;
    data['endDatetime'] = endDatetime;
    return data;
  }
}
