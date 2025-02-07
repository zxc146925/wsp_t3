part of 'incident_bloc.dart';

@immutable
sealed class IncidentEvent {}

// 初始化
class IncidentInitEvent extends IncidentEvent {
  final int skip;
  final int size;
  IncidentInitEvent({required this.skip, required this.size});
}

// 加載更多
class IncidentLoadMoreEvent extends IncidentEvent {
  final int skip;
  final int size;
  IncidentLoadMoreEvent({required this.skip, required this.size});
}

// 搜尋
class IncidentSearchEvent extends IncidentEvent {
  final int skip;
  final int size;
  String? keyword;
  int? startDatetime;
  int? endDatetime;
  int? incidentState;
  IncidentSearchEvent({
    required this.skip,
    required this.size,
    this.keyword,
    this.startDatetime,
    this.endDatetime,
    this.incidentState,
  });
}

//搜尋更多
class IncidentSearchLoadMoreEvent extends IncidentEvent {
  final int skip;
  final int size;
  String? keyword;
  int? startDatetime;
  int? endDatetime;
  int? incidentState;
  IncidentSearchLoadMoreEvent({
    required this.skip,
    required this.size,
    this.keyword,
    this.startDatetime,
    this.endDatetime,
    this.incidentState,
  });
}

//編輯異常
class UpdateIncidentEvent extends IncidentEvent {
  // 判斷是編輯還是添加最愛
  final bool isEdit;
  final String incidentId;
  final int state;
  final bool isPinned;
  UpdateIncidentEvent({required this.incidentId, required this.state, required this.isPinned, required this.isEdit});
}

// 推播添加
class CreateIncidentEvent extends IncidentEvent {
  final IncidentListViewModel incidentViewModel;
  CreateIncidentEvent(this.incidentViewModel);
}
