import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:rxdart/subjects.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:wsp_t3/utils/bloc/smart_chat_bloc/smart_chat_bloc.dart';
import 'package:wsp_t3/utils/public/color_theme.dart';
import '../../../utils/api/config.dart';
import '../../../utils/bloc/camera_manager_bloc/camera_manager_bloc.dart';
import '../../../utils/bloc/engineering_bloc/engineering_bloc.dart';
import '../../../utils/bloc/history_bloc/history_bloc.dart';
import '../../../utils/bloc/incident_bloc/incident_bloc.dart';
import '../../../utils/bloc/location_camera_bloc/location_camera_bloc.dart';
import '../../../utils/bloc/login_bloc/login_bloc.dart';
import '../../../utils/bloc/notification_bloc/notification_bloc.dart';
import '../../../utils/bloc/speech_to_text_bloc/speech_to_text_bloc.dart';
import '../../../utils/bloc/video_bloc/video_bloc.dart';
import '../../../utils/entity/history.dart';
import '../../../utils/entity/message.dart';
import '../../../utils/entity/notification.dart';
import '../../../utils/public/appbar_shadow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/public/public_data.dart';
import '../../../utils/public/speech_bubble.dart';
import '../../../utils/public/text_style.dart';
import '../../../utils/socket/media_service.dart';
import '../../../utils/view_model/incident_list.dart';
import 'smart_drawer.dart';

class SmartChatScreen extends StatefulWidget {
  const SmartChatScreen({super.key});

  @override
  State<SmartChatScreen> createState() => _SmartChatScreenState();
}

class _SmartChatScreenState extends State<SmartChatScreen> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _containerKey = GlobalKey(); // 創建 GlobalKey
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final FlutterTts flutterTts = FlutterTts();

  OverlayEntry? _overlayEntry; // 泡泡提示的 OverlayEntry
  final String _detectedText = ''; // 偵測到的文字
  final List<String> _logs = []; // 保存語音結果的 Log 列表
  final BehaviorSubject<String> openDrawerTitleStream = BehaviorSubject<String>.seeded('');

  @override
  void initState() {
    super.initState();
    print('智慧助理');
    // 為了給帳號管理使用，怕如果沒到案場，就不會觸發
    context.read<EngineeringBloc>().add(RefreshEngineeringEvent(skip: 0, size: 10, userId: context.read<LoginBloc>().state.userEntity!.id));

    context.read<HistoryBloc>().add(HistoryInitEvent(skip: 0, size: 20, userId: context.read<LoginBloc>().state.userEntity!.id));
    final socketService = SocketService();
    socketService.init(Config.mediaSocketUrl);
    socketService.connect(context.read<LoginBloc>().state.userEntity!.id);

    context.read<NotificationBloc>().add(
          NotificationInitEvent(
            skip: 0,
            size: 10,
            userId: context.read<LoginBloc>().state.userEntity!.id,
          ),
        );

    // _scrollController.addListener(
    //   () {
    //     if (_scrollController.position.pixels >= _scrollController.position.minScrollExtent - 100 && context.read<SmartChatBloc>().state.runtimeType != SmartChatLoadMoreMaxState) {
    //       context.read<SmartChatBloc>().add(SmartChatOpenHistoryContentLoadMoreEvent(skip: context.read<SmartChatBloc>().state.historySmartChatMap.length, size: 20));
    //     }
    //   },
    // );

    socketService.on('notification', (msg) async {
      // print('notification----$msg');
      final message = msg['message'];
      NotificationEntity entity = NotificationEntity.fromJson(message);
      context.read<NotificationBloc>().add(NotificationAddEvent(entity));
    });

    socketService.on('incident', (msg) async {
      print('incident----$msg');
      final message = msg['message'];
      if (context.read<IncidentBloc>().state.incidentMap.containsKey(message['id'])) {
        context.read<IncidentBloc>().state.incidentMap.update(
              message['id'],
              (value) => IncidentListViewModel(
                id: value.id,
                title: value.title,
                cameraId: value.cameraId,
                cameraName: value.cameraName,
                createDatetime: value.createDatetime,
                isPinned: value.isPinned,
                locationName: value.locationName,
                time: value.time,
                videoUrl: value.videoUrl,
                state: message['state'],
              ),
            );
      }
      // context.read<IncidentBloc>().add(UpdateIncidentEvent(isEdit: true, incidentId: message['id'], state: message['state'], isPinned: false));
    });

    socketService.on('camera', (msg) async {
      print('收到攝影機消息：$msg');
      final message = msg['message'];

      context.read<CameraManagerBloc>().add(
            CameraManagerSocketUpdateEvent(
              id: message['id'],
              name: message['name'],
              ip: message['ip'],
              port: message['port'],
              protocol: message['protocol'],
              state: message['state'],
              web: message['web'],
              urlPath: message['urlPath'],
              account: message['account'],
              password: message['password'],
            ),
          );

      context.read<LocationCameraBloc>().add(
            UpdateLocationCameraStateEvent(
              id: message['id'],
              name: message['name'],
              ip: message['ip'],
              port: message['port'],
              protocol: message['protocol'],
              state: message['state'],
              web: message['web'],
              urlPath: message['urlPath'],
              account: message['account'],
              password: message['password'],
            ),
          );
    });

    socketService.on('message', (msg) async {
      print('收到消息：$msg');

      final message = msg['message'];
      if (message['chatroomId'] == context.read<SmartChatBloc>().state.chatRoomId.value) {
        if (message['type'] == 'text') {
          MessageEntity responseData = MessageEntity.fromJson(message);
          context.read<SmartChatBloc>().add(SmartChatReponseMessage(responseData));
        } else {
          print('目前是圖片/影片');
          String content = message['content'];
          if (PublicData.hasErrorMessage(content)) {
            MessageEntity responseData = MessageEntity(
              id: message['id'],
              content: message['content'],
              chatroomId: message['chatroomId'],
              senderId: message['senderId'],
              createDatetime: message['createDatetime'],
              type: 'text',
            );
            context.read<SmartChatBloc>().add(SmartChatReponseMessage(responseData));
          } else {
            final payloadString = message['payload'];
            print('目前是payloadString---$payloadString');
            final payloadObject = jsonDecode(payloadString)['context']['result'][0]['incident'];

            // print('payloadObject---${payloadObject['videoUrl']}');
            List<String> parts = PublicData.splitByFirstSlash(payloadObject['videoUrl']);

            MessageEntity responseData = MessageEntity(
              id: message['id'] ?? '',
              createDatetime: message['createDatetime'] ?? 0,
              content: message['content'] ?? '',
              type: message['type'] ?? '',
              // data: message['data'] ?? '',
              chatroomId: message['chatroomId'] ?? '',
              senderId: message['senderId'] ?? '',
              imageUrl: payloadObject['imageUrl'] ?? '',
              videoUrl: 'records/${parts[0]}-ai/${parts[1]}' ?? '',
              fileUrl: payloadObject['fileUrl'] ?? '',
            );
            context.read<SmartChatBloc>().add(SmartChatReponseMessage(responseData));
          }
        }
        _scrollToAnimatedMessage();
      }
    });
  }

  /// 用於滾動到 ListView 的最底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // 使用 animateTo 可以讓滾動過程有動畫效果
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 語音設定
  void _speak(String translatedText) async {
    flutterTts.stop();
    await flutterTts.setLanguage("zh-TW");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.speak(translatedText);
  }

  // 取得檔案副檔名
  String getFileExtension() {
    return path.extension('test').toLowerCase();
  }

  Widget _buildResponseAnimationType(MessageEntity isGTPMessage) {
    if (isGTPMessage.type == 'text') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedTextKit(
            key: const ValueKey(1),
            animatedTexts: [
              TypewriterAnimatedText(
                isGTPMessage.content ?? '',
                textAlign: TextAlign.start,
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                speed: const Duration(milliseconds: 30),
              ),
            ],
            repeatForever: false, // 确保不重复播放
            totalRepeatCount: 1,

            onFinished: () {
              _scrollToAnimatedMessage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () {
              _speak(isGTPMessage.content ?? '');
            },
          ),
        ],
      );
    } else if (isGTPMessage.type == 'image') {
      print('-------------AnimationType----------${Config.mediaSocketUrl}/file/${isGTPMessage.imageUrl}');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 600,
            height: 400,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Image.network(
              '${Config.mediaSocketUrl}/file/${isGTPMessage.imageUrl}',
              fit: BoxFit.cover,
            ),
          ),
          AnimatedTextKit(
            key: const ValueKey(1),
            animatedTexts: [
              TypewriterAnimatedText(
                isGTPMessage.content ?? '',
                textAlign: TextAlign.start,
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                speed: const Duration(milliseconds: 30),
              ),
            ],
            repeatForever: false, // 确保不重复播放
            totalRepeatCount: 1,

            onFinished: () {
              _scrollToAnimatedMessage();
            },
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_rounded),
                onPressed: () {
                  _speak(isGTPMessage.content ?? '');
                },
              ),
              // GestureDetector(
              //   onTap: () {
              //     directDownload(isGTPMessage.image_url!);
              //   },
              //   child: Container(
              //     width: 35,
              //     height: 35,
              //     decoration: BoxDecoration(
              //       color: Colors.black,
              //       borderRadius: BorderRadius.circular(50),
              //     ),
              //     child: const Icon(
              //       Icons.file_download_outlined,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      );
    } else if (isGTPMessage.type == 'video') {
      print('目前是Video----${Config.recordsVideoIP}/${isGTPMessage.videoUrl!}');
      return BlocProvider(
        create: (context) => VideoBloc()..add(VideoLoadEvent('${Config.recordsVideoIP}/${isGTPMessage.videoUrl!}', isLive: true)),
        child: BlocConsumer<VideoBloc, VideoState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is VideoLoading) {
              return const SizedBox(
                width: 600,
                height: 400,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is VideoLoaded) {
              // 添加一个状态变量，用于控制播放按钮的显示和隐藏
              bool showPlayButton = !state.controller.value.isPlaying;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 600,
                        height: 400,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Image.network(
                          '${Config.mediaSocketUrl}/file/${isGTPMessage.imageUrl}',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        isGTPMessage.content,
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.left, // 文字靠右對齊
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded),
                            onPressed: () {
                              _speak(isGTPMessage.content ?? '');
                            },
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     directDownload(isGTPMessage.image_url!);
                          //   },
                          //   child: Container(
                          //     width: 35,
                          //     height: 35,
                          //     decoration: BoxDecoration(
                          //       color: Colors.black,
                          //       borderRadius: BorderRadius.circular(50),
                          //     ),
                          //     child: const Icon(
                          //       Icons.file_download_outlined,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 600,
                    height: 400,
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
                              final videoBloc = context.read<VideoBloc>();
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
                              final videoBloc = context.read<VideoBloc>();
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
                  ),
                  AnimatedTextKit(
                    key: const ValueKey(1),
                    animatedTexts: [
                      TypewriterAnimatedText(
                        isGTPMessage.content ?? '',
                        textAlign: TextAlign.start,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        speed: const Duration(milliseconds: 30),
                      ),
                    ],
                    repeatForever: false, // 确保不重复播放
                    totalRepeatCount: 1,

                    onFinished: () {
                      _scrollToAnimatedMessage();
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded),
                        onPressed: () {
                          _speak(isGTPMessage.content ?? '');
                        },
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     directDownload(isGTPMessage.video_url!);
                      //   },
                      //   child: Container(
                      //     width: 35,
                      //     height: 35,
                      //     decoration: BoxDecoration(
                      //       color: Colors.black,
                      //       borderRadius: BorderRadius.circular(50),
                      //     ),
                      //     child: const Icon(
                      //       Icons.file_download_outlined,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              );
            } else if (state is VideoError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 600,
                        height: 400,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Image.network(
                          '${Config.mediaSocketUrl}/file/${isGTPMessage.imageUrl}',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        isGTPMessage.content,
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.left, // 文字靠右對齊
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded),
                            onPressed: () {
                              _speak(isGTPMessage.content ?? '');
                            },
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     directDownload(isGTPMessage.image_url!);
                          //   },
                          //   child: Container(
                          //     width: 35,
                          //     height: 35,
                          //     decoration: BoxDecoration(
                          //       color: Colors.black,
                          //       borderRadius: BorderRadius.circular(50),
                          //     ),
                          //     child: const Icon(
                          //       Icons.file_download_outlined,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 600,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: MyColorTheme.black.withOpacity(0.5),
                    ),
                    child: const Center(
                      child: Text(
                        '目前影片來源出有誤',
                        style: TextStyle(color: MyColorTheme.white),
                      ),
                    ),
                  ),
                  AnimatedTextKit(
                    key: const ValueKey(1),
                    animatedTexts: [
                      TypewriterAnimatedText(
                        isGTPMessage.content ?? '',
                        textAlign: TextAlign.start,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        speed: const Duration(milliseconds: 30),
                      ),
                    ],
                    repeatForever: false, // 确保不重复播放
                    totalRepeatCount: 1,

                    onFinished: () {
                      _scrollToAnimatedMessage();
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded),
                        onPressed: () {
                          _speak(isGTPMessage.content ?? '');
                        },
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     directDownload(isGTPMessage.image_url!);
                      //   },
                      //   child: Container(
                      //     width: 35,
                      //     height: 35,
                      //     decoration: BoxDecoration(
                      //       color: Colors.black,
                      //       borderRadius: BorderRadius.circular(50),
                      //     ),
                      //     child: const Icon(
                      //       Icons.file_download_outlined,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // 阴影颜色
                    blurRadius: 10, // 阴影模糊半径
                    offset: const Offset(2, 4), // 阴影的偏移量
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_outlined),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: const Text(
                        '日違規統計表',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      PublicData.directDownload(isGTPMessage.fileUrl!, isGTPMessage.fileUrl!.split('/').last);
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.file_download_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            isGTPMessage.content,
            style: const TextStyle(color: Colors.black),
            textAlign: TextAlign.left, // 文字靠右對齊
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () {
              _speak(isGTPMessage.content);
            },
          ),
        ],
      );
    }
    _scrollToAnimatedMessage();
  }

  Widget _buildResponseType(MessageEntity isGTPMessage) {
    if (isGTPMessage.type == 'text') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            isGTPMessage.content,
            style: const TextStyle(color: Colors.black),
            textAlign: TextAlign.left, // 文字靠右對齊
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_rounded),
                onPressed: () {
                  _speak(isGTPMessage.content);
                },
              ),
            ],
          ),
        ],
      );
    } else if (isGTPMessage.type == 'image') {
      print('-----------------------${Config.mediaSocketUrl}/file/${isGTPMessage.imageUrl}');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 600,
            height: 400,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Image.network(
              '${Config.mediaSocketUrl}/file/${isGTPMessage.imageUrl}',
              fit: BoxFit.cover,
            ),
          ),
          SelectableText(
            isGTPMessage.content,
            style: const TextStyle(color: Colors.black),
            textAlign: TextAlign.left, // 文字靠右對齊
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_rounded),
                onPressed: () {
                  _speak(isGTPMessage.content ?? '');
                },
              ),
              // GestureDetector(
              //   onTap: () {
              //     directDownload(isGTPMessage.image_url!);
              //   },
              //   child: Container(
              //     width: 35,
              //     height: 35,
              //     decoration: BoxDecoration(
              //       color: Colors.black,
              //       borderRadius: BorderRadius.circular(50),
              //     ),
              //     child: const Icon(
              //       Icons.file_download_outlined,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      );
    } else if (isGTPMessage.type == 'video') {
      print('目前是Video----${Config.recordsVideoIP}/${isGTPMessage.videoUrl!}');
      return BlocProvider(
        create: (context) => VideoBloc()..add(VideoLoadEvent('${Config.recordsVideoIP}/${isGTPMessage.videoUrl!}', isLive: true)),
        child: BlocConsumer<VideoBloc, VideoState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is VideoLoading) {
              return const SizedBox(
                width: 600,
                height: 400,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is VideoLoaded) {
              // 添加一个状态变量，用于控制播放按钮的显示和隐藏
              bool showPlayButton = !state.controller.value.isPlaying;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 600,
                        height: 400,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Image.network(
                          '${Config.mediaSocketUrl}/file/${isGTPMessage.imageUrl}',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SelectableText(
                        isGTPMessage.content,
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.left, // 文字靠右對齊
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded),
                            onPressed: () {
                              _speak(isGTPMessage.content ?? '');
                            },
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     directDownload(isGTPMessage.image_url!);
                          //   },
                          //   child: Container(
                          //     width: 35,
                          //     height: 35,
                          //     decoration: BoxDecoration(
                          //       color: Colors.black,
                          //       borderRadius: BorderRadius.circular(50),
                          //     ),
                          //     child: const Icon(
                          //       Icons.file_download_outlined,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 600,
                    height: 400,
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
                              final videoBloc = context.read<VideoBloc>();
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
                              final videoBloc = context.read<VideoBloc>();
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
                  ),
                  SelectableText(
                    isGTPMessage.content,
                    style: const TextStyle(color: Colors.black),
                    textAlign: TextAlign.left, // 文字靠右對齊
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded),
                        onPressed: () {
                          _speak(isGTPMessage.content ?? '');
                        },
                      ),
                    ],
                  ),
                ],
              );
            } else if (state is VideoError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 600,
                        height: 400,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Image.network(
                          '${Config.mediaSocketUrl}/file/${isGTPMessage.imageUrl}',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SelectableText(
                        isGTPMessage.content,
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.left, // 文字靠右對齊
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded),
                            onPressed: () {
                              _speak(isGTPMessage.content ?? '');
                            },
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     directDownload(isGTPMessage.image_url!);
                          //   },
                          //   child: Container(
                          //     width: 35,
                          //     height: 35,
                          //     decoration: BoxDecoration(
                          //       color: Colors.black,
                          //       borderRadius: BorderRadius.circular(50),
                          //     ),
                          //     child: const Icon(
                          //       Icons.file_download_outlined,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 600,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: MyColorTheme.black.withOpacity(0.5),
                    ),
                    child: const Center(
                      child: Text(
                        '目前影片來源出有誤',
                        style: TextStyle(color: MyColorTheme.white),
                      ),
                    ),
                  ),
                  SelectableText(
                    isGTPMessage.content,
                    style: const TextStyle(color: Colors.black),
                    textAlign: TextAlign.left, // 文字靠右對齊
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // 阴影颜色
                    blurRadius: 10, // 阴影模糊半径
                    offset: const Offset(2, 4), // 阴影的偏移量
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_outlined),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: const Text(
                        '日違規統計表',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      PublicData.directDownload(isGTPMessage.fileUrl!, isGTPMessage.fileUrl!.split('/').last);
                    },
                    child: Container(
                      width: 35,
                      height: 35,
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
              ),
            ),
          ),
          Text(
            isGTPMessage.content,
            style: const TextStyle(color: Colors.black),
            textAlign: TextAlign.left, // 文字靠右對齊
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_rounded),
                onPressed: () {
                  _speak(isGTPMessage.content ?? '');
                },
              ),
              GestureDetector(
                onTap: () {
                  PublicData.directDownload(isGTPMessage.fileUrl!, isGTPMessage.fileUrl!.split('/').last);
                },
                child: Container(
                  width: 35,
                  height: 35,
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
          ),
        ],
      );
    }
    _scrollToAnimatedMessage();
  }

  void sendMessage(String message) {
    _textController.text = message;
    context.read<SmartChatBloc>().add(SmartChatSendMessage(
          message: message,
          userId: context.read<LoginBloc>().state.userEntity!.id,
        ));
    _textController.clear();
    _scrollToAnimatedMessage();
  }

  void _scrollToAnimatedMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 建立泡泡提示
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            _removeOverlay(); // 點選泡泡外部關閉
          },
          behavior: HitTestBehavior.translucent,
          child: SpeechBubble(
            onStop: () {
              context.read<SpeechToTextBloc>().add(StopListening());
              _removeOverlay();
            },
          ),
        );
      },
    );
  }

  /// 顯示泡泡提示
  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      context.read<SpeechToTextBloc>().add(StartListening());
    }
  }

  /// 移除泡泡提示
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  bool get wantKeepAlive => true;

  // @override
  // void dispose() {
  //   _textController.dispose();
  //   _scrollController.dispose();
  //   _focusNode.dispose();
  //   flutterTts.stop();
  //   _removeOverlay();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: openDrawerTitleStream.stream,
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            key: _scaffoldKey,
            endDrawer: smartDrawer(snapshot.data ?? '', context, _scaffoldKey),
            body: Stack(
              children: [
                appBarShadow(),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 100.0.h,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.notifications_none),
                                      Text(
                                        '異常通知',
                                        style: TextStyle(
                                          color: Colors.black,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // IconButton(
                                //   icon: const Icon(Icons.more_horiz),
                                //   onPressed: () {
                                //     openDrawerTitleStream.add('異常通知');
                                //     _scaffoldKey.currentState?.openEndDrawer();
                                //   },
                                // ),
                              ],
                            ),
                            BlocConsumer<NotificationBloc, NotificationState>(
                              listener: (context, notificationState) {
                                // if (notificationState.runtimeType == NotificationLoadingMoreState) {
                                //   switchPromptBoxType(type: 1, context: context, showToastText: '載入中...');
                                // }
                              },
                              builder: (context, notificationState) {
                                switch (notificationState.runtimeType) {
                                  case NotificationLoadingState:
                                    {
                                      return Expanded(
                                        flex: 5,
                                        child: Container(
                                          padding: const EdgeInsets.only(top: 10),
                                          color: Colors.transparent,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      );
                                    }
                                  case NotificationReadMoreMaxState:
                                  case NotificationLoadingMoreState:
                                  case NotificationShowingState:
                                    {
                                      return Expanded(
                                        flex: 5,
                                        child: Container(
                                          padding: const EdgeInsets.only(top: 10),
                                          color: Colors.transparent,
                                          child: notificationState.notificationMap.isEmpty
                                              ? Center(
                                                  child: Container(
                                                    child: const Text('暫無異常通知'),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  itemCount: notificationState.notificationMap.length,
                                                  shrinkWrap: true,
                                                  itemBuilder: (context, index) {
                                                    if (index > notificationState.notificationMap.length - 3 && notificationState.runtimeType != NotificationReadMoreMaxState) {
                                                      context.read<NotificationBloc>().add(
                                                            NotificationLoadMoreEvent(
                                                              skip: notificationState.notificationMap.length,
                                                              size: 10,
                                                              userId: context.read<LoginBloc>().state.userEntity!.id,
                                                            ),
                                                          );
                                                    }

                                                    NotificationEntity notificationEntity = notificationState.notificationMap.values.toList()[index];
                                                    return MouseRegion(
                                                      cursor: SystemMouseCursors.click,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          // 更新已讀
                                                          context.read<NotificationBloc>().add(
                                                                NotificationUpdateReadEvent(
                                                                  notificationId: notificationEntity.id,
                                                                  userId: context.read<LoginBloc>().state.userEntity!.id,
                                                                ),
                                                              );
                                                          // chat輸入
                                                          context.read<SmartChatBloc>().add(
                                                                SmartChatSendMessage(
                                                                  message: notificationEntity.title,
                                                                  userId: context.read<LoginBloc>().state.userEntity!.id,
                                                                ),
                                                              );
                                                        },
                                                        child: Container(
                                                          height: 60,
                                                          margin: const EdgeInsets.all(5),
                                                          decoration: BoxDecoration(
                                                            color: notificationEntity.read ? const Color.fromRGBO(220, 220, 220, 1) : Colors.white,
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: notificationEntity.read ? Colors.grey : Colors.red,
                                                                  borderRadius: const BorderRadius.only(
                                                                    topLeft: Radius.circular(10),
                                                                    bottomLeft: Radius.circular(10),
                                                                  ),
                                                                ),
                                                                width: 7,
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  alignment: Alignment.centerLeft,
                                                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                  child: Text(
                                                                    notificationEntity.title,
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(fontSize: MyTextStyle.text_16),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(right: 5, top: 5),
                                                                child: Text(
                                                                  DateFormat('MM/dd HH:mm').format(
                                                                    DateTime.fromMillisecondsSinceEpoch(notificationEntity.createDatetime),
                                                                  ),
                                                                  style: const TextStyle(fontSize: MyTextStyle.text_14),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
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
                            Container(
                              height: 2,
                              color: Colors.black,
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.schedule),
                                            SizedBox(width: 5),
                                            Text('詢問歷史', style: TextStyle(fontSize: MyTextStyle.text_18)),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.more_horiz),
                                          onPressed: () {
                                            // context.go('/download');
                                            openDrawerTitleStream.add('詢問歷史');
                                            _scaffoldKey.currentState?.openEndDrawer();
                                          },
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: BlocConsumer<HistoryBloc, HistoryState>(
                                        listener: (context, state) {},
                                        builder: (context, state) {
                                          switch (state.runtimeType) {
                                            case HistoryLoadingState:
                                              {
                                                // CircularProgressIndicator 垂直、水平居中
                                                return const Center(
                                                  child: CircularProgressIndicator(),
                                                );
                                              }
                                            case HistoryShowingState:
                                              {
                                                final showingState = state as HistoryShowingState;

                                                // 如果沒有數據，顯示居中的「暫無歷史訊息」
                                                if (showingState.historyMap.isEmpty) {
                                                  return const Center(
                                                    child: Text(
                                                      '暫無歷史訊息',
                                                      style: TextStyle(fontSize: 16),
                                                    ),
                                                  );
                                                }

                                                // 有數據時顯示列表
                                                return ListView.builder(
                                                  itemCount: showingState.historyMap.entries.take(3).length,
                                                  itemBuilder: (context, index) {
                                                    HistoryEntity historyEntity = showingState.historyMap.values.toList()[index];

                                                    return MouseRegion(
                                                      cursor: SystemMouseCursors.click,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          // print('聊天室ID:${historyEntity.id}----${historyEntity.title}');
                                                          context.read<SmartChatBloc>().add(SmartChatOpenHistoryContentEvent(skip: 0, size: 200, chatroomId: historyEntity.id));
                                                        },
                                                        child: Container(
                                                          margin: const EdgeInsets.all(5),
                                                          // decoration: const BoxDecoration(
                                                          // color: Colors.grey.shade200,
                                                          // borderRadius: BorderRadius.circular(8),
                                                          // border: Border.all(color: Colors.grey.shade300),
                                                          // ),
                                                          padding: const EdgeInsets.all(5),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                PublicData.formatRecordDate(historyEntity.createDatetime),
                                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: MyTextStyle.text_14),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Text(
                                                                historyEntity.title,
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(fontSize: MyTextStyle.text_16),
                                                              ),
                                                              // const SizedBox(height: 5),
                                                              // Text(
                                                              //   historyEntity.content,
                                                              //   style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                              // ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            default:
                                              {
                                                return const SizedBox.shrink(); // 返回一個空元件
                                              }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Container(
                          height: 100.0.h,
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          margin: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 控制內部子元素上下分布
                            children: [
                              BlocConsumer<SmartChatBloc, SmartChatState>(
                                listener: (context, state) {
                                  // print('SmartChatState listener onChange------${state.runtimeType}---${state.toString()}');
                                },
                                builder: (context, state) {
                                  switch (state.runtimeType) {
                                    case SmartChatInitialState:
                                      {
                                        return Expanded(
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      print('觸發--本日的異常事件統計---id:${context.read<LoginBloc>().state.userEntity!.id}');

                                                      context.read<SmartChatBloc>().add(
                                                            SmartChatSendMessage(
                                                              message: '本日的異常事件統計',
                                                              userId: context.read<LoginBloc>().state.userEntity!.id,
                                                            ),
                                                          );
                                                    },
                                                    child: Container(
                                                      width: 190,
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white, // 設置容器的背景顏色
                                                        borderRadius: BorderRadius.circular(10), // 圓角效果
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.2), // 陰影顏色
                                                            spreadRadius: 2, // 陰影擴散半徑
                                                            blurRadius: 10, // 陰影模糊半徑
                                                            offset: const Offset(0, 3), // 陰影偏移量 (X, Y)
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Image.asset(
                                                            'assets/date_today.png',
                                                            width: 24,
                                                            height: 24,
                                                            color: Colors.black,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          const Text(
                                                            '本日的異常事件統計',
                                                            style: TextStyle(fontSize: MyTextStyle.text_16),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      context.read<SmartChatBloc>().add(SmartChatSendMessage(
                                                            message: '本月的異常事件統計',
                                                            userId: context.read<LoginBloc>().state.userEntity!.id,
                                                          ));
                                                    },
                                                    child: Container(
                                                      width: 190,
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white, // 設置容器的背景顏色
                                                        borderRadius: BorderRadius.circular(10), // 圓角效果
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.2), // 陰影顏色
                                                            spreadRadius: 2, // 陰影擴散半徑
                                                            blurRadius: 10, // 陰影模糊半徑
                                                            offset: const Offset(0, 3), // 陰影偏移量 (X, Y)
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Image.asset(
                                                            'assets/date_range.png',
                                                            width: 24,
                                                            height: 24,
                                                            color: Colors.black,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          const Text(
                                                            '本月的異常事件統計',
                                                            style: TextStyle(fontSize: MyTextStyle.text_16),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      context.read<SmartChatBloc>().add(SmartChatSendMessage(
                                                            message: '這個月所有作業場景的',
                                                            userId: context.read<LoginBloc>().state.userEntity!.id,
                                                          ));
                                                    },
                                                    child: Container(
                                                      width: 190,
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white, // 設置容器的背景顏色
                                                        borderRadius: BorderRadius.circular(10), // 圓角效果
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.2), // 陰影顏色
                                                            spreadRadius: 2, // 陰影擴散半徑
                                                            blurRadius: 10, // 陰影模糊半徑
                                                            offset: const Offset(0, 3), // 陰影偏移量 (X, Y)
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Image.asset(
                                                            'assets/desk_alt.png',
                                                            width: 24,
                                                            height: 24,
                                                            color: Colors.black,
                                                          ),
                                                          const SizedBox(height: 10),
                                                          const Text(
                                                            '這個月所有作業場景的',
                                                            style: TextStyle(fontSize: MyTextStyle.text_16),
                                                          ),
                                                          const Text(
                                                            '各項異常事件統計',
                                                            style: TextStyle(fontSize: MyTextStyle.text_16),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    case SmartChatLoadingState:
                                    case SmartChatShowingState:
                                    case SmartChatIsMeLoadingState:
                                    case SmartChatLoadMoreState:
                                    case SmartChatLoadMoreMaxState:
                                    case SmartChatResponseLoadingState:
                                    case SmartChatMessageState:
                                      {
                                        return Expanded(
                                          child: SingleChildScrollView(
                                            controller: _scrollController,
                                            child: Column(
                                              children: [
                                                ListView.builder(
                                                  itemCount: state.historySmartChatMap.length ?? 1,
                                                  shrinkWrap: true,
                                                  itemBuilder: (context, index) {
                                                    MessageEntity model = state.historySmartChatMap.values.toList()[index];
                                                    // if (state.smartChatMap.isEmpty) {
                                                    //   return Container();
                                                    // }

                                                    return Container(
                                                      // color: Colors.blue,
                                                      child: (model.senderId != 'ai')
                                                          ? Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                Container(
                                                                  constraints: BoxConstraints(
                                                                    maxWidth: MediaQuery.of(context).size.width * 0.5, // 限制最大寬度為螢幕寬度的 50%
                                                                  ),
                                                                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: model.content.length > 15 // 根據文字長度調整邊角樣式
                                                                        ? BorderRadius.circular(15) // 多行時使用較小的圓角
                                                                        : BorderRadius.circular(100), // 單行時使用大圓角
                                                                    color: const Color.fromRGBO(71, 71, 71, 1),
                                                                  ),
                                                                  child: Text(
                                                                    model.content,
                                                                    style: const TextStyle(color: Colors.white),
                                                                    textAlign: TextAlign.left,
                                                                    softWrap: true, // 啟用文字換行
                                                                    overflow: TextOverflow.clip, // 防止文字超出容器
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Container(
                                                                  width: 30,
                                                                  height: 30,
                                                                  alignment: Alignment.center,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    borderRadius: BorderRadius.circular(50),
                                                                  ),
                                                                  child: Image.asset('assets/chatIcon.png'),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                                    // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        _buildResponseType(model),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                    );
                                                  },
                                                ),
                                                // 下方動畫顯示問答
                                                Container(
                                                  // color: Colors.red,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      StreamBuilder<MessageEntity?>(
                                                          stream: state.smartChatStream,
                                                          builder: (context, snapshot) {
                                                            if (snapshot.data == null) {
                                                              return Container();
                                                            }
                                                            MessageEntity isMeMessage = snapshot.data!;
                                                            return Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                (state.runtimeType == SmartChatIsMeLoadingState)
                                                                    ? const SpinKitThreeBounce(
                                                                        color: Colors.grey,
                                                                        size: 30,
                                                                      )
                                                                    : Container(
                                                                        constraints: BoxConstraints(
                                                                          maxWidth: MediaQuery.of(context).size.width * 0.5, // 限制最大寬度為螢幕寬度的 50%
                                                                        ),
                                                                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: isMeMessage.content.length > 15 // 根據文字長度調整邊角樣式
                                                                              ? BorderRadius.circular(15) // 多行時使用較小的圓角
                                                                              : BorderRadius.circular(100), // 單行時使用大圓角
                                                                          color: const Color.fromRGBO(71, 71, 71, 1),
                                                                        ),
                                                                        child: Text(
                                                                          isMeMessage.content,
                                                                          style: const TextStyle(color: Colors.white),
                                                                          textAlign: TextAlign.left,
                                                                          softWrap: true, // 啟用文字換行
                                                                          overflow: TextOverflow.clip, // 防止文字超出容器
                                                                        ),
                                                                      ),
                                                              ],
                                                            );
                                                          }),
                                                      const SizedBox(height: 20),
                                                      StreamBuilder<MessageEntity?>(
                                                          stream: state.smartChatGPTStream,
                                                          builder: (context, snapshot) {
                                                            MessageEntity? isGTPMessage = snapshot.data;
                                                            switch (state.runtimeType) {
                                                              case SmartChatResponseLoadingState:
                                                                {
                                                                  return Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: [
                                                                      Container(
                                                                        width: 30,
                                                                        height: 30,
                                                                        alignment: Alignment.center,
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          borderRadius: BorderRadius.circular(50),
                                                                        ),
                                                                        child: Image.asset('assets/chatIcon.png'),
                                                                      ),
                                                                      const SizedBox(
                                                                        width: 10,
                                                                      ),
                                                                      const SpinKitThreeBounce(
                                                                        color: Colors.grey,
                                                                        size: 30,
                                                                      )
                                                                    ],
                                                                  );
                                                                }
                                                              case SmartChatMessageState:
                                                                {
                                                                  return Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: [
                                                                      Container(
                                                                        width: 30,
                                                                        height: 30,
                                                                        alignment: Alignment.center,
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          borderRadius: BorderRadius.circular(50),
                                                                        ),
                                                                        child: Image.asset('assets/chatIcon.png'),
                                                                      ),
                                                                      const SizedBox(
                                                                        width: 10,
                                                                      ),
                                                                      Expanded(
                                                                        child: Container(
                                                                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                                          // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              _buildResponseAnimationType(isGTPMessage!),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }
                                                              default:
                                                                {
                                                                  return Container();
                                                                }
                                                            }
                                                          }),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
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
                              // 下半部分：底部的 Icon 和 TextFormField
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 30),
                                    Tooltip(
                                      message: '開啟新的聊天室',
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(50),
                                              color: const Color.fromRGBO(71, 71, 71, 1),
                                            ),
                                            child: Image.asset(
                                              'assets/blank.png',
                                              color: Colors.white,
                                            ),
                                          ),
                                          onTap: () {
                                            // 處理按鈕點擊事件
                                            flutterTts.stop();
                                            context.read<SmartChatBloc>().add(SmartChatNewRoomMessage());
                                            context.read<HistoryBloc>().add(HistoryInitEvent(skip: 0, size: 3, userId: context.read<LoginBloc>().state.userEntity!.id));
                                          },
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: const Color.fromRGBO(206, 206, 206, 1),
                                        ),
                                        child: const Icon(
                                          Icons.mic_none_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        _showOverlay();
                                      },
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(50),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2), // 陰影顏色
                                              spreadRadius: 2, // 陰影擴散半徑
                                              blurRadius: 10, // 陰影模糊半徑
                                              offset: const Offset(0, 3), // 陰影偏移量 (X, Y)
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: BlocConsumer<SpeechToTextBloc, SpeechToTextState>(
                                                listener: (context, state) {
                                                  // TODO: implement listener
                                                },
                                                builder: (context, state) {
                                                  if (state is SpeechStopped && state.recognizedText.isNotEmpty) {
                                                    _textController.text = state.recognizedText;
                                                  }
                                                  return TextFormField(
                                                    controller: _textController,
                                                    focusNode: _focusNode,
                                                    keyboardType: TextInputType.text,
                                                    validator: (value) {
                                                      return null;
                                                    },
                                                    onFieldSubmitted: (value) {
                                                      print('onFieldSubmitted: $value');
                                                      sendMessage(value);
                                                      _focusNode.requestFocus();
                                                    },
                                                    decoration: const InputDecoration(
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                                      border: InputBorder.none,
                                                      hintText: '詢問你想問的問題？',
                                                      hintStyle: TextStyle(
                                                        color: Color.fromRGBO(148, 148, 148, 1),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              icon: Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50),
                                                  color: const Color.fromRGBO(71, 71, 71, 1),
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_upward_rounded,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onPressed: () {
                                                String inputText = _textController.text; // 獲取輸入的文字
                                                if (inputText.isNotEmpty) {
                                                  // 在這裡處理發送的邏輯
                                                  sendMessage(inputText);
                                                  _textController.clear(); // 清空輸入框
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
