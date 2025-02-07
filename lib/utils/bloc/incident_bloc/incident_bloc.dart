import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/incident_service.dart';
import '../../view_model/incident_list.dart';

part 'incident_event.dart';
part 'incident_state.dart';

class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  factory IncidentBloc() {
    var state = IncidentInitialState();
    state.incidentMap = {};
    return IncidentBloc._(state);
  }

  // ignore: use_super_parameters
  IncidentBloc._(state) : super(state) {
    on<IncidentInitEvent>(_onIncidentInitEvent);
    on<IncidentLoadMoreEvent>(_onIncidentLoadMoreEvent);
    on<IncidentSearchLoadMoreEvent>(_onIncidentSearchLoadMoreEvent);
    on<CreateIncidentEvent>(_onCreateIncidentEvent);
    on<UpdateIncidentEvent>(_onUpdateIncidentEvent);
    on<IncidentSearchEvent>(_onIncidentSearchEvent);
  }

  @override
  void onEvent(IncidentEvent event) {
    // print('IncidentEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<IncidentState> change) {
    // print('IncidentState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  IncidentState emitState(IncidentState newState, IncidentState oldState) {
    newState.incidentMap = oldState.incidentMap;
    return newState;
  }

  // 初始化
  Future<void> _onIncidentInitEvent(IncidentInitEvent event, Emitter<IncidentState> emit) async {
    emit(emitState(IncidentLoadingState(), state));
    state.incidentMap.clear();
    final response = await IncidentService.getIncident(event.skip, event.size);
    // print('getIncident  response-----${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> incidentList = jsonDecode(response.body);
      if (incidentList.isEmpty) {
        state.incidentMap = {};
      } else {
        for (var incidentItem in incidentList) {
          Map<String, dynamic> incident = incidentItem['incident'];
          Map<String, dynamic> location = incidentItem['location'];
          Map<String, dynamic> camera = incidentItem['camera'];

          // print('incident----${incident['id']}----${incident['state']}----${incident['title']}----${location['name']}----${camera['name']}----${incident['createDatetime']}----${incident['time']}----${incident['isPinned']}----${camera['ip']}----${incident['videoUrl']}');

          state.incidentMap.update(
            incident['id'],
            (value) => IncidentListViewModel(
              id: incident['id'] ?? '',
              state: incident['state'] ?? 0,
              title: incident['title'] ?? '',
              locationName: location['name'] ?? '',
              cameraName: camera['name'] ?? '',
              createDatetime: incident['createDatetime'] ?? 0,
              time: incident['time'] ?? 0,
              isPinned: incident['isPinned'] ?? false,
              cameraId: camera['id'] ?? '',
              videoUrl: incident['videoUrl'] ?? '',
            ),
            ifAbsent: () => IncidentListViewModel(
              id: incident['id'] ?? '',
              state: incident['state'] ?? 0,
              title: incident['title'] ?? '',
              locationName: location['name'] ?? '',
              cameraName: camera['name'] ?? '',
              createDatetime: incident['createDatetime'] ?? 0,
              time: incident['time'] ?? 0,
              isPinned: incident['isPinned'] ?? false,
              cameraId: camera['id'] ?? '',
              videoUrl: incident['videoUrl'] ?? '',
            ),
          );
        }
      }
      emit(emitState(IncidentShowingState(), state));
    }
  }

  // 搜尋
  Future<void> _onIncidentSearchEvent(IncidentSearchEvent event, Emitter<IncidentState> emit) async {
    emit(emitState(IncidentLoadingState(), state));
    final response = await IncidentService.getIncidentSearch(
      event.skip,
      event.size,
      event.keyword,
      event.startDatetime,
      event.endDatetime,
      event.incidentState,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      state.incidentMap.clear();
      List<dynamic> incidentList = jsonDecode(response.body);
      print('IncidentSearchEvent getIncidentSearch  response-----${response.body}');
      for (var incidentItem in incidentList) {
        Map<String, dynamic> incident = incidentItem['incident'];
        Map<String, dynamic> location = incidentItem['location'];
        Map<String, dynamic> camera = incidentItem['camera'];

        // print('incident----${incident['id']}----${incident['state']}----${incident['title']}----${location['name']}----${camera['name']}----${incident['createDatetime']}----${incident['time']}----${incident['isPinned']}----${camera['ip']}----${incident['videoUrl']}');

        state.incidentMap.update(
          incident['id'],
          (value) => IncidentListViewModel(
            id: incident['id'] ?? '',
            state: incident['state'] ?? 0,
            title: incident['title'] ?? '',
            locationName: location['name'] ?? '',
            cameraName: camera['name'] ?? '',
            createDatetime: incident['createDatetime'] ?? 0,
            time: incident['time'] ?? 0,
            isPinned: incident['isPinned'] ?? false,
            cameraId: camera['id'] ?? '',
            videoUrl: incident['videoUrl'] ?? '',
          ),
          ifAbsent: () => IncidentListViewModel(
            id: incident['id'] ?? '',
            state: incident['state'] ?? 0,
            title: incident['title'] ?? '',
            locationName: location['name'] ?? '',
            cameraName: camera['name'] ?? '',
            createDatetime: incident['createDatetime'] ?? 0,
            time: incident['time'] ?? 0,
            isPinned: incident['isPinned'] ?? false,
            cameraId: camera['id'] ?? '',
            videoUrl: incident['videoUrl'] ?? '',
          ),
        );
      }
      if (incidentList.length < event.size) {
        // 讀取已達上限
        emit(emitState(IncidentReadMoreMaxState(), state));
      } else {
        // 未達上限
        emit(emitState(IncidentShowingState(), state));
      }
    } else {
      // 讀取失敗，都回到初始狀態
      emit(emitState(IncidentInitialState(), state));
    }
  }

  // 讀取更多
  Future<void> _onIncidentLoadMoreEvent(IncidentLoadMoreEvent event, Emitter<IncidentState> emit) async {
    emit(emitState(IncidentLoadingMoreState(), state));

    final response = await IncidentService.getIncident(event.skip, event.size);
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> incidentList = jsonDecode(response.body);
      // print('NotificationLoadingMoreState getNotifaiction  response-----${response.body}');
      for (var incidentItem in incidentList) {
        Map<String, dynamic> incident = incidentItem['incident'];
        Map<String, dynamic> location = incidentItem['location'];
        Map<String, dynamic> camera = incidentItem['camera'];

        // print('incident----${incident['id']}----${incident['state']}----${incident['title']}----${location['name']}----${camera['name']}----${incident['createDatetime']}----${incident['time']}----${incident['isPinned']}----${camera['ip']}----${incident['videoUrl']}');

        state.incidentMap.update(
          incident['id'],
          (value) => IncidentListViewModel(
            id: incident['id'] ?? '',
            state: incident['state'] ?? 0,
            title: incident['title'] ?? '',
            locationName: location['name'] ?? '',
            cameraName: camera['name'] ?? '',
            createDatetime: incident['createDatetime'] ?? 0,
            time: incident['time'] ?? 0,
            isPinned: incident['isPinned'] ?? false,
            cameraId: camera['id'] ?? '',
            videoUrl: incident['videoUrl'] ?? '',
          ),
          ifAbsent: () => IncidentListViewModel(
            id: incident['id'] ?? '',
            state: incident['state'] ?? 0,
            title: incident['title'] ?? '',
            locationName: location['name'] ?? '',
            cameraName: camera['name'] ?? '',
            createDatetime: incident['createDatetime'] ?? 0,
            time: incident['time'] ?? 0,
            isPinned: incident['isPinned'] ?? false,
            cameraId: camera['id'] ?? '',
            videoUrl: incident['videoUrl'] ?? '',
          ),
        );
      }
      if (incidentList.length < event.size) {
        // 讀取已達上限
        emit(emitState(IncidentReadMoreMaxState(), state));
      } else {
        // 未達上限
        emit(emitState(IncidentShowingState(), state));
      }
    } else {
      // 讀取失敗，都回到初始狀態
      emit(emitState(IncidentInitialState(), state));
    }
  }

  //搜尋讀取更多
  Future<void> _onIncidentSearchLoadMoreEvent(IncidentSearchLoadMoreEvent event, Emitter<IncidentState> emit) async {
    emit(emitState(IncidentLoadingMoreState(), state));

    final response = await IncidentService.getIncidentSearch(
      event.skip,
      event.size,
      event.keyword,
      event.startDatetime,
      event.endDatetime,
      event.incidentState,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> incidentList = jsonDecode(response.body);
      // print('NotificationLoadingMoreState getNotifaiction  response-----${response.body}');
      for (var incidentItem in incidentList) {
        Map<String, dynamic> incident = incidentItem['incident'];
        Map<String, dynamic> location = incidentItem['location'];
        Map<String, dynamic> camera = incidentItem['camera'];

        // print('incident----${incident['id']}----${incident['state']}----${incident['title']}----${location['name']}----${camera['name']}----${incident['createDatetime']}----${incident['time']}----${incident['isPinned']}----${camera['ip']}----${incident['videoUrl']}');

        state.incidentMap.update(
          incident['id'],
          (value) => IncidentListViewModel(
            id: incident['id'] ?? '',
            state: incident['state'] ?? 0,
            title: incident['title'] ?? '',
            locationName: location['name'] ?? '',
            cameraName: camera['name'] ?? '',
            createDatetime: incident['createDatetime'] ?? 0,
            time: incident['time'] ?? 0,
            isPinned: incident['isPinned'] ?? false,
            cameraId: camera['id'] ?? '',
            videoUrl: incident['videoUrl'] ?? '',
          ),
          ifAbsent: () => IncidentListViewModel(
            id: incident['id'] ?? '',
            state: incident['state'] ?? 0,
            title: incident['title'] ?? '',
            locationName: location['name'] ?? '',
            cameraName: camera['name'] ?? '',
            createDatetime: incident['createDatetime'] ?? 0,
            time: incident['time'] ?? 0,
            isPinned: incident['isPinned'] ?? false,
            cameraId: camera['id'] ?? '',
            videoUrl: incident['videoUrl'] ?? '',
          ),
        );
      }
      if (incidentList.length < event.size) {
        // 讀取已達上限
        emit(emitState(IncidentReadMoreMaxState(), state));
      } else {
        // 未達上限
        emit(emitState(IncidentShowingState(), state));
      }
    } else {
      // 讀取失敗，都回到初始狀態
      emit(emitState(IncidentInitialState(), state));
    }
  }

  // 新增
  Future<void> _onCreateIncidentEvent(CreateIncidentEvent event, Emitter<IncidentState> emit) async {
    emit(emitState(IncidentLoadingMoreState(), state));
    Map<String, IncidentListViewModel> newMap = {};
    newMap.update(event.incidentViewModel.id, (value) => event.incidentViewModel, ifAbsent: () => event.incidentViewModel);
    newMap.addAll(state.incidentMap);
    state.incidentMap = newMap;
    emit(emitState(IncidentShowingState(), state));
  }

  // 編輯最愛
  Future<void> _onUpdateIncidentEvent(UpdateIncidentEvent event, Emitter<IncidentState> emit) async {
    emit(emitState(IncidentEditingState(), state));
    try {
      final response = await IncidentService.updateIncidentFavorite(event.incidentId, event.state, event.isPinned);
      print('updateNotifaictionRead  response-----${response.body}');
      Map<String, dynamic> responseMap = jsonDecode(response.body);

      state.incidentMap.update(
        responseMap['id'],
        (value) => IncidentListViewModel(
          id: value.id,
          state: responseMap['state'],
          title: value.title,
          locationName: value.locationName,
          cameraName: value.cameraName,
          createDatetime: value.createDatetime,
          time: value.time,
          isPinned: responseMap['isPinned'],
          cameraId: value.cameraId,
          videoUrl: value.videoUrl,
        ),
      );

      if (responseMap['isPinned'] == true && event.isEdit == false) {
        add(IncidentInitEvent(skip: 0, size: 20));
      } else {
        emit(emitState(IncidentShowingState(), state));
      }
    } catch (e) {
      emit(emitState(IncidentErrorState(), state));
    }
  }
}
