import 'package:go_router/go_router.dart';
import 'package:wsp_t3/screen/dowload_screen.dart';
import 'package:wsp_t3/screen/tab_bar_screen/anomaly/anomaly.dart';
import 'package:wsp_t3/screen/tab_bar_screen/construction/construction.dart';
import 'package:wsp_t3/screen/home.dart';
import 'package:wsp_t3/screen/login.dart';
import 'package:wsp_t3/utils/public/shared_preferences_manager.dart';

class MyRouter {
  final SharedPreferencesManager _sharedPreferencesManager;
  MyRouter._(this._sharedPreferencesManager);

  static Future<MyRouter> create() async {
    final sharedPreferencesManager = await SharedPreferencesManager.getInstance();
    return MyRouter._(sharedPreferencesManager);
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/construction',
        builder: (context, state) => const ConstructionScreen(),
        // routes: [
        //   GoRoute(
        //     path: 'list',
        //     builder: (context, state) => const ContentPage(),
        //   ),
        // ],
      ),
      GoRoute(
        path: '/anomaly',
        builder: (context, state) => const AnomalyScreen(),
      ),
      GoRoute(
        path: '/download',
        builder: (context, state) => const DownloadScreen(),
      ),
    ],
  );
}
