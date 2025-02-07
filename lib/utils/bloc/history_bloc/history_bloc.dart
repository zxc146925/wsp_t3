import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/chatroom_service.dart';
import '../../entity/history.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  factory HistoryBloc() {
    var state = HistoryInitialState();
    state.historyMap = {};
    return HistoryBloc._(state);
  }

  // ignore: use_super_parameters
  HistoryBloc._(state) : super(state) {
    on<HistoryInitEvent>(_onHistoryInitEvent);
    on<HistoryLoadMoreEvent>(_onHistoryLoadMoreEvent);
  }

  @override
  void onEvent(HistoryEvent event) {
    print('HistoryEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<HistoryState> change) {
    print('HistoryState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  HistoryState emitState(HistoryState newState, HistoryState oldState) {
    newState.historyMap = oldState.historyMap;
    return newState;
  }

  // 初始
  Future<void> _onHistoryInitEvent(HistoryInitEvent event, Emitter<HistoryState> emit) async {
    emit(emitState(HistoryLoadingState(), state));
    try {
      final response = await ChatroomService.getChatroomByUser(event.skip, event.size, event.userId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        state.historyMap.clear();
        List<dynamic> historyList = jsonDecode(response.body);
        for (var history in historyList) {
          state.historyMap.update(
            history['id'],
            (value) => HistoryEntity.fromJson(history),
            ifAbsent: () => HistoryEntity.fromJson(history),
          );
        }
        emit(emitState(HistoryShowingState(), state));
      }
    } catch (e) {
      print('HistoryInitEvent 失敗：$e');
      emit(emitState(HistoryReadFailState(), state));
    }
  }

  // 讀取更多
  Future<void> _onHistoryLoadMoreEvent(HistoryLoadMoreEvent event, Emitter<HistoryState> emit) async {
    emit(emitState(HistoryLoadMoreState(), state));
    try {
      final response = await ChatroomService.getChatroomByUser(event.skip, event.size, event.userId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> historyList = jsonDecode(response.body);
        for (var history in historyList) {
          state.historyMap.update(
            history['id'],
            (value) => HistoryEntity.fromJson(history),
            ifAbsent: () => HistoryEntity.fromJson(history),
          );
        }
        if (historyList.length < event.size) {
          emit(emitState(HistoryLoadMoreMaxState(), state));
        } else {
          emit(emitState(HistoryShowingState(), state));
        }
      }
    } catch (e) {
      print('HistoryInitEvent 失敗：$e');
      emit(emitState(HistoryReadFailState(), state));
    }
  }
}
