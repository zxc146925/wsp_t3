part of 'camera_list_statistic_bloc.dart';

@immutable
sealed class CameraListStatisticEvent {}

// 初始
class CameraListStatisticInitEvent extends CameraListStatisticEvent {
  final int skip;
  final int size;
  final String cameraId;
  final String cameraName;
  CameraListStatisticInitEvent({required this.skip, required this.size, required this.cameraId, required this.cameraName});
}

// 下拉更多
class CameraListStatisticLoadMoreEvent extends CameraListStatisticEvent {
  final int skip;
  final int size;
  final String cameraId;
  CameraListStatisticLoadMoreEvent({required this.skip, required this.size, required this.cameraId});
}

// 搜尋
class CameraListStatisticSearchEvent extends CameraListStatisticEvent {
  final int skip;
  final int size;
  final int startDatetime;
  final int endDatetime;
  CameraListStatisticSearchEvent({required this.skip, required this.size,required this.startDatetime, required this.endDatetime});
}

// 更新
class CameraListStatisticUpdateEvent extends CameraListStatisticEvent {
  CameraListStatisticUpdateEvent();
}
