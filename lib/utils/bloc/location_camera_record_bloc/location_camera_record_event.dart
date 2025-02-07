part of 'location_camera_record_bloc.dart';

@immutable
sealed class LocationCameraRecordEvent {}


// 初始化
class LocationCameraRecordInitialEvent extends LocationCameraRecordEvent {
  final int skip;
  final int size;
  final String locationId;
  final String cameraId;
  LocationCameraRecordInitialEvent({required this.skip, required this.size, required this.locationId, required this.cameraId});
}

// 加載更多
class LocationCameraRecordLoadMoreEvent extends LocationCameraRecordEvent {
  final int skip;
  final int size;
  final String locationId;
  final String cameraId;
  LocationCameraRecordLoadMoreEvent({required this.skip, required this.size, required this.locationId, required this.cameraId});
}



// // 新增
// class LocationCameraRecordCreateEvent extends LocationCameraRecordEvent {
//   final String locationId;
//   final String cameraId;
//   final String name;
//   final int startDatetime;
//   final int endDatetime;
//   final int number;
//   final int anomalyAmount;
//   final String description;
//   LocationCameraRecordCreateEvent({
//     required this.locationId,
//     required this.cameraId,
//     required this.name,
//     required this.startDatetime,
//     required this.endDatetime,
//     required this.number,
//     required this.anomalyAmount,
//     required this.description,
//   });
// }