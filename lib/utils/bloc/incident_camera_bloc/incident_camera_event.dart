part of 'incident_camera_bloc.dart';

@immutable
sealed class IncidentCameraEvent {}

// 初始化
class IncidentCameraInitialEvent extends IncidentCameraEvent {
  final int skip;
  final int size;
  final String cameraId;
  final int startDatetime;
  final int endDatetime;
  IncidentCameraInitialEvent({
    required this.skip,
    required this.size,
    required this.cameraId,
    required this.startDatetime,
    required this.endDatetime,
  });
}

// 加載更多
class IncidentCameraLoadMoreEvent extends IncidentCameraEvent {
  final int skip;
  final int size;
  // 根據初始以暫存到Bloc
  // final String cameraId;
  // final int startDatetime;
  // final int endDatetime;
  IncidentCameraLoadMoreEvent({
    required this.skip,
    required this.size,
    // required this.cameraId,
    // required this.startDatetime,
    // required this.endDatetime,
  });
}

//搜尋
class IncidentCameraSearchEvent extends IncidentCameraEvent {
  final int skip;
  final int size;
  final String cameraId;
  final int startDatetime;
  final int endDatetime;
  final int? incidentState;
  final String? keyword;

  IncidentCameraSearchEvent({
    required this.skip,
    required this.size,
    required this.cameraId,
    required this.startDatetime,
    required this.endDatetime,
    this.incidentState,
    this.keyword,
  });
}

// 下滑搜尋更多
class IncidentCameraSearchMoreEvent extends IncidentCameraEvent {
  final int skip;
  final int size;
  final String cameraId;
  final int startDatetime;
  final int endDatetime;
  final int? incidentState;
  final String? keyword;

  IncidentCameraSearchMoreEvent({
    required this.skip,
    required this.size,
    required this.cameraId,
    required this.startDatetime,
    required this.endDatetime,
    this.incidentState,
    this.keyword,
  });
}

//更新
class UpdateIncidentCameraEvent extends IncidentCameraEvent {
  // 判斷是編輯還是添加最愛
  final bool isEdit;
  final String incidentId;
  final int state;
  final bool isPinned;
  UpdateIncidentCameraEvent({required this.incidentId, required this.state, required this.isPinned, required this.isEdit});
}

