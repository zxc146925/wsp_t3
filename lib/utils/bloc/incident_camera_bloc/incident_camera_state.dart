part of 'incident_camera_bloc.dart';

@immutable
sealed class IncidentCameraState {
  // 當前選擇的時間
  String? cameraId;
  int? startDatetime;
  int? endDatetime;
  Map<String, IncidentEntity> incidentCameraMap = {};
}

// 初始狀態
final class IncidentCameraInitial extends IncidentCameraState { }

// 讀取中
class IncidentCameraLoading extends IncidentCameraState {}

// 顯示中
class IncidentCameraShowing extends IncidentCameraState {}

// 編輯中
class IncidentCameraEditingState extends IncidentCameraState {}

// 加載更多中
class IncidentCameraLoadingMore extends IncidentCameraState {}

// 加載失敗
class IncidentCameraError extends IncidentCameraState {}

//加載最多
class IncidentCameraReadMoreMaxState extends IncidentCameraState {}
