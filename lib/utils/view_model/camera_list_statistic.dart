class CameraListStatisticViewModel {
  final int date;
  final String cameraId;
  final String cameraName;
  final int incidentCount;
  final int recordCount;

  CameraListStatisticViewModel({required this.date, required this.incidentCount, required this.recordCount,required this.cameraId, required this.cameraName});

  factory CameraListStatisticViewModel.fromJson(Map<String, dynamic> json) {
    return CameraListStatisticViewModel(
      date: json['date'] ?? 0,
      cameraId: json['cameraId'] ?? '',
      cameraName: json['cameraName'] ?? '',
      incidentCount: json['incidentCount'] ?? 0,
      recordCount: json['recordCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'cameraId': cameraId,
      'cameraName': cameraName,
      'incidentCount': incidentCount,
      'recordCount': recordCount,
    };
  }
}
