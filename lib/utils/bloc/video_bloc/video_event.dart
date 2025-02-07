part of 'video_bloc.dart';

@immutable
sealed class VideoEvent {}
class VideoLoadEvent extends VideoEvent {
  final String videoUrl;
  final bool isLive;

  VideoLoadEvent(this.videoUrl, {this.isLive = false});
}

class VideoPlayPauseEvent extends VideoEvent {}

class VideoDisposeEvent extends VideoEvent {}

class VideoProgressUpdateEvent extends VideoEvent {}

class VideoSelectEvent extends VideoEvent {
  final String videoUrl;
  final bool isLive;

  VideoSelectEvent(this.videoUrl, {this.isLive = false});
}

class VideoLoadErrorEvent extends VideoEvent {
  VideoLoadErrorEvent();
}

/// 新增：用來調整影片進度的事件
class VideoSeekEvent extends VideoEvent {
  final Duration seekPosition;
  VideoSeekEvent(this.seekPosition);
}