import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/api/config.dart';
import '../../../utils/bloc/login_bloc/login_bloc.dart';
import '../../../utils/bloc/video_bloc/video_bloc.dart';
import '../../../utils/bloc/video_record_bloc/video_record_bloc.dart';
import '../../../utils/public/color_theme.dart';
import '../../../utils/public/public_data.dart';
import '../../../utils/view_model/video_record.dart';

class VideoRecord extends StatefulWidget {
  VideoRecordBloc bloc;
  VideoRecord({super.key, required this.bloc});

  @override
  State<VideoRecord> createState() => _VideoRecordState();
}

class _VideoRecordState extends State<VideoRecord> {
  // int _selectedIndex = 0; // 用來記錄當前選中的按鈕索引
  final ScrollController _horizontalController = ScrollController();
  BehaviorSubject<int> selectIndexStream = BehaviorSubject<int>.seeded(0);
  VideoBloc videoBloc = VideoBloc();

  // 當按鈕被點擊時，更新選中的索引
  void _onButtonPressed(int index) {
    selectIndexStream.add(index);
    if (index == 0) {
      // 辨識中
      if (widget.bloc.state.videoRecordMap.isNotEmpty) {
        videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${widget.bloc.state.videoRecordMap.values.first.aiFilename}', isLive: false));
      }
    } else {
      // 原始中
      if (widget.bloc.state.videoRecordMap.isNotEmpty) {
        videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${widget.bloc.state.videoRecordMap.values.first.filename}', isLive: false));
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _buildButton(int index, String text) {
    return StreamBuilder<int>(
        stream: selectIndexStream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () => _onButtonPressed(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: snapshot.data == index ? MyColorTheme.black : Colors.transparent,
                foregroundColor: snapshot.data == index ? Colors.white : MyColorTheme.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(text),
            ),
          );
        });
  }

  @override
  void dispose() {
    videoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 按鈕與下載圖標區域
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 按鈕組
              Row(
                children: [
                  _buildButton(0, '辨識影像'),
                  _buildButton(1, '原始影像'),
                ],
              ),
              // 下載按鈕
            context.read<LoginBloc>().state.userEntity!.permission == 0 ? Container():  MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (widget.bloc.state.videoRecordMap.isNotEmpty) {
                      if (selectIndexStream.value == 0) {
                        // 辨識中
                        List<String> parts = PublicData.splitByFirstSlash(widget.bloc.state.videoRecordMap.values.first.aiFilename);
                        String fireUrl = '${Config.recordsVideoIP}/api/mp4?cameraId=${parts[0]}&hlsFile=${parts[1]}';
                        String fileName = parts[1];
                        print('下載AI Url:$fireUrl---$fileName');
                        PublicData.directDownload(fireUrl, fileName);
                      } else {
                        // 原始中
                        List<String> parts = PublicData.splitByFirstSlash(widget.bloc.state.videoRecordMap.values.first.filename);
                        String fireUrl = '${Config.recordsVideoIP}/api/mp4?cameraId=${parts[0]}&hlsFile=${parts[1]}';
                        String fileName = parts[1];
                        print('原始 Url:$fireUrl---$fileName');
                        PublicData.directDownload(fireUrl, fileName);
                      }
                    }
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: MyColorTheme.black,
                    ),
                    child: const Icon(
                      size: 20,
                      Icons.file_download_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: BlocConsumer<VideoBloc, VideoState>(
              bloc: videoBloc,
              listener: (context, videoState) {},
              builder: (context, videoState) {
                if (videoState is VideoLoading || videoState is VideoInitial) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (videoState is VideoLoaded) {
                  // 添加一个状态变量，用于控制播放按钮的显示和隐藏
                  bool showPlayButton = !videoState.controller.value.isPlaying;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // 视频播放器
                      AspectRatio(
                        aspectRatio: videoState.controller.value.aspectRatio,
                        child: GestureDetector(
                          onTap: () {
                            // 点击视频区域时切换播放状态，并显示按钮
                            showPlayButton = true;
                            videoBloc.add(VideoPlayPauseEvent());
                          },
                          child: VideoPlayer(videoState.controller),
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
                              videoState.controller.value.isPlaying
                                  ? Icons.pause // 播放时显示暂停键
                                  : Icons.play_arrow, // 暂停时显示播放键
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (videoState is VideoError) {
                  return Center(
                    child: Container(
                      // color: MyColorTheme.black.withOpacity(0.5),
                      child: const Text(
                        // state.message,
                        '目前影片來源出有誤',
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
        // 綠色主要內容區域

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            height: 2,
            color: Colors.grey,
          ),
        ),
        // 紅色區域
        BlocConsumer<VideoRecordBloc, VideoRecordState>(
          bloc: widget.bloc,
          listener: (context, state) {
            if (state is VideoRecordShowing) {
              selectIndexStream.add(0);
              if (state.videoRecordMap.isNotEmpty) {
                videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${widget.bloc.state.videoRecordMap.values.first.aiFilename}', isLive: false));
              } else {
                videoBloc.add(VideoLoadEvent('', isLive: false));
              }
            }
          },
          builder: (context, state) {
            switch (state.runtimeType) {
              case VideoRecordInitial:
              case VideoRecordLoading:
                {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              case VideoRecordShowing:
                {
                  if (state.videoRecordMap.isEmpty) {
                    return const Center(
                      child: SizedBox(height: 140, child: Text('目前沒有影片記錄')),
                    );
                  }
                  return SizedBox(
                      height: 140,
                      child: Scrollbar(
                        thumbVisibility: true, // 顯示水平滾動條
                        controller: _horizontalController,
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 10.0, // 每個物件之間的水平間距
                            runSpacing: 10.0, // 每行之間的垂直間距
                            children: List.generate(state.videoRecordMap.length, (index) {
                              VideoRecordViewModel model = state.videoRecordMap.values.toList()[index];
                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    // 切換播放影片

                                    if (selectIndexStream.value == 0) {
                                      // 辨識
                                      print('辨識圖片------${model.aiThumbnail}');

                                      videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${model.aiFilename}', isLive: false));
                                    } else {
                                      // 原始
                                      print('原始圖片------${model.thumbnail}');

                                      videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${model.filename}', isLive: false));
                                    }
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 200,
                                        // height: 50, // 固定高度
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          // color: Colors.red,
                                        ),
                                        child: StreamBuilder<int>(
                                            stream: selectIndexStream,
                                            builder: (context, snapshot) {
                                              if (snapshot.data == null) {
                                                return Container();
                                              }
                                              return CachedNetworkImage(
                                                height: 100,
                                                alignment: Alignment.center,
                                                imageUrl: snapshot.data == 0 ? model.aiThumbnail : model.thumbnail,
                                                fit: BoxFit.cover,
                                                progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                                                  alignment: Alignment.center,
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                                ),
                                                errorWidget: (context, url, error) => Container(
                                                  alignment: Alignment.center,
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: const Icon(Icons.error),
                                                ),
                                              );
                                            }),
                                      ),
                                      SizedBox(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(PublicData.getTimeForm(model.startDatetime)),
                                            const Icon(Icons.arrow_right),
                                            Text(PublicData.getTimeForm(model.endDatetime)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      )

                      // ListView.builder(
                      //   scrollDirection: Axis.horizontal,
                      //   itemCount: state.videoRecordMap.length,
                      //   shrinkWrap: true,
                      //   itemBuilder: (context, index) {
                      //     VideoRecordViewModel model = state.videoRecordMap.values.toList()[index];
                      //     return Text(model.thumbnail);
                      //   },
                      // ),
                      );
                }
              default:
                {
                  return Container();
                }
            }
          },
        ),
      ],
    );
  }
}
