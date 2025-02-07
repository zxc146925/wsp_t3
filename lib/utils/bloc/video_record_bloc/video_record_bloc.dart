import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/config.dart';
import '../../api/record_service.dart';
import '../../view_model/video_record.dart';

part 'video_record_event.dart';
part 'video_record_state.dart';

class VideoRecordBloc extends Bloc<VideoRecordEvent, VideoRecordState> {
  factory VideoRecordBloc() {
    var state = VideoRecordInitial();
    state.videoRecordMap = {};
    state.aiFilename = '';
    state.filename = '';
    return VideoRecordBloc._(state);
  }

  VideoRecordBloc._(state) : super(state) {
    on<VideoRecordInitEvent>(_onVideoRecordInitEvent);
  }

  @override
  void onEvent(VideoRecordEvent event) {
    // print('VideoRecordEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<VideoRecordState> change) {
    // print('VideoRecordState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  VideoRecordState emitState(VideoRecordState newState, VideoRecordState oldState) {
    newState.videoRecordMap = oldState.videoRecordMap;
    return newState;
  }

  // 初始化
  Future<void> _onVideoRecordInitEvent(VideoRecordInitEvent event, Emitter<VideoRecordState> emit) async {
    // print('初始話影片----------${event.cameraId}---${event.startDatetime}---${event.endDatetime}');
    emit(emitState(VideoRecordLoading(), state));
    state.videoRecordMap = {};
    try {
      final response = await RecordService.getRecordCamera(startDatetime: event.startDatetime, endDatetime: event.endDatetime, cameraId: event.cameraId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> videoRecordList = jsonDecode(response.body);
        if (videoRecordList.isEmpty) {
          state.videoRecordMap = {};
        } else {
          for (var videoRecordItem in videoRecordList) {
            // print('videoRecordItem--------------------------${videoRecordItem.toString()}');
            state.videoRecordMap.update(
              videoRecordItem['filename'],
              (value) => VideoRecordViewModel(
                thumbnail: '${Config.mediaSocketUrl}/file/${videoRecordItem['thumbnail']}',
                aiThumbnail: '${Config.mediaSocketUrl}/file/${videoRecordItem['aiThumbnail']}',
                filename: videoRecordItem['filename'],
                aiFilename: videoRecordItem['aiFilename'],
                startDatetime: videoRecordItem['startDatetime'],
                endDatetime: videoRecordItem['startDatetime'] + 3600000, // 加一小時
              ),
              ifAbsent: () => VideoRecordViewModel(
                thumbnail: '${Config.mediaSocketUrl}/file/${videoRecordItem['thumbnail']}',
                aiThumbnail: '${Config.mediaSocketUrl}/file/${videoRecordItem['aiThumbnail']}',
                filename: videoRecordItem['filename'],
                aiFilename: videoRecordItem['aiFilename'],
                startDatetime: videoRecordItem['startDatetime'],
                endDatetime: videoRecordItem['startDatetime'] + 3600000, // 加一小時
              ),
            );
          }
        }
        emit(emitState(VideoRecordShowing(), state));
      }
    } catch (e) {
      emit(emitState(VideoRecordError(), state));
    }
  }
}
