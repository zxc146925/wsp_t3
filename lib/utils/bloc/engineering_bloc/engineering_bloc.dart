import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/engineering_service.dart';
import '../../entity/engineering.dart';

part 'engineering_event.dart';
part 'engineering_state.dart';

class EngineeringBloc extends Bloc<EngineeringEvent, EngineeringState> {
  factory EngineeringBloc() {
    var state = EngineeringInitial();
    state.engineeringMap = {};
    return EngineeringBloc._(state);
  }

  EngineeringBloc._(state) : super(state) {
    on<RefreshEngineeringEvent>(_onRefreshEngineeringEvent);
    on<LoadMoreEngineeringEvent>(_onLoadMoreEngineeringEvent);
    on<CreateEngineeringEvent>(_onCreateEngineeringEvent);
    on<UpdateEngineeringEvent>(_onUpdateEngineeringEvent);
  }

  @override
  void onEvent(EngineeringEvent event) {
    // print('EngineeringEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<EngineeringState> change) {
    // print('EngineeringState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  EngineeringState emitState(EngineeringState newState, EngineeringState oldState) {
    newState.engineeringMap = oldState.engineeringMap;
    return newState;
  }

  // 加載更多
  Future<void> _onLoadMoreEngineeringEvent(LoadMoreEngineeringEvent event, Emitter<EngineeringState> emit) async {}

  // 新增
  Future<void> _onCreateEngineeringEvent(CreateEngineeringEvent event, Emitter<EngineeringState> emit) async {}

  // 更新
  Future<void> _onUpdateEngineeringEvent(UpdateEngineeringEvent event, Emitter<EngineeringState> emit) async {
    emit(emitState(EngineeringEditingState(), state));
    try {
      final response = await EngineeringService.updateEngineering(event.id, event.name, event.inspector, event.contractor, event.engineer, event.phone, event.startDatetime, event.endDatetime, event.description);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> engineering = jsonDecode(response.body);
        state.engineeringMap.update(
          engineering['id'],
          (value) => EngineeringEntity.fromJson(engineering),
        );
        emit(emitState(EngineeringShowingState(), state));
      }
    } catch (e) {
      print('UpdateEngineeringEvent erro--$e');
      emit(emitState(EngineeringErrorState(), state));
    }
  }

  // 刷新
  Future<void> _onRefreshEngineeringEvent(RefreshEngineeringEvent event, Emitter<EngineeringState> emit) async {
    try {
      emit(emitState(EngineeringLoadingState(), state));
      final response = await EngineeringService.getEngineering(event.skip, event.size, event.userId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> engineeringList = jsonDecode(response.body);
        if (engineeringList.isEmpty) {
          state.engineeringMap = {};
        } else {
          for (var engineerItem in engineeringList) {
            state.engineeringMap.update(
              engineerItem['id'],
              (value) => EngineeringEntity.fromJson(engineerItem),
              ifAbsent: () => EngineeringEntity.fromJson(engineerItem),
            );
          }
        }
        emit(emitState(EngineeringShowingState(), state));
      } else {
        print('RefreshEngineeringEvent error--${response.statusCode}');
        emit(emitState(EngineeringErrorState(), state));
      }
    } catch (e) {
      print('RefreshEngineeringEvent erro--$e');
    }
  }
}
