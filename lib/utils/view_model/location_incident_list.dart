class LocationIncidentListViewModel {
  String id;
  String title;
  int updateDatetime;
  String imageUrl;
  String videoUrl;
  int createDatetime;
  bool isPinned;
  int state;
  String type;
  int startDatetime;

  LocationIncidentListViewModel({
    required this.id,
    required this.title,
    required this.updateDatetime,
    required this.imageUrl,
    required this.videoUrl,
    required this.createDatetime,
    required this.isPinned,
    required this.state,
    required this.type,
    required this.startDatetime,
  });

  factory LocationIncidentListViewModel.fromJson(Map<String, dynamic> json) => LocationIncidentListViewModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        updateDatetime: json['updateDatetime'] ?? 0,
        imageUrl: json['imageUrl'] ?? '',
        videoUrl: json['videoUrl'] ?? '',
        createDatetime: json['createDatetime'] ?? 0,
        isPinned: json['isPinned'] ?? false,
        state: json['state'] ?? 0,
        type: json['type'] ?? '',
        startDatetime: json['startDatetime'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'updateDatetime': updateDatetime,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'createDatetime': createDatetime,
        'isPinned': isPinned,
        'state': state,
        'type': type,
        'startDatetime': startDatetime,
      };
}
