import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:wsp_t3/utils/bloc/engineering_bloc/engineering_bloc.dart';
import 'package:wsp_t3/utils/bloc/login_bloc/login_bloc.dart';
import 'utils/api/config.dart';
import 'utils/bloc/account_bloc/account_bloc.dart';
import 'utils/bloc/camera_list_statistic_bloc/camera_list_statistic_bloc.dart';
import 'utils/bloc/camera_manager_bloc/camera_manager_bloc.dart';
import 'utils/bloc/history_bloc/history_bloc.dart';
import 'utils/bloc/incident_bloc/incident_bloc.dart';
import 'utils/bloc/location_bloc/location_bloc.dart';
import 'utils/bloc/location_camera_bloc/location_camera_bloc.dart';
import 'utils/bloc/location_camera_record_bloc/location_camera_record_bloc.dart';
import 'utils/bloc/notification_bloc/notification_bloc.dart';
import 'utils/bloc/smart_chat_bloc/smart_chat_bloc.dart';
import 'utils/bloc/speech_to_text_bloc/speech_to_text_bloc.dart';
import 'utils/public/color_theme.dart';
import 'utils/routes/my_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// import 'package:video_player/video_player.dart';

// https://mycena.com.tw:61009/DemoCamera/livestream.flv
// https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8
// https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4
// http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid_demo1080p.flv

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Config(isLocalItem: true);
  setUrlStrategy(PathUrlStrategy());
  // MediaService.instance.socket.connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider<ApplicationServiceBloc>(
        //   create: (_) => ApplicationServiceBloc()..add(ApplicationServiceConnectEvent()),
        // ),
        BlocProvider<LoginBloc>(
          create: (_) => LoginBloc(),
        ),
        BlocProvider<EngineeringBloc>(
          create: (_) => EngineeringBloc(),
        ),
        BlocProvider<LocationBloc>(
          create: (_) => LocationBloc(),
        ),
        BlocProvider<CameraManagerBloc>(
          create: (_) => CameraManagerBloc(),
        ),
        BlocProvider<CameraListStatisticBloc>(
          create: (_) => CameraListStatisticBloc(),
        ),
        BlocProvider<LocationCameraBloc>(
          create: (_) => LocationCameraBloc(),
        ),
        BlocProvider<AccountBloc>(
          create: (_) => AccountBloc(),
        ),
        BlocProvider<IncidentBloc>(
          create: (_) => IncidentBloc()..add(IncidentInitEvent(skip: 0, size: 30)),
        ),
        BlocProvider<LocationCameraRecordBloc>(
          create: (_) => LocationCameraRecordBloc(),
        ),

        BlocProvider<SmartChatBloc>(
          create: (_) => SmartChatBloc(),
        ),
        BlocProvider<SpeechToTextBloc>(
          create: (_) => SpeechToTextBloc()..add(InitializeSpeech()),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => NotificationBloc(),
        ),
        BlocProvider<HistoryBloc>(
          create: (_) => HistoryBloc(),
        ),
      ],
      child: Sizer(builder: (context, orientation, screenType) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Flutter GoRouter Example',
          theme: ThemeData(
            primarySwatch: Colors.blue, // 設置主題的主顏色
            scaffoldBackgroundColor: Colors.white, // 設置整個應用的背景顏色為白色
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent, // 設置AppBar的背景顏色為白色
              foregroundColor: MyColorTheme.black, // 設置AppBar的文字顏色為黑色
            ),
            // 您可以在這裡進一步設置其他顏色和樣式
          ),
          routerConfig: MyRouter.router,
        );
      }),
    );
  }
}

// void main() {
//   runApp(const VideoApp());
// }

// class VideoApp extends StatefulWidget {
//   const VideoApp({super.key});

//   @override
//   _VideoAppState createState() => _VideoAppState();
// }

// class _VideoAppState extends State<VideoApp> {
//   String id = '123123';
//   String _html = '';
//   @override
//   void initState() {
//     _html = '''
//       <div id="aaaa" style = "width: 300px; height:200px; background-color: red;">
//         <h1>Hello, Flutter!</h1>
//         <p>This is a simple HTML rendering example.</p>
//       </div>
//     ''';
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Demo',
//       home: Scaffold(
//         body: Center(
//           child: Column(
//             children: [
//               HtmlWidget(_html),
//               const Text('123'),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             print(_html);
//             // js.context.callMethod('showAlert', ['Hello from Dart!']);
//             // setState(() {
//             //   _controller.value.isPlaying ? _controller.pause() : _controller.play();
//             // });
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }




