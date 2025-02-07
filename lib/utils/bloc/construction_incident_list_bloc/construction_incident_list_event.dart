part of 'construction_incident_list_bloc.dart';

@immutable
sealed class ConstructionIncidentListEvent {}

//初始
class ConstructionIncidentListInitEvent extends ConstructionIncidentListEvent {
  int size;
  int skip;
  String locationId;
  ConstructionIncidentListInitEvent({required this.size, required this.skip, required this.locationId});
}

//加載更多
class ConstructionIncidentListLoadMoreEvent extends ConstructionIncidentListEvent {
  int size;
  int skip;
  String locationId;
  ConstructionIncidentListLoadMoreEvent({required this.size, required this.skip, required this.locationId});
}
