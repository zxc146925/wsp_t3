part of 'video_record_bloc.dart';

@immutable
sealed class VideoRecordEvent {}


// 初始化
class VideoRecordInitEvent extends VideoRecordEvent {
  final int startDatetime;
  final int endDatetime;
  final String cameraId;
  VideoRecordInitEvent({required this.startDatetime, required this.endDatetime, required this.cameraId});
}

