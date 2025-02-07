part of 'location_camera_bloc.dart';

@immutable
sealed class LocationCameraState {
  Map<String, CameraEntity> cameraMap = {};
  // 給下拉選單的預設值
  BehaviorSubject<CameraEntity> selectCameraStream = BehaviorSubject<CameraEntity>();
  // 未選擇的攝影機
  Map<String, CameraEntity> unSelectedCameraMap = {};
}

//初始狀態
final class LocationCameraInitial extends LocationCameraState {}

// 初始狀態讀取完成
final class LocationCameraInitialCompleteState extends LocationCameraState {}

//讀取中
class LocationCameraLoadingState extends LocationCameraState {}

//顯示中
class LocationCameraShowingState extends LocationCameraState {}

// 新增中
class LocationCameraAddingState extends LocationCameraState {}

// 移除中
class LocationCameraRemovingState extends LocationCameraState {}

// 加載更多中
class LocationCameraLoadingMoreState extends LocationCameraState {}

// 讀取最多
class LocationCameraReadMoreMaxState extends LocationCameraState {}

//加載失敗
class LocationCameraErrorState extends LocationCameraState {}
