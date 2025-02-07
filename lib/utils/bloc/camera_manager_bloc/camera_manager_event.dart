part of 'camera_manager_bloc.dart';

@immutable
sealed class CameraManagerEvent {}

// 初始
class CameraManagerInitialEvent extends CameraManagerEvent {
  final int skip;
  final int size;
  CameraManagerInitialEvent({required this.skip, required this.size});
}

// 加載更多
class CameraManagerLoadMoreEvent extends CameraManagerEvent {}

// 新增
class CameraManagerCreateEvent extends CameraManagerEvent {}

// 更新攝影機
class CameraManagerSocketUpdateEvent extends CameraManagerEvent {
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
  CameraManagerSocketUpdateEvent({
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

// 編輯
class CameraManagerUpdateEvent extends CameraManagerEvent {
  final String id;
  final String name;
  final String ip;
  final int port;
  final String protocol;
  final String web;
  final String urlPath;
  final String account;
  final String password;
  CameraManagerUpdateEvent({required this.id, required this.name, required this.ip, required this.port, required this.protocol, required this.web, required this.urlPath, required this.account, required this.password});
}
