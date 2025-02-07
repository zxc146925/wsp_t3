part of 'construction_incident_list_bloc.dart';

@immutable
sealed class ConstructionIncidentListState {
   Map<String, LocationIncidentListViewModel> locationIncidentMap = {};
}

// 初始狀態
class ConstructionIncidentListInitialState extends ConstructionIncidentListState {}

// 讀取中
class ConstructionIncidentListLoadingState extends ConstructionIncidentListState {}


// 加載更多狀態
class ConstructionIncidentListLoadMoreState extends ConstructionIncidentListState {}

// 顯示中
class ConstructionIncidentListShowState extends ConstructionIncidentListState {}

// 加載最多
class ConstructionIncidentListReadMaxState extends ConstructionIncidentListState {}


// 加載失敗
class ConstructionIncidentListErrorState extends ConstructionIncidentListState {}