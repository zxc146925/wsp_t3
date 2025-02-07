import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';
import 'package:wsp_t3/utils/public/color_theme.dart';
import '../../../../utils/api/config.dart';
import '../../../../utils/bloc/camera_manager_bloc/camera_manager_bloc.dart';
import '../../../../utils/bloc/video_bloc/video_bloc.dart';

// 影像管理/實時影像
class VideoLiveTabScreen extends StatefulWidget {
  const VideoLiveTabScreen({super.key});

  @override
  State<VideoLiveTabScreen> createState() => _VideoLiveTabScreenState();
}

class _VideoLiveTabScreenState extends State<VideoLiveTabScreen> {
  final VideoBloc videoBloc = VideoBloc();
  BehaviorSubject<int> selectIndexStream = BehaviorSubject<int>.seeded(0);

  @override
  void initState() {
    super.initState();
    print('影片播放');
    if (context.read<CameraManagerBloc>().state.cameraManagerMap.values.toList().isNotEmpty) {
      videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${context.read<CameraManagerBloc>().state.cameraManagerMap.values.toList()[0].id}/livestream/index.m3u8', isLive: true));
    }
  }

  Widget _buildControlPanel(VideoLoaded state, BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: state.position.inSeconds.toDouble(),
            max: state.duration?.inSeconds.toDouble() ?? 0,
            onChanged: (value) {
              state.controller.seekTo(Duration(seconds: value.toInt()));
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(state.position),
                style: const TextStyle(color: Colors.white),
              ),
              if (!state.isLive)
                Text(
                  _formatDuration(state.duration ?? Duration.zero),
                  style: const TextStyle(color: Colors.white),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  state.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  videoBloc.add(VideoPlayPauseEvent());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onButtonPressed(int index) {
    // 原始
    if (index == 0) {
      print('原始URl-${Config.realTimeVideoIP}/${context.read<CameraManagerBloc>().state.cameraIdStream.value}/livestream/index.m3u8');
      videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${context.read<CameraManagerBloc>().state.cameraIdStream.value}/livestream/index.m3u8', isLive: true));
    } else {
      // 辨識
      print('辨識URl-${Config.realTimeVideoIP}/${context.read<CameraManagerBloc>().state.cameraIdStream.value}-ai/livestream/index.m3u8');
      videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${context.read<CameraManagerBloc>().state.cameraIdStream.value}-ai/livestream/index.m3u8', isLive: true));
    }
    selectIndexStream.add(index);
  }

  Widget _buildButton(
    int index,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectIndexStream.value == index ? MyColorTheme.black : Colors.transparent,
          foregroundColor: selectIndexStream.value == index ? Colors.white : MyColorTheme.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  void dispose() {
    videoBloc.close().then((value) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CameraManagerBloc, CameraManagerState>(
      listener: (context, cameraListState) {
        if (cameraListState is CameraManagerInitialCompleteState) {
          print('初始狀態----播放：${Config.realTimeVideoIP}/${cameraListState.cameraManagerMap.values.toList()[0].id}/livestream/index.m3u8');
          videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${cameraListState.cameraManagerMap.values.toList()[0].id}/livestream/index.m3u8', isLive: true));
          cameraListState.cameraIdStream.add(cameraListState.cameraManagerMap.values.toList()[0].id);
          // http://mycena.com.tw:8888/camera-1/index.m3u8
        }
      },
      builder: (context, cameraListState) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: cameraListState.cameraManagerMap.isEmpty
                              ? const Center(child: Text('目前無攝影機資訊'))
                              : DataTable(
                                  showCheckboxColumn: false,
                                  showBottomBorder: true,
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        '狀態',
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        '攝影機名稱',
                                      ),
                                    ),
                                  ],
                                  rows: cameraListState.cameraManagerMap.values
                                      .toList()
                                      .map(
                                        (row) => DataRow(
                                          color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                            if (states.contains(WidgetState.hovered)) {
                                              return Colors.white;
                                            }
                                            return null;
                                          }),
                                          cells: [
                                            DataCell(Container(
                                              width: 10,
                                              height: 10,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: row.state == 0 ? Colors.red : Colors.green,
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                            )),
                                            DataCell(
                                              Container(
                                                child: Text(
                                                  row.cameraName,
                                                ),
                                              ),
                                            ),
                                          ],
                                          onSelectChanged: (isSelected) {
                                            print('Item ${row.id} is selected: $isSelected');
                                            videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${row.id}/livestream/index.m3u8', isLive: true));
                                            cameraListState.cameraIdStream.add(row.id);
                                            selectIndexStream.add(0);
                                            // videoBloc.add(VideoSelectEvent(row.url, isLive: row.isLive));
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<int>(
                                    stream: selectIndexStream.stream,
                                    builder: (context, snapshot) {
                                      return Row(
                                        children: [
                                          _buildButton(0, '原始影像'),
                                          _buildButton(1, '辨識影像'),
                                        ],
                                      );
                                    }),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(height: 2, color: Colors.grey),
                                ),
                                BlocConsumer<VideoBloc, VideoState>(
                                  bloc: videoBloc,
                                  listener: (context, state) {},
                                  builder: (context, state) {
                                    if (state is VideoLoading) {
                                      return const Expanded(
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    } else if (state is VideoLoaded) {
                                      // 添加一个状态变量，用于控制播放按钮的显示和隐藏
                                      bool showPlayButton = !state.controller.value.isPlaying;

                                      return Expanded(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // 视频播放器
                                            AspectRatio(
                                              aspectRatio: state.controller.value.aspectRatio,
                                              child: GestureDetector(
                                                onTap: () {
                                                  // 点击视频区域时切换播放状态，并显示按钮
                                                  showPlayButton = true;
                                                  videoBloc.add(VideoPlayPauseEvent());
                                                },
                                                child: VideoPlayer(state.controller),
                                              ),
                                            ),

                                            // 播放按钮
                                            AnimatedOpacity(
                                              opacity: showPlayButton ? 1.0 : 0.0, // 动画控制按钮的显示和隐藏
                                              duration: const Duration(milliseconds: 300),
                                              child: GestureDetector(
                                                onTap: () {
                                                  // 点击播放按钮切换播放状态
                                                  videoBloc.add(VideoPlayPauseEvent());
                                                  showPlayButton = false;
                                                },
                                                child: Container(
                                                  color: Colors.black.withOpacity(0.5), // 半透明背景
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    state.controller.value.isPlaying
                                                        ? Icons.pause // 播放时显示暂停键
                                                        : Icons.play_arrow, // 暂停时显示播放键
                                                    color: Colors.white,
                                                    size: 100,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (state is VideoError) {
                                      return Expanded(
                                          child: Center(
                                        child: Container(
                                          // color: MyColorTheme.black.withOpacity(0.5),
                                          child: const Text(
                                            // state.message,
                                            '目前影片來源出有誤',
                                          ),
                                        ),
                                      ));
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
