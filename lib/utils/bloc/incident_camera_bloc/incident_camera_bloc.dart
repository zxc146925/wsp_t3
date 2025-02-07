import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wsp_t3/utils/api/incident_service.dart';

import '../../entity/incident.dart';

part 'incident_camera_event.dart';
part 'incident_camera_state.dart';

// 影像管理-影像紀錄-異常事件
class IncidentCameraBloc extends Bloc<IncidentCameraEvent, IncidentCameraState> {
  factory IncidentCameraBloc() {
    var state = IncidentCameraInitial();
    state.incidentCameraMap = {};
    return IncidentCameraBloc._(state);
  }

  IncidentCameraBloc._(state) : super(state) {
    on<IncidentCameraInitialEvent>(_onIncidentCameraInitialEvent);
    on<IncidentCameraLoadMoreEvent>(_onIncidentCameraLoadMoreEvent);
    on<IncidentCameraSearchEvent>(_onIncidentCameraSearchEvent);
    on<UpdateIncidentCameraEvent>(_onUpdateIncidentCameraEvent);
  }

  @override
  void onEvent(IncidentCameraEvent event) {
    // print('IncidentCameraEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<IncidentCameraState> change) {
    // print('IncidentCameraState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  IncidentCameraState emitState(IncidentCameraState newState, IncidentCameraState oldState) {
    newState.incidentCameraMap = oldState.incidentCameraMap;
    newState.cameraId = oldState.cameraId;
    newState.startDatetime = oldState.startDatetime;
    newState.endDatetime = oldState.endDatetime;
    return newState;
  }

  //初始
  Future<void> _onIncidentCameraInitialEvent(IncidentCameraInitialEvent event, Emitter<IncidentCameraState> emit) async {
    emit(emitState(IncidentCameraLoading(), state));
    state.incidentCameraMap.clear();
    try {
      state.cameraId = event.cameraId;
      state.startDatetime = event.startDatetime;
      state.endDatetime = event.endDatetime;
      final response = await IncidentService.getIncidentCamera(event.skip, event.size, event.cameraId, event.startDatetime, event.endDatetime);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> incidentCameraList = jsonDecode(response.body);
        if (incidentCameraList.isEmpty) {
          state.incidentCameraMap = {};
        } else {
          for (var incidentCameraItem in incidentCameraList) {
            // print('incidentCameraItem----${incidentCameraItem.toString()}');
            state.incidentCameraMap.update(
              incidentCameraItem['id'],
              (value) => IncidentEntity.fromJson(incidentCameraItem),
              ifAbsent: () => IncidentEntity.fromJson(incidentCameraItem),
            );
          }
        }
        emit(emitState(IncidentCameraShowing(), state));
      }
    } catch (e) {
      emit(emitState(IncidentCameraError(), state));
    }
  }

  // 更新異常狀態
  Future<void> _onUpdateIncidentCameraEvent(UpdateIncidentCameraEvent event, Emitter<IncidentCameraState> emit) async {
    emit(emitState(IncidentCameraEditingState(), state));
    try {
      final response = await IncidentService.updateIncidentFavorite(event.incidentId, event.state, event.isPinned);
      print('updateNotifaictionRead  response-----${response.body}');
      Map<String, dynamic> responseMap = jsonDecode(response.body);

      state.incidentCameraMap.update(
        responseMap['id'],
        (value) => IncidentEntity(
          id: value.id,
          title: value.title,
          updateDatetime: value.updateDatetime,
          imageUrl: value.imageUrl,
          videoUrl: value.videoUrl,
          createDatetime: value.createDatetime,
          isPinned: responseMap['isPinned'],
          state: responseMap['state'],
          type: value.type,
          startDatetime: value.startDatetime,
        ),
      );

      emit(emitState(IncidentCameraShowing(), state));
    } catch (e) {
      emit(emitState(IncidentCameraError(), state));
    }
  }

  // 加載更多
  Future<void> _onIncidentCameraLoadMoreEvent(IncidentCameraLoadMoreEvent event, Emitter<IncidentCameraState> emit) async {
    emit(emitState(IncidentCameraLoadingMore(), state));
    try {
      final response = await IncidentService.getIncidentCamera(event.skip, event.size, state.cameraId!, state.startDatetime!, state.endDatetime!);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> incidentCameraList = jsonDecode(response.body);
        for (var incidentCameraItem in incidentCameraList) {
          state.incidentCameraMap.update(
            incidentCameraItem['id'],
            (value) => IncidentEntity.fromJson(incidentCameraItem),
            ifAbsent: () => IncidentEntity.fromJson(incidentCameraItem),
          );
        }

        if (incidentCameraList.length < event.size) {
          // 讀取已達上限
          emit(emitState(IncidentCameraReadMoreMaxState(), state));
        } else {
          // 未達上限
          emit(emitState(IncidentCameraShowing(), state));
        }
      } else {
        emit(emitState(IncidentCameraError(), state));
      }
    } catch (e) {
      emit(emitState(IncidentCameraError(), state));
    }
  }

  // 搜尋
  Future<void> _onIncidentCameraSearchEvent(IncidentCameraSearchEvent event, Emitter<IncidentCameraState> emit) async {
    emit(emitState(IncidentCameraLoading(), state));
    try {
      final response = await IncidentService.getIncidentCameraSearch(
        event.skip,
        event.size,
        state.cameraId!,
        state.startDatetime!,
        state.endDatetime!,
        event.incidentState,
        event.keyword,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> incidentCameraList = jsonDecode(response.body);
        if (incidentCameraList.isEmpty) {
          state.incidentCameraMap = {};
        } else {
          state.incidentCameraMap.clear();
          for (var incidentCameraItem in incidentCameraList) {
            print('異常搜尋列表----${incidentCameraItem.toString()}');
            state.incidentCameraMap.update(
              incidentCameraItem['id'],
              (value) => IncidentEntity.fromJson(incidentCameraItem),
              ifAbsent: () => IncidentEntity.fromJson(incidentCameraItem),
            );
          }
        }
        print('搜尋後的結果長度----${state.incidentCameraMap.length}');
        emit(emitState(IncidentCameraShowing(), state));
      }
    } catch (e) {
      emit(emitState(IncidentCameraError(), state));
    }
  }
}
