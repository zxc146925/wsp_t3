import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/record_service.dart';
import '../../entity/location_camera_record.dart';

part 'location_camera_record_event.dart';
part 'location_camera_record_state.dart';

// 案場的影像紀錄使用
class LocationCameraRecordBloc extends Bloc<LocationCameraRecordEvent, LocationCameraRecordState> {
  factory LocationCameraRecordBloc() {
    var state = LocationCameraRecordInitial();
    state.locationCameraRecordMap = {};
    return LocationCameraRecordBloc._(state);
  }

  LocationCameraRecordBloc._(state) : super(state) {
    on<LocationCameraRecordInitialEvent>(_onLocationCameraRecordInitialEvent);
  }

  @override
  void onEvent(LocationCameraRecordEvent event) {
    print('LocationCameraRecordEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<LocationCameraRecordState> change) {
    print('LocationCameraRecordState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  LocationCameraRecordState emitState(LocationCameraRecordState newState, LocationCameraRecordState oldState) {
    newState.locationCameraRecordMap = oldState.locationCameraRecordMap;
    return newState;
  }

  //  初始化
  Future<void> _onLocationCameraRecordInitialEvent(LocationCameraRecordInitialEvent event, Emitter<LocationCameraRecordState> emit) async {
    emit(LocationCameraRecordLoading());
    state.locationCameraRecordMap.clear();
    print('初始化影像紀錄-------${event.size}');
    try {
      var response = await RecordService.getRecordCameraAndLocation(skip: 0, size: event.size, cameraId: event.cameraId, locationId: event.locationId);
      print('response-------------${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> locationCamerRecordList = jsonDecode(response.body);

        if (locationCamerRecordList.isEmpty) {
          state.locationCameraRecordMap = {};
        } else {
          for (var locationCamerRecordItem in locationCamerRecordList) {
            // List<String> parts = PublicData.splitByFirstSlash(locationCamerRecordItem['filename']);
            // print('locationCamerRecordItem-----------${locationCamerRecordItem.toString()}');


           

            state.locationCameraRecordMap.update(
              locationCamerRecordItem['filename'],
              (value) => LocationCameraRecordEntity(
                thumbnail: locationCamerRecordItem['thumbnail'],
                aiThumbnail: locationCamerRecordItem['aiThumbnail'],
                filename: locationCamerRecordItem['filename'],
                aiFilename: locationCamerRecordItem['aiFilename'],
                startDatetime: locationCamerRecordItem['startDatetime'],
                endDatetime: locationCamerRecordItem['startDatetime'] + 3600000, // 加一小時
              ),
              ifAbsent: () => LocationCameraRecordEntity(
                thumbnail: locationCamerRecordItem['thumbnail'],
                aiThumbnail: locationCamerRecordItem['aiThumbnail'],
                filename: locationCamerRecordItem['filename'],
                aiFilename: locationCamerRecordItem['aiFilename'],
                startDatetime: locationCamerRecordItem['startDatetime'],
                endDatetime: locationCamerRecordItem['startDatetime'] + 3600000, // 加一小時
              ),
            );
          }
        }
        emit(emitState(LocationCameraRecordInitialComplete(), state));
      }
    } catch (e) {
      emit(emitState(LocationCameraRecordError(), state));
    }
  }
}
