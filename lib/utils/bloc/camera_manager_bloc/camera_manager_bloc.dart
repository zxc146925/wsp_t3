import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../api/camera_service.dart';
import '../../entity/camera_manager.dart';

part 'camera_manager_event.dart';
part 'camera_manager_state.dart';

class CameraManagerBloc extends Bloc<CameraManagerEvent, CameraManagerState> {
  factory CameraManagerBloc() {
    var state = CameraManagerInitialState();
    state.cameraManagerMap = {};
    state.cameraIdStream = BehaviorSubject<String>.seeded('');
    return CameraManagerBloc._(state);
  }

  CameraManagerBloc._(state) : super(state) {
    on<CameraManagerInitialEvent>(_onCameraManagerInitialEvent);
    on<CameraManagerLoadMoreEvent>(_onCameraManagerLoadMoreEvent);
    on<CameraManagerCreateEvent>(_onCameraManagerCreateEvent);
    on<CameraManagerSocketUpdateEvent>(_onCameraManagerSocketUpdateEvent);
    on<CameraManagerUpdateEvent>(_onCameraManagerUpdateEvent);
  }

  @override
  void onEvent(CameraManagerEvent event) {
    // print('CameraManagerEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<CameraManagerState> change) {
    // print('CameraManagerState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  CameraManagerState emitState(CameraManagerState newState, CameraManagerState oldState) {
    newState.cameraManagerMap = oldState.cameraManagerMap;
    return newState;
  }

  //初始
  Future<void> _onCameraManagerInitialEvent(CameraManagerInitialEvent event, Emitter<CameraManagerState> emit) async {
    emit(emitState(CameraManagerLoadingState(), state));
    try {
      final response = await CameraService.getCameraList(event.skip, event.size);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> cameraManager = jsonDecode(response.body);
        if (cameraManager.isEmpty) {
          state.cameraManagerMap = {};
        } else {
          for (var cameraItem in cameraManager) {
            Map<String, dynamic> camera = cameraItem['camera'];
            Map<String, dynamic> location = cameraItem['location'] ?? {};

            print('id---------------${camera['id']}---${camera['name']}---${location['name']}---${camera['ip']}---${camera['port']}---${camera['protocol']}---${camera['web']}---${camera['urlPath']}---${camera['createDatetime']}');

            state.cameraManagerMap.update(
              camera['id'],
              (value) => CameraManagerEntity(
                id: camera['id'],
                cameraName: camera['name'],
                locationName: location['name'] ?? '-',
                ip: camera['ip'],
                port: camera['port'],
                protocol: camera['protocol'],
                web: camera['web'],
                urlPath: camera['urlPath'],
                createDatetime: camera['createDatetime'],
                state: camera['state'],
                account: camera['account'],
                password: camera['password'],
              ),
              ifAbsent: () => CameraManagerEntity(
                id: camera['id'],
                cameraName: camera['name'],
                locationName: location['name'] ?? '-',
                ip: camera['ip'],
                port: camera['port'],
                protocol: camera['protocol'],
                web: camera['web'],
                urlPath: camera['urlPath'],
                createDatetime: camera['createDatetime'],
                state: camera['state'],
                account: camera['account'],
                password: camera['password'],
              ),
            );
          }
        }
        emit(emitState(CameraManagerInitialCompleteState(), state));
      } else {
        emit(emitState(CameraManagerErrorState(), state));
      }
    } catch (e) {
      print('CameraManagerRefreshEvent erro--$e');
    }
  }

  //編輯
  Future<void> _onCameraManagerUpdateEvent(CameraManagerUpdateEvent event, Emitter<CameraManagerState> emit) async {
    emit(emitState(CameraManagerEditingState(), state));
    try {
      final response = await CameraService.updateCamera(event.id, event.name, event.ip, event.port, event.protocol, event.web, event.urlPath, event.account, event.password);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> cameraManager = jsonDecode(response.body);

        state.cameraManagerMap.update(
          cameraManager['id'],
          (value) => CameraManagerEntity(
            id: value.id,
            cameraName: cameraManager['name'],
            locationName: value.locationName,
            ip: cameraManager['ip'],
            port: cameraManager['port'],
            protocol: cameraManager['protocol'],
            web: cameraManager['web'],
            urlPath: cameraManager['urlPath'],
            createDatetime: value.createDatetime,
            state: cameraManager['state'],
            account: cameraManager['account'],
            password: cameraManager['password'],
          ),
        );
        emit(emitState(CameraManagerShowingState(), state));
      } else {
        print('CameraManagerUpdateEvent error--${response.statusCode}');
        emit(emitState(CameraManagerEditErrorState(), state));
      }
    } catch (e) {
      print('CameraManagerUpdateEvent erro--$e');
      emit(emitState(CameraManagerEditErrorState(), state));
    }
  }

  //Socket更新
  Future<void> _onCameraManagerSocketUpdateEvent(CameraManagerSocketUpdateEvent event, Emitter<CameraManagerState> emit) async {
    // emit(emitState(CameraManagerLoadingState(), state));
    print('Socket更新----id:${event.id}---cameraName:${event.name}----ip:${event.ip}---state:${event.state}');

    try {
      state.cameraManagerMap.update(
        event.id,
        (value) => CameraManagerEntity(
          id: event.id,
          cameraName: event.name,
          locationName: value.locationName,
          ip: event.ip,
          port: event.port,
          protocol: event.protocol,
          web: event.web,
          urlPath: event.urlPath,
          createDatetime: value.createDatetime,
          state: event.state,
          account: event.account,
          password: event.password,
        ),
      );

      emit(emitState(CameraManagerShowingState(), state));
    } catch (e) {
      print('CameraManagerUpdateEvent erro--$e');
      emit(emitState(CameraManagerEditErrorState(), state));
    }
  }

  // 加載更多
  Future<void> _onCameraManagerLoadMoreEvent(CameraManagerLoadMoreEvent event, Emitter<CameraManagerState> emit) async {}

  // 新增
  Future<void> _onCameraManagerCreateEvent(CameraManagerCreateEvent event, Emitter<CameraManagerState> emit) async {}
}
