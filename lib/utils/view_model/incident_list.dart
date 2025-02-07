class IncidentListViewModel {
  String id;
  String title;
  int state;
  String locationName;
  String cameraName;
  int createDatetime;
  int time;
  bool isPinned;
  String cameraId;
  String videoUrl;

  IncidentListViewModel({
    required this.id,
    required this.state,
    required this.title,
    required this.locationName,
    required this.cameraName,
    required this.createDatetime,
    required this.time,
    required this.isPinned,
    required this.cameraId,
    required this.videoUrl,
  });

  factory IncidentListViewModel.fromJson(Map<String, dynamic> json) {
    return IncidentListViewModel(
      id: json['id'] ?? '',
      state: json['state'] ?? 0,
      title: json['title'] ?? '',
      locationName: json['locationName'] ?? '',
      cameraName: json['cameraName'] ?? '',
      createDatetime: json['createDatetime'] ?? 0,
      time: json['time'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      cameraId: json['cameraId'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'title': title,
      'locationName': locationName,
      'cameraName': cameraName,
      'createDatetime': createDatetime,
      'time': time,
      'isPinned': isPinned,
      'cameraId': cameraId,
      'videoUrl': videoUrl,
    };
  }
}
