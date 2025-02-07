import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../api/user_service.dart';
import '../../entity/engineering.dart';
import '../../entity/user.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  factory AccountBloc() {
    var state = AccountInitialState();
    state.userMap = {};
    return AccountBloc._(state);
  }

  // ignore: use_super_parameters
  AccountBloc._(state) : super(state) {
    on<AccountInitEvent>(_onAccountInitEvent);
    on<AccountLoadMoreEvent>(_onAccountLoadMoreEvent);
    on<CreateAccountEvent>(_onCreateAccountEvent);
    on<UpdateAccountEvent>(_onUpdateAccountEvent);
  }

  @override
  void onEvent(AccountEvent event) {
    print('AccountEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<AccountState> change) {
    print('AccountState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  AccountState emitState(AccountState newState, AccountState oldState) {
    newState.userMap = oldState.userMap;
    return newState;
  }

  // 初始化
  Future<void> _onAccountInitEvent(AccountInitEvent event, Emitter<AccountState> emit) async {
    emit(emitState(AccountLoadingState(), state));
    if (event.user!.permission == 0) {
      state.userMap.update(
        event.user!.id,
        (value) => event.user!,
        ifAbsent: () => event.user!,
      );
    } else {
      final response = await UserService.getUser(event.skip, event.size);
      // print('getNotifaiction  response-----${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> userList = jsonDecode(response.body);
        if (userList.isEmpty) {
          state.userMap = {};
        } else {
          for (var userItem in userList) {
            state.userMap.update(
              userItem['id'],
              (value) => UserEntity.fromJson(userItem),
              ifAbsent: () => UserEntity.fromJson(userItem),
            );
          }
        }
      }
    }
    emit(emitState(AccountShowingState(), state));
  }

  // 讀取更多
  Future<void> _onAccountLoadMoreEvent(AccountLoadMoreEvent event, Emitter<AccountState> emit) async {
    emit(emitState(AccountLoadingMoreState(), state));
  }

  // 新增
  Future<void> _onCreateAccountEvent(CreateAccountEvent event, Emitter<AccountState> emit) async {
    emit(emitState(AccountAddingState(), state));
    final response = await UserService.registerUser(event.mail, event.password, event.name, event.phone, event.permission, event.engineeringId);
    print('registerUser  response-----${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> userMap = jsonDecode(response.body);
      if (userMap.isEmpty) {
        state.userMap = {};
      } else {
        state.userMap.update(
          userMap['id'],
          (value) => UserEntity.fromJson(userMap),
          ifAbsent: () => UserEntity.fromJson(userMap),
        );
      }
      emit(emitState(AccountShowingState(), state));
    } else {
      emit(emitState(AccountAddErrorState(), state));
    }
  }

  // 編輯使用者
  Future<void> _onUpdateAccountEvent(UpdateAccountEvent event, Emitter<AccountState> emit) async {
    emit(emitState(AccountEditingState(), state));
    try {
      final response = await UserService.updateUser(event.id, event.mail, event.name, event.phone, event.permission);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> user = jsonDecode(response.body);
        state.userMap.update(
          user['id'],
          (value) => UserEntity.fromJson(user),
        );
        emit(emitState(AccountShowingState(), state));
      } else {
        print('AccountUpdateEvent error--${response.statusCode}');
        emit(emitState(AccountEditErrorState(), state));
      }
    } catch (e) {
      print('AccountUpdateEvent erro--$e');
      emit(emitState(AccountEditErrorState(), state));
    }
  }
}
