part of 'camera_list_statistic_bloc.dart';

@immutable
sealed class CameraListStatisticState {
  // 當下的CamerId
  String cameraId = '';
  String cameraName = '';
  List<CameraListStatisticViewModel> cameraListStatisticViewModelList = [];
}

// 初始
final class CameraListStatisticInitial extends CameraListStatisticState {}

// 初始完成
final class CameraListStatisticInitialComplete extends CameraListStatisticState {}

// 讀取中
class CameraListStatisticLoading extends CameraListStatisticState {}

// 顯示中
class CameraListStatisticShowing extends CameraListStatisticState {}

// 加載更多中(UI轉圈)
class CameraListStatisticLoadingMore extends CameraListStatisticState {}

// 加載失敗
class CameraListStatisticError extends CameraListStatisticState {}

//加載最多
class CameraListStatisticReadMax extends CameraListStatisticState {}

// 最新數據
class CameraListStatisticShowLatest extends CameraListStatisticState {}
