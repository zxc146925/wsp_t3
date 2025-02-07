import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/notification_service.dart';
import '../../entity/notification.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  factory NotificationBloc() {
    var state = NotificationInitialState();
    state.notificationMap = {};
    return NotificationBloc._(state);
  }

  // ignore: use_super_parameters
  NotificationBloc._(state) : super(state) {
    on<NotificationInitEvent>(_onNotificationInitEvent);
    on<NotificationLoadMoreEvent>(_onNotificationLoadMoreEvent);
    on<NotificationAddEvent>(_onNotificationAddEvent);
    on<NotificationUpdateReadEvent>(_onNotificationUpdateReadEvent);
  }

  @override
  void onEvent(NotificationEvent event) {
    // print('NotificationEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<NotificationState> change) {
    // print('NotificationState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  NotificationState emitState(NotificationState newState, NotificationState oldState) {
    newState.notificationMap = oldState.notificationMap;
    return newState;
  }

  // 初始化
  Future<void> _onNotificationInitEvent(NotificationInitEvent event, Emitter<NotificationState> emit) async {
    emit(emitState(NotificationLoadingState(), state));
    final response = await NotificationService.getNotifaiction(event.skip, event.size, event.userId);
    // print('getNotifaiction  response-----${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> notifaictionList = jsonDecode(response.body);
      if (notifaictionList.isEmpty) {
        state.notificationMap = {};
      } else {
        for (var notifaictionItem in notifaictionList) {
          if (notifaictionItem['read'] == false) {
            state.notificationMap.update(
              notifaictionItem['id'],
              (value) => NotificationEntity.fromJson(notifaictionItem),
              ifAbsent: () => NotificationEntity.fromJson(notifaictionItem),
            );
          }
        }
      }
      emit(emitState(NotificationShowingState(), state));
    }
  }

  // 讀取更多
  Future<void> _onNotificationLoadMoreEvent(NotificationLoadMoreEvent event, Emitter<NotificationState> emit) async {
    emit(emitState(NotificationLoadingMoreState(), state));
    final response = await NotificationService.getNotifaiction(event.skip, event.size, event.userId);
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> notifaictionList = jsonDecode(response.body);
      // print('NotificationLoadingMoreState getNotifaiction  response-----${response.body}');
      for (var notifaictionItem in notifaictionList) {
        if (notifaictionItem['read'] == false) {
          state.notificationMap.update(
            notifaictionItem['id'],
            (value) => NotificationEntity.fromJson(notifaictionItem),
            ifAbsent: () => NotificationEntity.fromJson(notifaictionItem),
          );
        }
      }
      if (notifaictionList.length < event.size) {
        // 讀取已達上限
        emit(emitState(NotificationReadMoreMaxState(), state));
      } else {
        // 未達上限
        emit(emitState(NotificationShowingState(), state));
      }
    } else {
      // 讀取失敗，都回到初始狀態
      emit(emitState(NotificationInitialState(), state));
    }
  }

  // 推播添加
  Future<void> _onNotificationAddEvent(NotificationAddEvent event, Emitter<NotificationState> emit) async {
    emit(emitState(NotificationLoadingMoreState(), state));
    Map<String, NotificationEntity> newMap = {};
    newMap.update(event.notificationEntity.id, (value) => event.notificationEntity, ifAbsent: () => event.notificationEntity);
    newMap.addAll(state.notificationMap);
    state.notificationMap = newMap;
    emit(emitState(NotificationShowingState(), state));
  }

  // 更新推播為已讀
  Future<void> _onNotificationUpdateReadEvent(NotificationUpdateReadEvent event, Emitter<NotificationState> emit) async {
    emit(emitState(NotificationLoadingMoreState(), state));
    final response = await NotificationService.updateNotifaictionRead(event.notificationId, event.userId);
    print('updateNotifaictionRead  response-----${response.body}');
    Map<String, dynamic> responseMap = jsonDecode(response.body);
    NotificationEntity entity = NotificationEntity.fromJson(responseMap);

    state.notificationMap.update(
      entity.id,
      (value) => entity,
    );

    emit(emitState(NotificationShowingState(), state));
  }
}
