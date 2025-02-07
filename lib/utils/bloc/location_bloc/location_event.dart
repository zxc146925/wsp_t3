part of 'location_bloc.dart';

@immutable
sealed class LocationEvent {}

// 刷新
class RefreshLocationEvent extends LocationEvent {
  final int skip;
  final int size;
  final EngineeringEntity engineering;
  RefreshLocationEvent({required this.skip, required this.size, required this.engineering});
}

// 加載更多
class LoadMoreLocationEvent extends LocationEvent {}

// 新增
class CreateLocationEvent extends LocationEvent {
  final String engineeringId;
  final String name;
  final String manager;
  final String phone;
  final int state;
  final String description;
  final int startDatetime;
  final int endDatetime;
  CreateLocationEvent({
    required this.engineeringId,
    required this.name,
    required this.manager,
    required this.phone,
    required this.state,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
  });
}

// 更新
class UpdateLocationEvent extends LocationEvent {
  final String id;
  final String name;
  final String manager;
  final String phone;
  final int state;
  final String description;
  final int startDatetime;
  final int endDatetime;
  UpdateLocationEvent({
    required this.id,
    required this.name,
    required this.manager,
    required this.phone,
    required this.state,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
  });
}
