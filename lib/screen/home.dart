import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wsp_t3/screen/tab_bar_screen/account.dart';
import 'package:wsp_t3/screen/tab_bar_screen/anomaly/anomaly.dart';
import 'package:wsp_t3/screen/tab_bar_screen/construction/construction.dart';
import 'package:wsp_t3/screen/tab_bar_screen/smart_chat/smart_chat.dart';
import 'package:wsp_t3/screen/tab_bar_screen/video/video_home.dart';
import 'package:wsp_t3/screen/video_player_widget.dart';
import 'package:wsp_t3/utils/bloc/account_bloc/account_bloc.dart';
import 'package:wsp_t3/utils/bloc/smart_chat_bloc/smart_chat_bloc.dart';
import '../utils/public/shared_preferences_manager.dart';
import '../utils/public/text_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<Widget> viewchildren = [const SmartChatScreen(), const ConstructionScreen(), const VideoScreen(), const AnomalyScreen(), const AccountScreen()];

  @override
  void initState() {
    tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            // color: Colors.blue,
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.fitHeight,
              height: MediaQuery.of(context).size.height,
              // 記得根據你的檔案路徑修改
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // 設定模糊程度
              child: Container(
                  // color: Colors.black.withOpacity(0.2), // 可以調整透明度以增強視覺效果
                  ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              elevation: 0, // 設置陰影的高度
              shadowColor: Colors.transparent,
              toolbarHeight: 70, // 自定義 AppBar 高度
              leadingWidth: 400,
              surfaceTintColor: Colors.transparent,
              leading: Center(
                child: Container(
                  alignment: Alignment.center,
                  // color: Colors.blue,
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/WSP_logo.png',
                        height: 30,
                      ),
                      const SizedBox(width: 20),
                      Image.asset(
                        'assets/WSP_SmartNVR.png',
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              centerTitle: false,
              title: SizedBox(
                width: 600,
                child: TabBar(
                  controller: tabController,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: MyTextStyle.text_16),
                  tabs: const [
                    Tab(text: '智慧助理'),
                    Tab(text: '案場管理'),
                    Tab(text: '影像管理'),
                    Tab(text: '異常紀錄'),
                    Tab(text: '帳號管理'),
                  ],
                  dividerColor: Colors.transparent,
                  unselectedLabelColor: Colors.grey.shade500, // 未選中的文字顏色
                  labelColor: Colors.black, // 選中的文字顏色
                  indicatorColor: Colors.red, // 指示器顏色
                  indicatorWeight: 4.0, // 指示器的高度
                ),
              ),
              actions: [
                // IconButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => const VideoPlayerWidget()),
                //     );
                //     // PublicData.generateAndDownloadExcel();
                //   },
                //   icon: const Icon(Icons.settings),
                // ),
                PopupMenuButton<String>(
                  color: Colors.white.withOpacity(0.8),
                  icon: Container(
                    width: 35,
                    height: 35,
                    // margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(71, 71, 71, 1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      color: Colors.white,
                    ),
                  ),
                  onSelected: (String value) async {
                    if (value == 'go_to_page') {
                      // context.go('/download');
                      final uri = Uri.parse('https://mycena.com.tw:30000');

                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication); // 外部瀏覽器
                      } else {
                        throw 'Could not launch';
                      }
                      print("跳轉到手動巡檢頁面");
                    } else if (value == 'logout') {
                      final SharedPreferencesManager sharedPreferencesManager = await SharedPreferencesManager.getInstance();
                      sharedPreferencesManager.clear();
                      context.read<SmartChatBloc>().add(SmartChatNewRoomMessage());
                      context.go('/login');
                      print("登出");
                    }
                  },
                  padding: const EdgeInsets.all(5),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    // 第一項
                    const PopupMenuItem<String>(
                      value: 'go_to_page',
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.center, // 文字置中
                          child: Text(
                            '前往手動巡檢頁面',
                          ),
                        ),
                      ),
                    ),
                    // 分隔線
                    const PopupMenuDivider(),
                    // 第二項
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.center, // 文字置中
                          child: Text(
                            '登出',
                            // style: TextStyle(fontWeight: FontWeight.bold), // 可選：加粗
                          ),
                        ),
                      ),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // 圓角樣式
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(), // 禁止滑動
              controller: tabController,
              children: viewchildren,
            ),
          ),
        ],
      ),
    );
  }
}
