import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../../../utils/api/config.dart';
import '../../../../utils/bloc/incident_bloc/incident_bloc.dart';
import '../../../../utils/bloc/incident_camera_bloc/incident_camera_bloc.dart';
import '../../../../utils/bloc/video_bloc/video_bloc.dart';
import '../../../../utils/entity/incident.dart';
import '../../../../utils/public/color_theme.dart';
import '../../../../utils/public/public_data.dart';
import '../../../../utils/public/text_style.dart';


class VideoIncidentDetail extends StatefulWidget {
  IncidentEntity? entity;
  VideoIncidentDetail(this.entity, {super.key});

  @override
  State<VideoIncidentDetail> createState() => _VideoIncidentDetailState();
}

class _VideoIncidentDetailState extends State<VideoIncidentDetail> {
  VideoBloc videoBloc = VideoBloc();
  String stateName = '';

  @override
  void initState() {
    stateName = PublicData.stateListName[widget.entity!.state];
    print('播放-${Config.realTimeVideoIP}/${widget.entity!.id}-ai/livestream/index.m3u8');
    videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${widget.entity!.id}-ai/livestream/index.m3u8', isLive: true));
    super.initState();
  }

  Future<void> _showEditDialog(IncidentEntity entity) async {
    await showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Container(
            width: 810,
            height: 620,
            decoration: BoxDecoration(
              border: Border.all(
                color: MyColorTheme.white,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(5),
              color: MyColorTheme.black,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '編輯異常',
                        style: TextStyle(fontSize: MyTextStyle.text_16, color: MyColorTheme.white),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(
                            Icons.close,
                            color: MyColorTheme.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: MyColorTheme.white,
                  thickness: 1,
                ),
                BlocConsumer<IncidentCameraBloc, IncidentCameraState>(
                  buildWhen: (previous, current) {
                    if (previous.runtimeType == IncidentCameraEditingState && current.runtimeType == IncidentShowingState) {
                      Fluttertoast.showToast(
                        msg: "更新成功",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 3,
                      );
                    }
                    if (previous.runtimeType == IncidentEditingState && current.runtimeType == IncidentEditErrorState) {
                      Fluttertoast.showToast(
                        msg: "更新失敗",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 3,
                      );
                    }
                    return true;
                  },
                  listener: (context, state) {},
                  builder: (context, state) {
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        child: Wrap(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '異常類型',
                                          style: TextStyle(color: MyColorTheme.white),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        TextFormField(
                                          maxLines: 1,
                                          enabled: false,
                                          readOnly: true,
                                          textInputAction: TextInputAction.done,
                                          cursorColor: MyColorTheme.white,
                                          style: const TextStyle(color: MyColorTheme.white),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                            ),
                                            labelText: entity.title,
                                            labelStyle: const TextStyle(color: MyColorTheme.white),
                                            floatingLabelBehavior: FloatingLabelBehavior.never,

                                            // // 未獲得焦點時的邊框樣式
                                            // enabledBorder: OutlineInputBorder(
                                            //   borderRadius: BorderRadius.circular(5), // 邊框圓角
                                            //   borderSide: const BorderSide(color: Colors.grey, width: 1), // 邊框顏色和寬度
                                            // ),

                                            // 獲得焦點時的邊框樣式
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: Colors.black, width: 1),
                                            ),

                                            // 錯誤狀態時的邊框樣式
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: Colors.red, width: 2),
                                            ),

                                            // 錯誤且獲得焦點時的邊框樣式
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: Colors.red, width: 2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '處理狀態',
                                          style: TextStyle(color: MyColorTheme.white),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        DropdownButtonFormField<String>(
                                          value: stateName, // 預設值
                                          onChanged: (value) {
                                            stateName = value!;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return '請選擇一個選項';
                                            }
                                            return null;
                                          },
                                          items: PublicData.stateListName.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(color: MyColorTheme.white),
                                              ),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                            ),
                                            labelText: stateName,
                                            labelStyle: const TextStyle(color: MyColorTheme.white),
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
                                          dropdownColor: MyColorTheme.black, // 下拉選單背景色
                                          style: const TextStyle(color: MyColorTheme.white),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '異常時間',
                                          style: TextStyle(color: MyColorTheme.white),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        TextFormField(
                                          maxLines: 1,
                                          enabled: false,
                                          readOnly: true,
                                          textInputAction: TextInputAction.done,
                                          cursorColor: MyColorTheme.white,
                                          style: const TextStyle(color: MyColorTheme.white),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                            ),
                                            labelText: DateFormat('yyyy/MM/dd HH:mm').format(
                                              DateTime.fromMillisecondsSinceEpoch(entity.createDatetime),
                                            ),
                                            labelStyle: const TextStyle(color: MyColorTheme.white),
                                            floatingLabelBehavior: FloatingLabelBehavior.never,

                                            // // 未獲得焦點時的邊框樣式
                                            // enabledBorder: OutlineInputBorder(
                                            //   borderRadius: BorderRadius.circular(5), // 邊框圓角
                                            //   borderSide: const BorderSide(color: Colors.grey, width: 1), // 邊框顏色和寬度
                                            // ),

                                            // 獲得焦點時的邊框樣式
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: Colors.black, width: 1),
                                            ),

                                            // 錯誤狀態時的邊框樣式
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: Colors.red, width: 2),
                                            ),

                                            // 錯誤且獲得焦點時的邊框樣式
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: Colors.red, width: 2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Container(),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(flex: 1, child: Container()),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 1,
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          // print('更新異常------${entity.id}---${entity.title}---${stateListName.indexOf(stateName)}---${entity.isPinned}');
                                          context.read<IncidentBloc>().add(UpdateIncidentEvent(isEdit: true, incidentId: entity.id, state: PublicData.stateListName.indexOf(stateName), isPinned: entity.isPinned));
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: MyColorTheme.white,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text('送出'),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    // switch (state.runtimeType) {
                    //   case AccountInitialState:
                    //   case AccountLoadingState:
                    //   case AccountEditingState:
                    //     {
                    //       return Expanded(
                    //         child: Container(
                    //           width: MediaQuery.of(context).size.width,
                    //           margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    //           decoration: BoxDecoration(
                    //             color: Colors.transparent,
                    //             borderRadius: BorderRadius.circular(10),
                    //             border: Border.all(color: Colors.grey.shade300, width: 1),
                    //           ),
                    //           child: const Center(
                    //             child: CircularProgressIndicator(),
                    //           ),
                    //         ),
                    //       );
                    //     }
                    //   case AccountShowingState:
                    //     {

                    //     }
                    //   default:
                    //     {
                    //       return Container();
                    //     }
                    // }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 @override
  void dispose() {
    videoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncidentBloc, IncidentState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType == IncidentEditingState && current.runtimeType == IncidentShowingState) {
          Navigator.of(context).pop();
        }
        return true;
      },
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(10),
          height: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.entity?.title ?? ''),
                  Row(
                    children: [
                      const Text('攝影機IP'),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          List<String> parts = PublicData.splitByFirstSlash(widget.entity!.videoUrl);
                          print('videoUrl---cameraId:${widget.entity!.id}--${widget.entity?.videoUrl}----${parts[1]}');
                          String fireUrl = '${Config.recordsVideoIP}/api/mp4?cameraId=${widget.entity!.id}-ai&hlsFile=${parts[1]}';
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
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 300,
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
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('異常類型'),
                              Text(widget.entity?.title ?? ''),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('處理狀態'),
                              Text(stateName),
                            ],
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                _showEditDialog(widget.entity!);
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
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('異常時間'),
                          Text(
                            DateFormat('yyyy/MM/dd HH:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(widget.entity?.createDatetime ?? 0),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
