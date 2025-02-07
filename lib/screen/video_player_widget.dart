import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../utils/bloc/video_bloc/video_bloc.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoBloc videoBloc = VideoBloc();

  @override
  void initState() {
    videoBloc.add(VideoLoadEvent('https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8', isLive: false));
    super.initState();
  }

  // 輔助函數：將 Duration 格式化為 mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<VideoBloc, VideoState>(
        bloc: videoBloc,
        listener: (context, state) {
          // 可在此根據狀態做額外處理
        },
        builder: (context, state) {
          if (state is VideoLoading || state is VideoInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is VideoLoaded) {
            // 依據是否為直播決定 UI 呈現
            if (state.isLive) {
              // 直播影片：僅顯示影片與播放/暫停按鈕
              return Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: state.controller.value.aspectRatio,
                    child: GestureDetector(
                      onTap: () => videoBloc.add(VideoPlayPauseEvent()),
                      child: VideoPlayer(state.controller),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: IconButton(
                      icon: Icon(
                        state.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                      onPressed: () => videoBloc.add(VideoPlayPauseEvent()),
                    ),
                  ),
                ],
              );
            } else {
              // 非直播影片：顯示影片、進度條、開始／結束時間及播放按鈕
              final position = state.controller.value.position;
              final duration = state.duration ?? Duration.zero;
              final sliderValue = position.inSeconds.toDouble();
              final maxSliderValue = duration.inSeconds.toDouble();

              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // 影片播放器
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: state.controller.value.aspectRatio,
                      child: VideoPlayer(state.controller),
                    ),
                  ),
                  // 進度條與時間顯示
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        // 當前播放時間
                        Text(_formatDuration(position)),
                        Expanded(
                          child: Slider(
                            value: sliderValue.clamp(0, maxSliderValue),
                            max: maxSliderValue,
                            onChanged: (value) {
                              // 使用者拖拉 Slider 時，派發 VideoSeekEvent
                              videoBloc.add(VideoSeekEvent(Duration(seconds: value.toInt())));
                            },
                          ),
                        ),
                        // 影片總長度
                        Text(_formatDuration(duration)),
                      ],
                    ),
                  ),
                  // 播放/暫停按鈕
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: IconButton(
                      icon: Icon(
                        state.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 50,
                      ),
                      onPressed: () => videoBloc.add(VideoPlayPauseEvent()),
                    ),
                  ),
                ],
              );
            }
          } else if (state is VideoError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  '目前影片來源出有誤',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
