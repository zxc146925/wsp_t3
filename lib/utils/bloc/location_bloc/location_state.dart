part of 'location_bloc.dart';

@immutable
sealed class LocationState {
  Map<String, LocationEntity> locationMap = {};
  EngineeringEntity? engineeringEntity;
  LocationEntity? locationEntityItem;
}

//初始狀態
final class LocationInitial extends LocationState {}


//讀取中
class LocationLoadingState extends LocationState {}

//顯示中
class LocationShowingState extends LocationState {}

// 添加
class LocationAddingState extends LocationState {}

//加載失敗
class LocationErrorState extends LocationState {}

// 編輯中
final class LocationEditingState extends LocationState {}

// 編輯失敗
final class LocationEditErrorState extends LocationState {}
