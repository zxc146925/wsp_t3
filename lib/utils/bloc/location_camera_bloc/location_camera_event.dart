part of 'location_camera_bloc.dart';

@immutable
sealed class LocationCameraEvent {}

// 刷新
class RefreshLocationCameraEvent extends LocationCameraEvent {
  final int skip;
  final int size;
  final String locationId;
  RefreshLocationCameraEvent({required this.skip, required this.size, required this.locationId});
}

// 更新下拉選單
class UpdateLocationCameraEvent extends LocationCameraEvent {
  UpdateLocationCameraEvent();
}

// 加載更多
class LoadMoreLocationCameraEvent extends LocationCameraEvent {
  final int skip;
  final int size;
  final String locationId;
  LoadMoreLocationCameraEvent({required this.skip, required this.size, required this.locationId});
}

// 新增/update
class CreateLocationCameraEvent extends LocationCameraEvent {
  String locationId;
  String cameraId;
  CreateLocationCameraEvent({required this.locationId, required this.cameraId});
}

// Socket更新
class UpdateLocationCameraStateEvent extends LocationCameraEvent {
    final String id;
  final String name;
  final String ip;
  final int port;
  final int state;
  final String protocol;
  final String web;
  final String urlPath;
  final String account;
  final String password;
  UpdateLocationCameraStateEvent({
    required this.id,
    required this.name,
    required this.ip,
    required this.port,
    required this.state,
    required this.protocol,
    required this.web,
    required this.urlPath,
    required this.account,
    required this.password,
  });
}

// 刪除
class DeleteLocationCameraEvent extends LocationCameraEvent {
  final String locationId;
  final String cameraId;
  DeleteLocationCameraEvent({required this.locationId, required this.cameraId});
}
