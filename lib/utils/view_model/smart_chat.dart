class SmartChatViewModel {
  final String id;
  final String message;
  final String time;
  final bool isMe;
  // final String imageUrl;
  // final String videoUrl;

  SmartChatViewModel({
    required this.id,
    required this.message,
    required this.time,
    required this.isMe,
    // required this.imageUrl,
    // required this.videoUrl,
  });

  factory SmartChatViewModel.fromJson(Map<String, dynamic> json) {
    return SmartChatViewModel(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      time: json['time'] ?? '',
      isMe: json['isMe'] ?? false,
      // imageUrl: json['imageUrl'] ?? '',
      // videoUrl: json['videoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'time': time,
      // 'isMe': isMe,
      // 'imageUrl': imageUrl,
      // 'videoUrl': videoUrl,
    };
  }
}
