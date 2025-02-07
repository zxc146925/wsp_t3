part of 'login_bloc.dart';

@immutable
sealed class LoginState {
  UserEntity? userEntity;
}

final class LoginInitialState extends LoginState {}


class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {}

class LoginFailureState extends LoginState {}