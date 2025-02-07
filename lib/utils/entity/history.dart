class HistoryEntity {
  final String id;
  final String title;
  final int createDatetime;

  HistoryEntity({
    required this.id,
    required this.title,
    required this.createDatetime,
  });

  factory HistoryEntity.fromJson(Map<String, dynamic> json) {
    return HistoryEntity(
      id: json['id'],
      title: json['title'] ?? '',
      createDatetime: json['createDatetime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createDatetime': createDatetime,
    };
  }
}
