import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/location_service.dart';
import '../../entity/engineering.dart';
import '../../entity/location.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  factory LocationBloc() {
    var state = LocationInitial();
    state.locationMap = {};
    state.engineeringEntity = null;
    state.locationEntityItem = null;
    return LocationBloc._(state);
  }

  LocationBloc._(state) : super(state) {
    on<RefreshLocationEvent>(_onRefreshLocationEvent);
    on<LoadMoreLocationEvent>(_onLoadMoreLocationEvent);
    on<CreateLocationEvent>(_onCreateLocationEvent);
    on<UpdateLocationEvent>(_onUpdateLocationEvent);
  }

  @override
  void onEvent(LocationEvent event) {
    // print('LocationEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<LocationState> change) {
    // print('LocationState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  LocationState emitState(LocationState newState, LocationState oldState) {
    newState.locationMap = oldState.locationMap;
    newState.engineeringEntity = oldState.engineeringEntity;
    newState.locationEntityItem = oldState.locationEntityItem;
    return newState;
  }

  // 加載更多
  Future<void> _onLoadMoreLocationEvent(LoadMoreLocationEvent event, Emitter<LocationState> emit) async {}

  // 新增
  Future<void> _onCreateLocationEvent(CreateLocationEvent event, Emitter<LocationState> emit) async {
    emit(emitState(LocationAddingState(), state));
    try {
      final response = await LocationService.createLocation(event.engineeringId, event.name, event.manager, event.phone, event.state, event.description, event.startDatetime, event.endDatetime);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> location = jsonDecode(response.body);
        Map<String, LocationEntity> newMap = {};
        print('新增成功-----${location.toString()}');
        newMap.update(
          location['id'],
          (value) => LocationEntity.fromJson(location),
          ifAbsent: () => LocationEntity.fromJson(location),
        );
        newMap.addAll(state.locationMap);
        state.locationMap = newMap;
        state.locationEntityItem = LocationEntity.fromJson(location);
        emit(emitState(LocationShowingState(), state));
      }
    } catch (e) {
      print('UpdateLocationEvent erro--$e');
      emit(emitState(LocationEditErrorState(), state));
    }
  }

  // 刷新
  Future<void> _onRefreshLocationEvent(RefreshLocationEvent event, Emitter<LocationState> emit) async {
    try {
      emit(emitState(LocationLoadingState(), state));
      final response = await LocationService.getLocation(event.skip, event.size, event.engineering.id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> locationList = jsonDecode(response.body);
        if (locationList.isEmpty) {
          state.locationMap = {};
        } else {
          for (var locationItem in locationList) {
            state.locationMap.update(locationItem['id'], (value) => LocationEntity.fromJson(locationItem), ifAbsent: () => LocationEntity.fromJson(locationItem));
          }
        }
        state.engineeringEntity = event.engineering;
        emit(emitState(LocationShowingState(), state));
      } else {
        emit(emitState(LocationErrorState(), state));
      }
    } catch (e) {
      print('RefreshLocationEvent erro--$e');
    }
  }

  // 編輯案場
  Future<void> _onUpdateLocationEvent(UpdateLocationEvent event, Emitter<LocationState> emit) async {
    emit(emitState(LocationEditingState(), state));
    try {
      final response = await LocationService.updateLocation(event.id, event.name, event.manager, event.phone, event.state, event.startDatetime, event.endDatetime, event.description);
      print('updateLocation  response-----${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> location = jsonDecode(response.body);
        state.locationMap.update(
          location['id'],
          (value) => LocationEntity.fromJson(location),
        );
        state.locationEntityItem = LocationEntity.fromJson(location);
        emit(emitState(LocationShowingState(), state));
      }
    } catch (e) {
      print('UpdateLocationEvent erro--$e');
      emit(emitState(LocationEditErrorState(), state));
    }
  }
}
