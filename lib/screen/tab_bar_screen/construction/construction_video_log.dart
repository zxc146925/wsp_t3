import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

import 'package:wsp_t3/utils/bloc/location_camera_bloc/location_camera_bloc.dart';
import 'package:wsp_t3/utils/public/public_data.dart';

import '../../../utils/api/config.dart';
import '../../../utils/bloc/location_camera_record_bloc/location_camera_record_bloc.dart';
import '../../../utils/bloc/login_bloc/login_bloc.dart';
import '../../../utils/bloc/video_bloc/video_bloc.dart';
import '../../../utils/entity/camera.dart';
import '../../../utils/entity/location.dart';
import '../../../utils/entity/location_camera_record.dart';
import '../../../utils/public/color_theme.dart';

class ConstructionVideoLog extends StatefulWidget {
  LocationEntity locationEntity;
  ConstructionVideoLog({
    super.key,
    required this.locationEntity,
  });

  @override
  State<ConstructionVideoLog> createState() => _ConstructionVideoLogState();
}

class _ConstructionVideoLogState extends State<ConstructionVideoLog> {
  BehaviorSubject<int> selectIndexStream = BehaviorSubject<int>.seeded(0);
  BehaviorSubject<String> selectCameraStream = BehaviorSubject<String>.seeded('');
  VideoBloc videoBloc = VideoBloc();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      // selectCameraStream.add(cameraMap.values.first.name);
      // 初始化
      if (context.read<LocationCameraBloc>().state.cameraMap.isNotEmpty) {
        print('初始化-----------------------------');
        selectCameraStream.add(context.read<LocationCameraBloc>().state.cameraMap.values.first.id);
        context.read<LocationCameraRecordBloc>().add(
              LocationCameraRecordInitialEvent(
                skip: 0,
                size: 50,
                locationId: widget.locationEntity.id!,
                cameraId: context.read<LocationCameraBloc>().state.cameraMap.values.first.id,
              ),
            );
      }
      // print('selectCameraStream----${selectCameraStream.value}');
    });
  }

  @override
  void dispose() {
    videoBloc.close();
    super.dispose();
  }

  // 當按鈕被點擊時，更新選中的索引
  void _onButtonPressed(int index) {
    selectIndexStream.add(index);
    if (index == 0) {
      // index == 0 (辨識影像)
      if (context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.isNotEmpty) {
        videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.aiFilename}', isLive: false));
      } else {
        videoBloc.add(VideoLoadEvent('', isLive: false));
      }
    } else {
      // index == 1 (原始影像)
      if (context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.isNotEmpty) {
        videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.filename}', isLive: false));
      } else {
        videoBloc.add(VideoLoadEvent('', isLive: false));
      }
    }
  }

  Widget _buildButton(int index, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: StreamBuilder<int>(
          stream: selectIndexStream,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container();
            }
            return ElevatedButton(
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
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 獲取畫面寬度
    const screenWidth = 670;
    const maxItemsPerRow = 3; // 每行最多顯示的物件數
    const itemWidth = screenWidth / maxItemsPerRow; // 動態計算物件寬度
    if (context.read<LocationCameraBloc>().state.cameraMap.isEmpty) {
      return const Center(
        child: Text('暫無影像紀錄'),
      );
    }
    return Column(
      children: [
        DropdownButtonFormField<CameraEntity>(
          value: context.read<LocationCameraBloc>().state.cameraMap.values.first,
          onChanged: (entity) {
            context.read<LocationCameraRecordBloc>().add(
                  LocationCameraRecordInitialEvent(
                    skip: 0,
                    size: 50,
                    locationId: widget.locationEntity.id!,
                    cameraId: entity!.id,
                  ),
                );
          },
          validator: (value) {
            if (value == null) {
              return '請選擇一個選項';
            }
            return null;
          },
          items: context.read<LocationCameraBloc>().state.cameraMap.values.toList().map((CameraEntity entity) {
            return DropdownMenuItem<CameraEntity>(
              value: entity,
              child: Text(
                entity.name,
                style: const TextStyle(color: MyColorTheme.black),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
            ),
            labelText: '請選擇一個選項',
            labelStyle: const TextStyle(color: MyColorTheme.black),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          dropdownColor: MyColorTheme.white, // 下拉選單背景色
          style: const TextStyle(color: MyColorTheme.black),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildButton(0, '辨識影像'),
                _buildButton(1, '原始影像'),
              ],
            ),
            context.read<LoginBloc>().state.userEntity!.permission == 0
                ? Container()
                : MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        List<String> parts = [];

                        //     thumbnail: '${Config.mediaSocketUrl}/file/${locationCamerRecordItem['thumbnail']}',
                        //     aiThumbnail: '${Config.mediaSocketUrl}/file/${locationCamerRecordItem['aiThumbnail']}',
                        //     filename: '${Config.recordsVideoIP}/records/${locationCamerRecordItem['filename']}',
                        //     aiFilename: '${Config.recordsVideoIP}/records/${locationCamerRecordItem['aiFilename']}',
                        //     startDatetime: locationCamerRecordItem['startDatetime'],
                        //     endDatetime: locationCamerRecordItem['startDatetime'] + 3600000, // 加一小時
                        if (selectIndexStream.value == 0) {
                          // 辨識
                          if (context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.isNotEmpty) {
                            print('下載辨識有資料---${context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.aiFilename}');
                            parts = PublicData.splitByFirstSlash(context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.aiFilename);
                          } else {
                            print('下載辨識沒有資料---');

                            parts = PublicData.splitByFirstSlash('');
                          }
                        } else {
                          // 原始
                          if (context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.isNotEmpty) {
                            print('下載原始有資料---${context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.filename}');
                            parts = PublicData.splitByFirstSlash(context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.filename);
                          } else {
                            print('下載原始沒有資料---');
                            parts = PublicData.splitByFirstSlash('');
                          }
                        }
                        String fireUrl = '${Config.recordsVideoIP}/api/mp4?cameraId=${selectCameraStream.value}-ai&hlsFile=${parts[1]}';
                        String fileName = parts[1];
                        PublicData.directDownload(fireUrl, fileName);
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          color: MyColorTheme.black,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.file_download_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        BlocConsumer<VideoBloc, VideoState>(
          bloc: videoBloc,
          listener: (context, videoState) {},
          builder: (context, videoState) {
            if (videoState is VideoLoading || videoState is VideoInitial) {
              return Container(
                alignment: Alignment.center,
                height: 400,
                color: MyColorTheme.black,
                child: const CircularProgressIndicator(),
              );
            } else if (videoState is VideoLoaded) {
              // 添加一个状态变量，用于控制播放按钮的显示和隐藏
              bool showPlayButton = !videoState.controller.value.isPlaying;
              // final position = videoState.controller.value.position;
              // final duration = videoState.duration ?? Duration.zero;
              // final sliderValue = position.inSeconds.toDouble();
              // final maxSliderValue = duration.inSeconds.toDouble();
              return Column(
                children: [
                  Stack(
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.black.withOpacity(0.5), // 半透明背景
                                ),
                                child: Icon(
                                  videoState.controller.value.isPlaying
                                      ? Icons.pause // 播放时显示暂停键
                                      : Icons.play_arrow, // 暂停时显示播放键
                                  color: Colors.white,
                                  size: 100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  //   child: Row(
                  //     children: [
                  //       // 當前播放時間
                  //       Text(PublicData.formatDuration(position)),
                  //       Expanded(
                  //         child: Slider(
                  //           value: sliderValue.clamp(0, maxSliderValue),
                  //           max: maxSliderValue,
                  //           onChanged: (value) {
                  //             // 使用者拖拉 Slider 時，派發 VideoSeekEvent
                  //             videoBloc.add(VideoSeekEvent(Duration(seconds: value.toInt())));
                  //           },
                  //         ),
                  //       ),
                  //       // 影片總長度
                  //       Text(PublicData.formatDuration(duration)),
                  //     ],
                  //   ),
                  // ),
                ],
              );
            } else if (videoState is VideoError) {
              return Container(
                alignment: Alignment.center,
                height: 400,
                color: MyColorTheme.black,
                child: const Text(
                  // state.message,
                  '目前影片來源出有誤', style: TextStyle(color: MyColorTheme.white),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
        // Container(
        //   alignment: Alignment.center,
        //   height: 50,
        //   child: const Text('保留進度條'),
        // ),
        // const SizedBox(
        //   height: 20,
        // ),
        const Divider(
          height: 1,
        ),
        const SizedBox(
          height: 20,
        ),
        Flexible(
          child: BlocConsumer<LocationCameraRecordBloc, LocationCameraRecordState>(
            buildWhen: (previous, current) {
              print('previous.runtimeType---${previous.runtimeType}-----current.runtimeType:${current.runtimeType}-------${previous.runtimeType == LocationCameraRecordLoading && current.runtimeType == LocationCameraRecordInitialComplete}');
              if (previous.runtimeType == LocationCameraRecordLoading && current.runtimeType == LocationCameraRecordInitialComplete) {
                // 初始化完成
                print('初始播放－－－－－－－－－－－－－－－－${context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.filename}');
                if (selectIndexStream.value == 0) {
                  // 辨識
                  if (context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.isNotEmpty) {
                    videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.aiFilename}', isLive: false));
                  } else {
                    videoBloc.add(VideoLoadEvent('', isLive: false));
                  }
                } else {
                  // 原始
                  if (context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.isNotEmpty) {
                    videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.filename}', isLive: false));
                  } else {
                    videoBloc.add(VideoLoadEvent('', isLive: false));
                  }
                }
              }
              return true;
            },
            listener: (context, locationCameraRecordstate) {
              // TODO: implement listener
            },
            builder: (context, locationCameraRecordstate) {
              switch (locationCameraRecordstate.runtimeType) {
                case LocationCameraRecordInitial:
                case LocationCameraRecordLoading:
                  {
                    return const Center(child: CircularProgressIndicator());
                  }
                case LocationCameraRecordReadMax:
                case LocationCameraRecordShowing:
                case LocationCameraRecordInitialComplete:
                  {
                    if (locationCameraRecordstate.locationCameraRecordMap.isEmpty) {
                      return const Center(
                        child: Text('沒有影像紀錄'),
                      );
                    }
                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 10.0, // 每個物件之間的水平間距
                        runSpacing: 10.0, // 每行之間的垂直間距
                        children: List.generate(locationCameraRecordstate.locationCameraRecordMap.length, (index) {
                          LocationCameraRecordEntity entity = locationCameraRecordstate.locationCameraRecordMap.values.toList()[index];
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                // 切換播放影片

                                if (selectIndexStream.value == 0) {
                                  // 辨識
                                  print('辨識圖片------${entity.aiThumbnail}');

                                  videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${entity.aiFilename}', isLive: false));
                                } else {
                                  // 原始
                                  print('原始圖片------${entity.thumbnail}');

                                  videoBloc.add(VideoLoadEvent('${Config.recordsVideoIP}/records/${entity.filename}', isLive: false));
                                }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: itemWidth - 20,
                                    height: 100, // 固定高度
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
                                            imageUrl: snapshot.data == 0 ? '${Config.mediaSocketUrl}/file/${entity.aiThumbnail}' : '${Config.mediaSocketUrl}/file/${entity.thumbnail}',
                                            fit: BoxFit.cover,
                                            progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              width: 400,
                                              child: Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              width: 400,
                                              child: const Icon(Icons.error),
                                            ),
                                          );
                                        }),
                                  ),
                                  SizedBox(
                                    width: itemWidth - 20,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(PublicData.getTimeForm(entity.startDatetime)),
                                        const Icon(Icons.arrow_right),
                                        Text(PublicData.getTimeForm(entity.endDatetime)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }
                default:
                  {
                    return Container();
                  }
              }
            },
          ),
        ),
        // BlocConsumer<LocationCameraRecordBloc, LocationCameraRecordState>(
        //   bucildWhen: (previous, current) {
        //     if (previous.runtimeType == LocationCameraRecordLoading && current.runtimeType == LocationCameraRecordInitialComplete) {
        //       // 初始化完成
        //       print('初始播放－－－－－－－－－－－－－－－－${context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.filename}');
        //       if (selectIndexStream.value == 0) {
        //         // 辨識
        //         videoBloc.add(VideoLoadEvent(context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.aiFilename, isLive: false));
        //       } else {
        //         // 原始
        //         videoBloc.add(VideoLoadEvent(context.read<LocationCameraRecordBloc>().state.locationCameraRecordMap.values.first.filename, isLive: false));
        //       }
        //     }
        //     return true;
        //   },
        //   listener: (context, locationCameraRecordstate) {},
        //   builder: (context, locationCameraRecordstate) {
        //     switch (locationCameraRecordstate.runtimeType) {
        //       case LocationCameraRecordInitial:
        //       case LocationCameraRecordLoading:
        //         {
        //           return const Center(child: CircularProgressIndicator());
        //         }
        //       case LocationCameraRecordReadMax:
        //       case LocationCameraRecordShowing:
        //       case LocationCameraRecordInitialComplete:
        //         {
        //           if (locationCameraRecordstate.locationCameraRecordMap.isEmpty) {
        //             return const Center(child: Text('沒有影像紀錄'));
        //           }
        //           return Wrap(
        //             spacing: 10.0, // 每個物件之間的水平間距
        //             runSpacing: 10.0, // 每行之間的垂直間距
        //             children: List.generate(locationCameraRecordstate.locationCameraRecordMap.length, (index) {

        //             }),
        //           );
        //         }
        //       default:
        //         {
        //           return Container();
        //         }
        //     }
        //   },
        // ),
      ],
    );
  }
}
