class IncidentEntity {
  final String id;
  final int state;
  final String title;
  final int startDatetime;
  final int createDatetime;
  final int updateDatetime;
  final String type;
  final bool isPinned;
  final String imageUrl;
  final String videoUrl;

  IncidentEntity({
    required this.id,
    required this.state,
    required this.title,
    required this.startDatetime,
    required this.createDatetime,
    required this.updateDatetime,
    required this.type,
    required this.isPinned,
    required this.imageUrl,
    required this.videoUrl,
  });

  factory IncidentEntity.fromJson(Map<String, dynamic> json) {
    return IncidentEntity(
      id: json['id'] ?? '',
      state: json['state'] ?? 0,
      title: json['title'] ?? '',
      startDatetime: json['startDatetime'] ?? 0,
      createDatetime: json['createDatetime']?? 0,
      updateDatetime: json['updateDatetime']?? 0,
      type: json['type'] ??'',
      isPinned: json['isPinned'] ?? false,
      imageUrl: json['imageUrl'] ??'',
      videoUrl: json['videoUrl'] ??'',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'title': title,
      'startDatetime': startDatetime,
      'createDatetime': createDatetime,
      'updateDatetime': updateDatetime,
      'type': type,
      'isPinned': isPinned,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }
}
