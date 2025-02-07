import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../api/login_service.dart';
import '../../entity/user.dart';
import '../../public/shared_preferences_manager.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  factory LoginBloc() {
    var state = LoginInitialState();
    return LoginBloc._(state);
  }

  LoginBloc._(state) : super(state) {
    on<SignInEvent>(_onSignInEvent);
    on<ForgotPasswordEvent>(_onForgotPasswordEvent);
  }

  @override
  void onEvent(LoginEvent event) {
    // print('LoginEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<LoginState> change) {
    // print('LoginState onChange--------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  LoginState emitState(LoginState newState, LoginState oldState) {
    newState.userEntity = oldState.userEntity;
    return newState;
  }

  void _onSignInEvent(SignInEvent event, Emitter<LoginState> emit) async {
   
    emit(emitState(LoginLoadingState(), state));
    var response = await LoginService.login(event.mail, event.password);

    print('SignInEvent response-----${jsonDecode(response.body)}');

    switch (response.statusCode) {
      case 201:
      case 200:
        {
          final SharedPreferencesManager sharedPreferencesManager = await SharedPreferencesManager.getInstance();
          Map<String, dynamic> data = jsonDecode(response.body);
          print('登入成功------${data.toString()}');
          state.userEntity = UserEntity.fromJson(data);
          if (event.isRememberMe) {
            print('記住我的帳號');
            sharedPreferencesManager.setString('mail', event.mail);
            sharedPreferencesManager.setString('password', event.password);
            await SharedPreferencesManager.saveUserEntity(state.userEntity!);
          }
          emit(emitState(LoginSuccessState(), state));
          break;
        }
      default:
        {
          print('登入失敗');
          emit(emitState(LoginFailureState(), state));
          break;
        }
    }
  }

  void _onForgotPasswordEvent(ForgotPasswordEvent event, Emitter<LoginState> emit) async {
    emit(emitState(LoginLoadingState(), state));
  }
}
