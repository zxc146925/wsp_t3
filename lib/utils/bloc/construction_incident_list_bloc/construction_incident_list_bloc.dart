import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/location_service.dart';
import '../../view_model/location_incident_list.dart';

part 'construction_incident_list_event.dart';
part 'construction_incident_list_state.dart';

class ConstructionIncidentListBloc extends Bloc<ConstructionIncidentListEvent, ConstructionIncidentListState> {
  factory ConstructionIncidentListBloc() {
    var state = ConstructionIncidentListInitialState();
    state.locationIncidentMap = {};
    return ConstructionIncidentListBloc._(state);
  }

  ConstructionIncidentListBloc._(state) : super(state) {
    on<ConstructionIncidentListInitEvent>(_onConstructionIncidentListInitEvent);
    on<ConstructionIncidentListLoadMoreEvent>(_onConstructionIncidentListLoadMoreEvent);
  }

  @override
  void onEvent(ConstructionIncidentListEvent event) {
    print('ConstructionIncidentListEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<ConstructionIncidentListState> change) {
    print('ConstructionIncidentListState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  ConstructionIncidentListState emitState(ConstructionIncidentListState newState, ConstructionIncidentListState oldState) {
    newState.locationIncidentMap = oldState.locationIncidentMap;
    return newState;
  }

  // 初始化
  Future<void> _onConstructionIncidentListInitEvent(ConstructionIncidentListInitEvent event, Emitter<ConstructionIncidentListState> emit) async {
    emit(emitState(ConstructionIncidentListLoadingState(), state));
    final response = await LocationService.getLocationIncidentList(event.skip, event.size, event.locationId);
    // print('getLocationIncidentList  response-----${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> locationIncidentList = jsonDecode(response.body);
      if (locationIncidentList.isEmpty) {
        state.locationIncidentMap = {};
      } else {
        for (var locationIncidentItem in locationIncidentList) {
          state.locationIncidentMap.update(
            locationIncidentItem['id'],
            (value) => LocationIncidentListViewModel.fromJson(locationIncidentItem),
            ifAbsent: () => LocationIncidentListViewModel.fromJson(locationIncidentItem),
          );
        }
      }
      emit(emitState(ConstructionIncidentListShowState(), state));
    }
  }

  // 讀取更多
  Future<void> _onConstructionIncidentListLoadMoreEvent(ConstructionIncidentListLoadMoreEvent event, Emitter<ConstructionIncidentListState> emit) async {
    emit(emitState(ConstructionIncidentListLoadMoreState(), state));
    final response = await LocationService.getLocationIncidentList(event.skip, event.size, event.locationId);
    print('getLocationIncidentList  response-----${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> locationIncidentList = jsonDecode(response.body);
      if (locationIncidentList.isEmpty) {
        // 讀取已達上限
        for (var locationIncidentItem in locationIncidentList) {
          state.locationIncidentMap.update(
            locationIncidentItem['id'],
            (value) => LocationIncidentListViewModel.fromJson(locationIncidentItem),
            ifAbsent: () => LocationIncidentListViewModel.fromJson(locationIncidentItem),
          );
        }
        emit(emitState(ConstructionIncidentListReadMaxState(), state));
      } else {
        for (var locationIncidentItem in locationIncidentList) {
          state.locationIncidentMap.update(
            locationIncidentItem['id'],
            (value) => LocationIncidentListViewModel.fromJson(locationIncidentItem),
            ifAbsent: () => LocationIncidentListViewModel.fromJson(locationIncidentItem),
          );
        }
        emit(emitState(ConstructionIncidentListShowState(), state));
      }
    } else {
      // 讀取失敗，都回到初始狀態
      emit(emitState(ConstructionIncidentListErrorState(), state));
    }
  }
}
