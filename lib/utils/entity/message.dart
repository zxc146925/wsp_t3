class MessageEntity {
  final String id;
  final int createDatetime;
  final String content;
  final String type;
  // final String data;
  final String chatroomId;
  final String senderId;
  String? imageUrl;
  String? videoUrl;
  String? fileUrl;

  MessageEntity({
    required this.id,
    required this.createDatetime,
    required this.content,
    required this.type,
    // required this.data,
    required this.chatroomId,
    required this.senderId,
    this.imageUrl,
    this.videoUrl,
    this.fileUrl,
  });

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(
      id: json['id'] ?? '',
      createDatetime: json['createDatetime'] ?? 0,
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      // data: json['data'] ?? '',
      chatroomId: json['chatroomId'] ?? '',
      senderId: json['senderId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createDatetime': createDatetime,
      'content': content,
      'type': type,
      // 'data': data,
      'chatroomId': chatroomId,
      'senderId': senderId,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'fileUrl': fileUrl,
    };
  }
}
