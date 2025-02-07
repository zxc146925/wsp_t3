part of 'engineering_bloc.dart';

@immutable
sealed class EngineeringState {
  Map<String,EngineeringEntity> engineeringMap = {};
}

//初始狀態
final class EngineeringInitial extends EngineeringState {}

//編輯中
class EngineeringEditingState extends EngineeringState {}


//讀取中
class EngineeringLoadingState extends EngineeringState {}

//顯示中
class EngineeringShowingState extends EngineeringState {}

//加載失敗
class EngineeringErrorState extends EngineeringState {}