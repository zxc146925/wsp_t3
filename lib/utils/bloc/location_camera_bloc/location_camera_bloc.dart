import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../api/camera_service.dart';
import '../../api/location_service.dart';
import '../../entity/camera.dart';

part 'location_camera_event.dart';
part 'location_camera_state.dart';

class LocationCameraBloc extends Bloc<LocationCameraEvent, LocationCameraState> {
  factory LocationCameraBloc() {
    var state = LocationCameraInitial();
    state.cameraMap = {};
    state.unSelectedCameraMap = {};
    return LocationCameraBloc._(state);
  }

  LocationCameraBloc._(state) : super(state) {
    on<RefreshLocationCameraEvent>(_onRefreshLocationCameraEvent);
    on<LoadMoreLocationCameraEvent>(_onLoadMoreLocationCameraEvent);
    on<UpdateLocationCameraStateEvent>(_onUpdateLocationCameraStateEvent);
    on<CreateLocationCameraEvent>(_onCreateLocationCameraEvent);
    on<DeleteLocationCameraEvent>(_onDeleteLocationCameraEvent);
  }

  @override
  void onEvent(LocationCameraEvent event) {
    // print('LocationCameraEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<LocationCameraState> change) {
    // print('LocationCameraState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  LocationCameraState emitState(LocationCameraState newState, LocationCameraState oldState) {
    newState.cameraMap = oldState.cameraMap;
    newState.unSelectedCameraMap = oldState.unSelectedCameraMap;
    newState.selectCameraStream = oldState.selectCameraStream;
    return newState;
  }

  // 刷新
  Future<void> _onRefreshLocationCameraEvent(RefreshLocationCameraEvent event, Emitter<LocationCameraState> emit) async {
    try {
      emit(emitState(LocationCameraLoadingState(), state));

      final response = await CameraService.getLocationCamera(event.skip, event.size, event.locationId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> locationCameraList = jsonDecode(response.body);
        if (locationCameraList.isEmpty) {
          state.cameraMap = {};
        } else {
          for (var locationCameraItem in locationCameraList) {
            print('取得案場攝影機列表----locationCameraItem: ${locationCameraItem.toString()}');
            state.cameraMap.update(
              locationCameraItem['id'],
              (value) => CameraEntity.fromJson(locationCameraItem),
              ifAbsent: () => CameraEntity.fromJson(locationCameraItem),
            );
          }
        }

        state.unSelectedCameraMap.clear();

        final responseSelect = await CameraService.getCameraIdle(0, 99);
        if (responseSelect.statusCode == 200 || responseSelect.statusCode == 201) {
          List<dynamic> selectCameraList = jsonDecode(responseSelect.body);
          if (selectCameraList.isNotEmpty) {
            for (var selectCameraItem in selectCameraList) {
              print('拉取可選擇的攝影機：selectCameraItem: ${selectCameraItem.toString()}');
              state.unSelectedCameraMap.update(
                selectCameraItem['id'],
                (value) => CameraEntity.fromJson(selectCameraItem),
                ifAbsent: () => CameraEntity.fromJson(selectCameraItem),
              );
            }
            state.selectCameraStream.add(state.unSelectedCameraMap.values.first);
          }
        }

        emit(emitState(LocationCameraInitialCompleteState(), state));
      } else {
        emit(emitState(LocationCameraErrorState(), state));
      }
    } catch (e) {
      print('RefreshLocationCameraEvent erro--$e');
    }
  }

  Future<void> _onUpdateLocationCameraStateEvent(UpdateLocationCameraStateEvent event, Emitter<LocationCameraState> emit) async {
    emit(emitState(LocationCameraLoadingState(), state));
    if (state.cameraMap.containsKey(event.id)) {
      state.cameraMap.update(
        event.id,
        (value) => CameraEntity(
          id: event.id,
          name: event.name,
          ip: event.ip,
          port: event.port,
          protocol: event.protocol,
          web: event.web,
          urlPath: event.urlPath,
          state: event.state,
          account: event.account,
          password: event.password,
          startDatetime: value.startDatetime,
        ),
      );
    }
    emit(emitState(LocationCameraShowingState(), state));
  }

  // 加載更多
  Future<void> _onLoadMoreLocationCameraEvent(LoadMoreLocationCameraEvent event, Emitter<LocationCameraState> emit) async {
    try {
      emit(emitState(LocationCameraLoadingMoreState(), state));
      final response = await CameraService.getLocationCamera(event.skip, event.size, event.locationId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> locationCameraList = jsonDecode(response.body);
        if (locationCameraList.isEmpty || locationCameraList.length < event.size) {
          for (var locationCameraItem in locationCameraList) {
            state.cameraMap.update(locationCameraItem['id'], (value) => CameraEntity.fromJson(locationCameraItem), ifAbsent: () => CameraEntity.fromJson(locationCameraItem));
          }
          // 讀取已達上限
          emit(emitState(LocationCameraReadMoreMaxState(), state));
        } else {
          for (var locationCameraItem in locationCameraList) {
            state.cameraMap.update(locationCameraItem['id'], (value) => CameraEntity.fromJson(locationCameraItem), ifAbsent: () => CameraEntity.fromJson(locationCameraItem));
          }
        }
        emit(emitState(LocationCameraShowingState(), state));
      }
    } catch (e) {
      print('LoadMoreLocationCameraEvent error--$e');
    }
  }

  // 新增案場攝影機
  Future<void> _onCreateLocationCameraEvent(CreateLocationCameraEvent event, Emitter<LocationCameraState> emit) async {
    emit(emitState(LocationCameraAddingState(), state));
    try {
      final response = await LocationService.createLocationCamera(event.locationId, event.cameraId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> locationCamera = jsonDecode(response.body);
        state.cameraMap.update(
          locationCamera['id'],
          (value) => CameraEntity.fromJson(locationCamera),
          ifAbsent: () => CameraEntity.fromJson(locationCamera),
        );
        emit(emitState(LocationCameraShowingState(), state));
      }

      state.unSelectedCameraMap.clear();
      final responseSelect = await CameraService.getCameraIdle(0, 99);
      if (responseSelect.statusCode == 200 || responseSelect.statusCode == 201) {
        List<dynamic> selectCameraList = jsonDecode(responseSelect.body);
        if (selectCameraList.isNotEmpty) {
          for (var selectCameraItem in selectCameraList) {
            print('拉取可選擇的攝影機：selectCameraItem: ${selectCameraItem.toString()}');
            state.unSelectedCameraMap.update(
              selectCameraItem['id'],
              (value) => CameraEntity.fromJson(selectCameraItem),
              ifAbsent: () => CameraEntity.fromJson(selectCameraItem),
            );
          }
          state.selectCameraStream.add(state.unSelectedCameraMap.values.first);
        }
      }
    } catch (e) {
      emit(emitState(LocationCameraErrorState(), state));
      print('CreateLocationCameraEvent error--$e');
    }
  }

  // 刪除案場攝影機
  Future<void> _onDeleteLocationCameraEvent(DeleteLocationCameraEvent event, Emitter<LocationCameraState> emit) async {
    emit(emitState(LocationCameraRemovingState(), state));
    try {
      final response = await LocationService.deleteLocationCamera(event.locationId, event.cameraId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> locationCamera = jsonDecode(response.body);
        state.cameraMap.remove(locationCamera['id']);
      }

      state.unSelectedCameraMap.clear();

      final responseSelect = await CameraService.getCameraIdle(0, 99);
      if (responseSelect.statusCode == 200 || responseSelect.statusCode == 201) {
        List<dynamic> selectCameraList = jsonDecode(responseSelect.body);
        if (selectCameraList.isNotEmpty) {
          for (var selectCameraItem in selectCameraList) {
            print('拉取可選擇的攝影機：selectCameraItem: ${selectCameraItem.toString()}');
            state.unSelectedCameraMap.update(
              selectCameraItem['id'],
              (value) => CameraEntity.fromJson(selectCameraItem),
              ifAbsent: () => CameraEntity.fromJson(selectCameraItem),
            );
          }
          state.selectCameraStream.add(state.unSelectedCameraMap.values.first);
        }
      }

      emit(emitState(LocationCameraShowingState(), state));
    } catch (e) {
      emit(emitState(LocationCameraErrorState(), state));
      print('DeleteLocationCameraEvent error--$e');
    }
  }
}
