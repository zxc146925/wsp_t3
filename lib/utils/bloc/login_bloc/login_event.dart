part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {


}

class SignInEvent extends LoginEvent {
  final String mail;
  final String password;
  final bool isRememberMe;

  SignInEvent(this.mail, this.password, this.isRememberMe);
}

class ForgotPasswordEvent extends LoginEvent {
  final String account;

  ForgotPasswordEvent(this.account);
}