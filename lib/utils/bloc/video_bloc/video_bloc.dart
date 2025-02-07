import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';
import 'package:wsp_t3/utils/entity/camera.dart';
import 'package:http/http.dart' as http;

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  bool _isDisposed = false;

  factory VideoBloc() {
    var state = VideoInitial();
    state.controller = null;
    return VideoBloc._(state);
  }

  VideoBloc._(state) : super(state) {
    on<VideoLoadEvent>(_onVideoLoad);
    on<VideoPlayPauseEvent>(_onPlayPause);
    on<VideoDisposeEvent>(_onDispose);
    on<VideoProgressUpdateEvent>(_onProgressUpdate);
    on<VideoSelectEvent>(_onVideoSelect);
    on<VideoLoadErrorEvent>(_onVideoLoadError);
    on<VideoSeekEvent>(_onVideoSeek);
  }

  @override
  void onEvent(VideoEvent event) {
    // print('VideoEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<VideoState> change) {
    // print('VideoState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  VideoState emitState(VideoState newState, VideoState oldState) {
    newState.controller = oldState.controller;
    return newState;
  }

  @override
  Future<void> close() async {
    _isDisposed = true;
    if (state.controller != null) {
      await state.controller!.dispose();
      state.controller = null;
      print('關閉影片完成');
    }

    super.close();
  }

  Future<bool> checkM3U8FileExists(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('✅ .m3u8 檔案存在');
        return true;
      } else {
        print('❌ .m3u8 檔案不存在，狀態碼: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('⚠️ 檢查 .m3u8 檔案時發生錯誤: $e');
      return false;
    }
  }

  Future<void> _onVideoLoad(VideoLoadEvent event, Emitter<VideoState> emit) async {
    state.controller?.dispose();
    emit(VideoLoading());
    try {
      bool exists = await checkM3U8FileExists(event.videoUrl);
      if (exists) {
        state.controller = VideoPlayerController.networkUrl(Uri.parse(event.videoUrl));
        await state.controller?.initialize();

        if (_isDisposed) {
          await state.controller?.dispose();
          return;
        }
        state.controller?.play();

        // 若非直播，加入監聽器持續更新播放進度
        if (!event.isLive) {
          state.controller!.addListener(() {
            add(VideoProgressUpdateEvent());
          });
        }

        emit(
          VideoLoaded(
            controller: state.controller!,
            isPlaying: true,
            position: Duration.zero,
            duration: event.isLive ? null : state.controller!.value.duration,
            isLive: event.isLive,
          ),
        );
      } else {
        emit(VideoError("目前影片來源出有誤"));
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(VideoError("目前影片來源出有誤"));
      }
    }
  }

  void _onPlayPause(VideoPlayPauseEvent event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      final controller = currentState.controller;
      if (_isDisposed) return;
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
      emit(
        VideoLoaded(
          controller: controller,
          isPlaying: !controller.value.isPlaying,
          position: controller.value.position,
          duration: currentState.duration,
          isLive: currentState.isLive,
        ),
      );
    }
  }

  Future<void> _onDispose(VideoDisposeEvent event, Emitter<VideoState> emit) async {
    if (state.controller != null) {
      await state.controller?.dispose();
    }
    emit(VideoInitial());
  }

  void _onProgressUpdate(VideoProgressUpdateEvent event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      emit(VideoLoaded(
        controller: currentState.controller,
        isPlaying: currentState.isPlaying,
        position: currentState.controller.value.position,
        duration: currentState.duration,
        isLive: currentState.isLive,
      ));

      // Future.delayed(const Duration(milliseconds: 500), () {
      //   add(VideoProgressUpdateEvent());
      // });
    }
  }

  Future<void> _onVideoSelect(VideoSelectEvent event, Emitter<VideoState> emit) async {
    // 如果当前视频正在加载，回到初始状态
    if (state is VideoLoading || state is VideoLoaded) {
      add(VideoDisposeEvent());
    }

    // 加载新的视频
    add(VideoLoadEvent(event.videoUrl, isLive: event.isLive));
  }

  Future<void> _onVideoLoadError(VideoLoadErrorEvent event, Emitter<VideoState> emit) async {
    // 如果当前视频正在加载，回到初始状态
    emit(VideoError("目前影片來源出有誤"));
    // // 加载新的视频
    // add(VideoLoadEvent(event.videoUrl, isLive: event.isLive));
  }

  /// 新增：處理使用者調整進度的事件
  Future<void> _onVideoSeek(VideoSeekEvent event, Emitter<VideoState> emit) async {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      await currentState.controller.seekTo(event.seekPosition);
      emit(
        VideoLoaded(
          controller: currentState.controller,
          isPlaying: currentState.controller.value.isPlaying,
          position: event.seekPosition,
          duration: currentState.duration,
          isLive: currentState.isLive,
        ),
      );
    }
  }
}
