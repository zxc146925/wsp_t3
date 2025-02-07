import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:wsp_t3/utils/entity/camera_manager.dart';

import '../../../../utils/bloc/camera_manager_bloc/camera_manager_bloc.dart';

import '../../../../utils/bloc/login_bloc/login_bloc.dart';
import '../../../../utils/public/color_theme.dart';
import '../../../../utils/public/text_style.dart';

//// 影像管理/攝影機管理
class VideoManagerTabScreen extends StatefulWidget {
  const VideoManagerTabScreen({super.key});

  @override
  State<VideoManagerTabScreen> createState() => _VideoManagerTabScreenState();
}

class _VideoManagerTabScreenState extends State<VideoManagerTabScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey<FormFieldState> ipKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> nameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> protocolKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> portKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> webKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> urlPathKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> accountKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> passwordKey = GlobalKey<FormFieldState>();

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _protocolController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _webController = TextEditingController();
  final TextEditingController _urlPathController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && context.read<IncidentBloc>().state is! IncidentLoadingMoreState && context.read<IncidentBloc>().state is! IncidentReadMoreMaxState) {
      // 當滾動到底部附近且尚未加載更多或達到最大數據時，發送拉取更多的事件
      print('拉取更多資料');
      // }
    });
  }

  Future<void> _showEditDialog(BuildContext context, CameraManagerEntity entity) async {
    _ipController.text = entity.ip ?? '';
    _nameController.text = entity.cameraName ?? '';
    _protocolController.text = entity.protocol ?? '';
    _portController.text = entity.port.toString() ?? '';
    _webController.text = entity.web ?? '';
    _urlPathController.text = entity.urlPath ?? '';
    _accountController.text = entity.account ?? '';
    _passwordController.text = entity.password ?? '';

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
                        '編輯攝影機',
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
                BlocConsumer<CameraManagerBloc, CameraManagerState>(
                  buildWhen: (previous, current) {
                    if (previous.runtimeType == CameraManagerEditingState && current.runtimeType == CameraManagerShowingState) {
                      Navigator.of(context).pop();
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
                                        '攝影機IP',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: ipKey,
                                        maxLines: 1,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        controller: _ipController,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: entity.ip,
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
                                        '攝影機名稱',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: nameKey,
                                        maxLines: 1,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        controller: _nameController,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: entity.cameraName,
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
                                        '串流協定',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: protocolKey,
                                        maxLines: 1,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        controller: _protocolController,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: entity.protocol,
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
                                        '埠Port',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: portKey,
                                        maxLines: 1,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        controller: _portController,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: entity.port.toString(),
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
                                        '管理網站',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: webKey,
                                        maxLines: 1,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        controller: _webController,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: entity.web,
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
                                        'RTSP 連線網址 rtsp url',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: urlPathKey,
                                        maxLines: 1,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        controller: _urlPathController,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: entity.urlPath,
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
                                        '帳號',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: accountKey,
                                        maxLines: 1,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        controller: _accountController,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: entity.account,
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
                                        '密碼',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: passwordKey,
                                        maxLines: 1,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        controller: _passwordController,
                                        textInputAction: TextInputAction.done,
                                        // obscureText: true,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: entity.password,
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
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // isEdit == true
                                //     ? Expanded(
                                //         flex: 1,
                                //         child: Container(
                                //           alignment: Alignment.center,
                                //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                //           decoration: BoxDecoration(
                                //             color: MyColorTheme.red,
                                //             borderRadius: BorderRadius.circular(10),
                                //           ),
                                //           child: const Text('刪除'),
                                //         ),
                                //       ):
                                Expanded(flex: 1, child: Container()),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 1,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (ipKey.currentState!.validate() & nameKey.currentState!.validate() & protocolKey.currentState!.validate() & portKey.currentState!.validate() & webKey.currentState!.validate() & urlPathKey.currentState!.validate() & accountKey.currentState!.validate() & passwordKey.currentState!.validate()) {
                                          context.read<CameraManagerBloc>().add(
                                                CameraManagerUpdateEvent(
                                                  id: entity.id,
                                                  name: _nameController.text,
                                                  ip: _ipController.text,
                                                  port: int.parse(_portController.text),
                                                  protocol: _protocolController.text,
                                                  web: _webController.text,
                                                  urlPath: _urlPathController.text,
                                                  account: _accountController.text,
                                                  password: _passwordController.text,
                                                ),
                                              );
                                        } else {
                                          print('部分欄位驗證失敗');
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: MyColorTheme.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text('儲存'),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ));
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          BlocConsumer<CameraManagerBloc, CameraManagerState>(
            buildWhen: (previous, current) {
              if (previous.runtimeType == CameraManagerEditingState && current.runtimeType == CameraManagerShowingState) {
                Fluttertoast.showToast(
                  msg: "更新成功",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 3,
                );
              }
              if (previous.runtimeType == CameraManagerEditingState && current.runtimeType == CameraManagerEditErrorState) {
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
              switch (state.runtimeType) {
                case CameraManagerInitialState:
                case CameraManagerLoadingState:
                case CameraManagerEditingState:
                  {
                    return Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                case CameraManagerShowingState:
                case CameraManagerInitialCompleteState:
                  {
                    return Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: SingleChildScrollView(
                          child: DataTable(
                            showCheckboxColumn: false,
                            showBottomBorder: true,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  '攝影機名稱',
                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                ),
                              ),
                              DataColumn(
                                  label: SizedBox(
                                width: 200,
                                child: Text(
                                  '目前案場',
                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                ),
                              )),
                              DataColumn(
                                label: Text(
                                  '攝影機IP',
                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  '埠Port',
                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  '串流協定',
                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'RTSP 連線網址 rtsp url',
                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  '管理網站',
                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  '建立時間',
                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                ),
                              ),
                            ],
                            rows: state.cameraManagerMap.values
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
                                      DataCell(Text(row.cameraName)),
                                      DataCell(Text(row.locationName)),
                                      DataCell(Text(row.ip)),
                                      DataCell(Text(row.port.toString())),
                                      DataCell(Text(row.protocol)),
                                      DataCell(Text(row.urlPath)),
                                      DataCell(Text(row.web)),
                                      DataCell(
                                        Text(
                                          DateFormat('yyyy/MM/dd').format(
                                            DateTime.fromMillisecondsSinceEpoch(row.createDatetime),
                                          ),
                                        ),
                                      ),
                                    ],
                                    onSelectChanged: (isSelected) {
                                      if (context.read<LoginBloc>().state.userEntity!.permission != 0) {
                                        _showEditDialog(context, row);
                                      }
                                    },
                                  ),
                                )
                                .toList(),
                          ),
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
        ],
      ),
    );
  }
}
