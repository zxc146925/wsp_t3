part of 'account_bloc.dart';

@immutable
sealed class AccountEvent {}

// 初始化
class AccountInitEvent extends AccountEvent {
  final int skip;
  final int size;
  final UserEntity? user;
  AccountInitEvent({required this.skip, required this.size,this.user});
}

// 加載更多
class AccountLoadMoreEvent extends AccountEvent {
  final int skip;
  final int size;
  AccountLoadMoreEvent({required this.skip, required this.size});
}

//編輯帳號
class UpdateAccountEvent extends AccountEvent {
  final String id;
  final String mail;
  final String name;
  final String phone;
  final int permission;
  UpdateAccountEvent({required this.id, required this.mail, required this.name, required this.phone, required this.permission});
}

// 新增帳號
class CreateAccountEvent extends AccountEvent {
  final String mail;
  final String name;
  final String phone;
  final int permission;
  final String password;
  final String engineeringId;
  CreateAccountEvent({required this.mail, required this.name, required this.phone, required this.permission, required this.password, required this.engineeringId});
}
