part of 'camera_manager_bloc.dart';

@immutable
sealed class CameraManagerState {
  Map<String, CameraManagerEntity> cameraManagerMap = {};
  BehaviorSubject<String>  cameraIdStream = BehaviorSubject<String>.seeded('');
}

// 初始中
final class CameraManagerInitialState extends CameraManagerState {}

// 初始完成
final class CameraManagerInitialCompleteState extends CameraManagerState {}

// 讀取中
final class CameraManagerLoadingState extends CameraManagerState {}

// 顯示中
final class CameraManagerShowingState extends CameraManagerState {}

// 加載失敗
final class CameraManagerErrorState extends CameraManagerState {}

// 攝影機編輯中
final class CameraManagerEditingState extends CameraManagerState {}

// 攝影機編輯失敗
final class CameraManagerEditErrorState extends CameraManagerState {}

