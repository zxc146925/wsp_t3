part of 'video_record_bloc.dart';

@immutable
sealed class VideoRecordState {
  // 當前選擇的時間
  String? aiFilename;
  String? filename;
  Map<String, VideoRecordViewModel> videoRecordMap = {};
}

// 初始化
final class VideoRecordInitial extends VideoRecordState {}


// 讀取中
class VideoRecordLoading extends VideoRecordState {}

// 顯示中
class VideoRecordShowing extends VideoRecordState {}

// 加載失敗
class VideoRecordError extends VideoRecordState {}