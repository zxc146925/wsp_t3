part of 'location_camera_record_bloc.dart';

@immutable
sealed class LocationCameraRecordState {
  Map<String, LocationCameraRecordEntity> locationCameraRecordMap = {};
}

// 初始化
final class LocationCameraRecordInitial extends LocationCameraRecordState {}

// 初始化完成
final class LocationCameraRecordInitialComplete extends LocationCameraRecordState {}

// 讀取中
class LocationCameraRecordLoading extends LocationCameraRecordState {}

// 顯示中
class LocationCameraRecordShowing extends LocationCameraRecordState {}

// 加載更多中
class LocationCameraRecordLoadingMore extends LocationCameraRecordState {}

// 加載失敗
class LocationCameraRecordError extends LocationCameraRecordState {}

// 讀取最多
class LocationCameraRecordReadMax extends LocationCameraRecordState {}
