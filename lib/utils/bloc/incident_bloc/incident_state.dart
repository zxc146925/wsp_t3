part of 'incident_bloc.dart';

@immutable
sealed class IncidentState {
  Map<String, IncidentListViewModel> incidentMap = {};
}

// 初始狀態
final class IncidentInitialState extends IncidentState {}

//讀取中(整個轉圈)
class IncidentLoadingState extends IncidentState {}

// 讀取更多(UI轉圈)
class IncidentLoadingMoreState extends IncidentState {}

// 讀取已達上限
class IncidentReadMoreMaxState extends IncidentState {}

//顯示中
class IncidentShowingState extends IncidentState {}

//讀取失敗
class IncidentErrorState extends IncidentState {}

// 編輯中
final class IncidentEditingState extends IncidentState {}

// 編輯失敗
final class IncidentEditErrorState extends IncidentState {}
