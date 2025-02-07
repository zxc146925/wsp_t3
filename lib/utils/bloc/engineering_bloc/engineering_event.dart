part of 'engineering_bloc.dart';

@immutable
sealed class EngineeringEvent {}

// 刷新
class RefreshEngineeringEvent extends EngineeringEvent {
  final int skip;
  final int size;
  final String userId;
  RefreshEngineeringEvent({required this.skip, required this.size, required this.userId});
}

// 加載更多
class LoadMoreEngineeringEvent extends EngineeringEvent {}

// 新增
class CreateEngineeringEvent extends EngineeringEvent {}

// 更新
class UpdateEngineeringEvent extends EngineeringEvent {
  final String id;
  final String name;
  final String inspector;
  final String contractor;
  final String engineer;
  final String phone;
  final int startDatetime;
  final int endDatetime;
  final String description;
  UpdateEngineeringEvent({
    required this.id,
    required this.name,
    required this.inspector,
    required this.contractor,
    required this.engineer,
    required this.phone,
    required this.startDatetime,
    required this.endDatetime,
    required this.description,
  });
}