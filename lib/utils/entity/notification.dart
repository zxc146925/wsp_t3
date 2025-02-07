class NotificationEntity {
  final String id;
  final String title;
  // final String content;
  final int createDatetime;
  final bool read;
  final String incidentId;
  // final String imageUrl;
  // final String videoUrl;

  NotificationEntity({
    required this.id,
    required this.title,
    // required this.content,
    required this.createDatetime,
    required this.read,
    required this.incidentId,
    // required this.imageUrl,
    // required this.videoUrl,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'],
      title: json['title'],
      // content: json['content'],
      createDatetime: json['createDatetime'],
      read: json['read'],
      incidentId: json['data']['incidentId'],
      // imageUrl: json['imageUrl'],
      // videoUrl: json['videoUrl'],
    );

  
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      // 'content': content,
      'createDatetime': createDatetime,
      'read': read,
      // 'imageUrl': imageUrl,
      // 'videoUrl': videoUrl,
    };
  }
}
