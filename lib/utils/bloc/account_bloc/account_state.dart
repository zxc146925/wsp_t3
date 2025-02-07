part of 'account_bloc.dart';

@immutable
sealed class AccountState {
  Map<String, UserEntity> userMap = {};
  Map<String, EngineeringEntity> engineeringMap = {};
}

// 初始狀態
final class AccountInitialState extends AccountState {}

//讀取中(整個轉圈)
class AccountLoadingState extends AccountState {}

// 讀取更多(UI轉圈)
class AccountLoadingMoreState extends AccountState {}

// 讀取已達上限
class AccountReadMoreMaxState extends AccountState {}

//顯示中
class AccountShowingState extends AccountState {}

//讀取失敗
class AccountErrorState extends AccountState {}

// 編輯使用者
final class AccountEditingState extends AccountState {}

// 編輯失敗
final class AccountEditErrorState extends AccountState {}

//新增使用者
final class AccountAddingState extends AccountState {}

//新增失敗
final class AccountAddErrorState extends AccountState {}