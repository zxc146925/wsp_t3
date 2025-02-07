import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/camera_service.dart';
import '../../view_model/camera_list_statistic.dart';

part 'camera_list_statistic_event.dart';
part 'camera_list_statistic_state.dart';

// 給影像管理-影像紀錄中間區塊
class CameraListStatisticBloc extends Bloc<CameraListStatisticEvent, CameraListStatisticState> {
  factory CameraListStatisticBloc() {
    var state = CameraListStatisticInitial();
    state.cameraListStatisticViewModelList = [];
    state.cameraId = '';
    state.cameraName = '';
    return CameraListStatisticBloc._(state);
  }

  CameraListStatisticBloc._(state) : super(state) {
    on<CameraListStatisticInitEvent>(_onCameraListStatisticInitEvent);
    on<CameraListStatisticLoadMoreEvent>(_onCameraListStatisticLoadMoreEvent);
    on<CameraListStatisticSearchEvent>(_onCameraListStatisticSearchEvent);
  }

  @override
  void onEvent(CameraListStatisticEvent event) {
    // print('CameraListStatisticEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<CameraListStatisticState> change) {
    // print('CameraListStatisticState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  CameraListStatisticState emitState(CameraListStatisticState newState, CameraListStatisticState oldState) {
    newState.cameraListStatisticViewModelList = oldState.cameraListStatisticViewModelList;
    newState.cameraId = oldState.cameraId;
    newState.cameraName = oldState.cameraName;
    return newState;
  }

  //初始
  Future<void> _onCameraListStatisticInitEvent(CameraListStatisticInitEvent event, Emitter<CameraListStatisticState> emit) async {
    emit(emitState(CameraListStatisticLoading(), state));
    state.cameraListStatisticViewModelList.clear();
    state.cameraId = event.cameraId;
    state.cameraName = event.cameraName;
    print('CameraListStatisticInitEvent 初始-----${event.skip}--${event.size}--------${event.cameraId}');
    try {
      final response = await CameraService.getCameraListStatistic(event.skip, event.size, event.cameraId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> cameraListStatisticViewModelList = jsonDecode(response.body);
        if (cameraListStatisticViewModelList.isEmpty) {
          state.cameraListStatisticViewModelList = [];
          emit(emitState(CameraListStatisticInitialComplete(), state));
        } else {
          for (var cameraListStatisticViewModelItem in cameraListStatisticViewModelList) {
            // print('影像紀錄中間區塊初始：影像日期：${PublicData.getDateForm(cameraListStatisticViewModelItem['date'])}---攝影機名稱：${event.cameraName}--異常數量：${cameraListStatisticViewModelItem['incidentCount']}--影像數量：${cameraListStatisticViewModelItem['recordCount']}');
            state.cameraListStatisticViewModelList.add(
              CameraListStatisticViewModel(
                cameraId: event.cameraId,
                cameraName: event.cameraName,
                date: cameraListStatisticViewModelItem['date'],
                incidentCount: cameraListStatisticViewModelItem['incidentCount'],
                recordCount: cameraListStatisticViewModelItem['recordCount'],
              ),
            );
          }
          emit(emitState(CameraListStatisticInitialComplete(), state));
        }
        
      } else {
        emit(emitState(CameraListStatisticError(), state));
      }
    } catch (e) {
      print('CameraListStatisticEvent error--$e');
      emit(emitState(CameraListStatisticError(), state));
    }
  }

  // 加載更多
  Future<void> _onCameraListStatisticLoadMoreEvent(CameraListStatisticLoadMoreEvent event, Emitter<CameraListStatisticState> emit) async {
    emit(emitState(CameraListStatisticLoadingMore(), state));
    try {
      // print('CameraListStatisticLoadMoreEvent 加載更多-----${event.skip}--${event.size}--------${event.cameraId}');
      final response = await CameraService.getCameraListStatistic(event.skip, event.size, event.cameraId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> cameraListStatisticViewModelList = jsonDecode(response.body);
        for (var cameraListStatisticViewModelItem in cameraListStatisticViewModelList) {
          // print('cameraListStatisticViewModelItem----${cameraListStatisticViewModelItem.toString()}');
          state.cameraListStatisticViewModelList.add(CameraListStatisticViewModel(
            cameraId: state.cameraListStatisticViewModelList.first.cameraId,
            cameraName: state.cameraListStatisticViewModelList.first.cameraName,
            date: cameraListStatisticViewModelItem['date'],
            incidentCount: cameraListStatisticViewModelItem['incidentCount'],
            recordCount: cameraListStatisticViewModelItem['recordCount'],
          ));
        }
        if (cameraListStatisticViewModelList.length < event.size) {
          // 表示拉到最大
          print('拉到最大-------------${state.cameraListStatisticViewModelList.length}');
          emit(emitState(CameraListStatisticReadMax(), state));
        } else {
          print('繼續顯示-------------${state.cameraListStatisticViewModelList.length}');
          emit(emitState(CameraListStatisticShowing(), state));
        }
      }
    } catch (e) {
      print('CameraListStatisticEvent error--$e');
      emit(emitState(CameraListStatisticError(), state));
    }
  }

  // 搜尋
  Future<void> _onCameraListStatisticSearchEvent(CameraListStatisticSearchEvent event, Emitter<CameraListStatisticState> emit) async {
    try {
      emit(emitState(CameraListStatisticLoading(), state));
      final response = await CameraService.getCameraListStatisticSearch(skip: event.skip, size: event.size, cameraId: state.cameraId, startDatetime: event.startDatetime, endDatetime: event.endDatetime);
      print('response--------------${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> cameraListStatisticViewList = jsonDecode(response.body);
        print('cameraListStatisticViewList------------${cameraListStatisticViewList.length}');
        if (cameraListStatisticViewList.isEmpty) {
          // 表示搜尋不到結果
          state.cameraListStatisticViewModelList.clear();
        } else {
          // 表示搜尋到結果
          state.cameraListStatisticViewModelList.clear();
          for (var item in cameraListStatisticViewList) {
            print('cameraListStatisticViewList----${item.toString()}');
            state.cameraListStatisticViewModelList.add(
              CameraListStatisticViewModel(
                cameraId: state.cameraId,
                cameraName: state.cameraName,
                date: item['date'],
                incidentCount: item['incidentCount'],
                recordCount: item['recordCount'],
              ),
            );
          }
        }
        emit(emitState(CameraListStatisticInitialComplete(), state));
      }
    } catch (e) {
      print('CameraListStatisticEvent error--$e');
      emit(emitState(CameraListStatisticError(), state));
    }
  }
}
