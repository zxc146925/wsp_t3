part of 'video_bloc.dart';

@immutable
sealed class VideoState {
  Map<String,CameraEntity> cameraMap = {};
  VideoPlayerController? controller;
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  @override
  final VideoPlayerController controller;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final bool isLive;

  VideoLoaded({
    required this.controller,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.isLive,
  });
}

class VideoError extends VideoState {
  final String message;

  VideoError(this.message);
}
