import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/bloc/login_bloc/login_bloc.dart';
import '../utils/entity/user.dart';
import '../utils/public/color_theme.dart';
import '../utils/public/custom_vertification.dart';
import '../utils/public/input_validation_utility.dart';
import '../utils/public/shared_preferences_manager.dart';
import '../utils/public/text_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController accountController;
  late final TextEditingController passwordController;
  late final TextEditingController verifyController;

  late final GlobalKey<FormState> accountKey;
  late final GlobalKey<FormState> passwordKey;
  late final GlobalKey<FormState> verifyKey;
  BehaviorSubject<bool> rememberMeSubject = BehaviorSubject<bool>.seeded(false);

  String code = '';
  bool accountVisible = true;
  bool passwordVisible = true;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () async {
      print('目前未記住我');
      final SharedPreferencesManager sharedPreferencesManager = await SharedPreferencesManager.getInstance();
      UserEntity? retrievedUser = await SharedPreferencesManager.getUserEntity();
      if (retrievedUser != null) {
        print('目前已記住我');
        context.read<LoginBloc>().state.userEntity = retrievedUser;
        context.read<LoginBloc>().add(SignInEvent(retrievedUser.mail, sharedPreferencesManager.getString('password')!, true));
      }
    });
    _getCode();
    super.initState();

    accountController = TextEditingController(text: '');
    passwordController = TextEditingController(text: '');
    verifyController = TextEditingController(text: '');

    accountKey = GlobalKey<FormState>();
    passwordKey = GlobalKey<FormState>();
    verifyKey = GlobalKey<FormState>();
  }

  _getCode() {
    code = '';
    String alphabet = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
    for (var i = 0; i < 6; i++) {
      code += Random().nextInt(9).toString();
      // String charOrNum = Random().nextInt(2) % 2 == 0 ? 'char' : 'num';
      // switch (charOrNum) {
      //   case 'char':
      //     {
      //       code += alphabet[Random().nextInt(alphabet.length)];
      //       break;
      //     }
      //   case 'num':
      //     {
      //       code += Random().nextInt(9).toString();
      //       break;
      //     }
      // }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        switch (state.runtimeType) {
          case LoginSuccessState:
            {
              context.go('/');
            }
        }
      },
      listenWhen: (previous, current) {
        if (previous.runtimeType == LoginLoadingState && (current.runtimeType == LoginFailureState)) {
          Fluttertoast.showToast(
            msg: "您輸入的帳號不存在",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
          );
        }
        return true;
      },
      builder: (context, state) {
        return Stack(
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
            Scaffold(
              body: Center(
                  child: Container(
                width: 460,
                height: 690,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color.fromRGBO(208, 208, 208, 1),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/login_Icon.png',
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      '登入',
                      style: TextStyle(fontSize: MyTextStyle.text_48),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: accountKey,
                      child: TextFormField(
                        controller: accountController,
                        // obscureText: accountVisible,
                        validator: InputValidationUtility.validateInput,

                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        autofocus: false,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                        ],

                        style: const TextStyle(fontSize: MyTextStyle.text_12, color: MyColorTheme.black),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(color: MyColorTheme.black, width: 2),
                          ),
                          // suffixIcon: IconButton(
                          //   icon: Icon(accountVisible ? Icons.visibility : Icons.visibility_off),
                          //   onPressed: () {
                          //     setState(() {
                          //       accountVisible = !accountVisible;
                          //     });
                          //   },
                          // ),

                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: MyColorTheme.orange, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: MyColorTheme.orange, width: 2),
                          ),
                          labelText: '輸入電子郵件地址',
                          labelStyle: const TextStyle(fontSize: MyTextStyle.text_12, color: MyColorTheme.black),
                          errorStyle: const TextStyle(fontSize: 12, height: 1, color: MyColorTheme.orange),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        StreamBuilder<bool>(
                            stream: rememberMeSubject.stream,
                            builder: (context, snapshot) {
                              return Checkbox(
                                value: rememberMeSubject.value,
                                onChanged: (value) {
                                  rememberMeSubject.add(value!);
                                },
                              );
                            }),
                        const Text(
                          '記住我的帳號',
                          style: TextStyle(fontSize: MyTextStyle.text_12),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Form(
                      key: passwordKey,
                      child: TextFormField(
                        // autovalidateMode: AutovalidateMode.always,
                        obscureText: passwordVisible,
                        controller: passwordController,
                        validator: (value) {
                          // if (value!.isEmpty) {
                          //   return '請勿空白';
                          // }
                          // return null;
                          // 測試先關起來，正式在啟用
                          String pattern = r'^(?=.*[0-9]+.*)(?=.*[a-zA-Z]+.*)(?=.*[!@#$%^&*()_+{}|:<>?]+.*)[0-9a-zA-Z!@#$%^&*()_+{}|:<>?]{8,}$';
                          RegExp regex = RegExp(pattern);
                          if (!regex.hasMatch(value!)) {
                            return '密碼必須至少8碼，並且包含大小寫字母、數字和特殊符號';
                          } else {
                            return null;
                          }
                        },
                        maxLines: 1,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        autofocus: false,
                        style: const TextStyle(fontSize: MyTextStyle.text_12, color: MyColorTheme.black),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                          ),
                          labelStyle: const TextStyle(
                            fontSize: MyTextStyle.text_12,
                            color: MyColorTheme.black,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(color: MyColorTheme.black, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: MyColorTheme.orange,
                                width: 2,
                              )),
                          labelText: '輸入密碼',
                          errorMaxLines: 3,
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: MyColorTheme.orange,
                              width: 2,
                            ),
                          ),
                          errorStyle: const TextStyle(
                            fontSize: 12,
                            height: 1,
                            color: MyColorTheme.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    // const Text(
                    //   '密碼長度應至少8碼以上，並且混合大小寫英文字母、數字及特殊符號',
                    //   style: TextStyle(
                    //     color: MyColorTheme.white12,
                    //     fontSize: MyTextStyle.text_10,
                    //   ),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.bottomLeft,
                          decoration: BoxDecoration(
                            color: MyColorTheme.white,
                            border: Border.all(
                              color: const Color(0xffC7C7C7),
                              width: 2,
                            ),
                          ),
                          child: CustomVertificationWidget(
                            code: code,
                            backgroundColor: MyColorTheme.white,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _getCode();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: const Text(
                              '刷新',
                              style: TextStyle(
                                color: MyColorTheme.black,
                                fontSize: MyTextStyle.text_16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Form(
                      key: verifyKey,
                      child: TextFormField(
                        // obscureText: true,
                        controller: verifyController,
                        validator: (value) {
                          // 測試先關起來，正式在啟用
                          if (value!.isEmpty) {
                            return '請勿空白';
                          } else if (value.toLowerCase() != code.toLowerCase()) {
                            return '輸入錯誤';
                          }
                          return null;
                        },
                        maxLines: 1,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly, // 只允許數字
                        ],
                        autofocus: false,
                        style: const TextStyle(fontSize: MyTextStyle.text_12, color: MyColorTheme.black),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(color: MyColorTheme.black, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: MyColorTheme.orange, width: 2)),
                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: MyColorTheme.orange, width: 2)),
                          labelText: '請輸入上方圖形中的文字',
                          labelStyle: const TextStyle(fontSize: MyTextStyle.text_12, color: MyColorTheme.black),
                          errorStyle: const TextStyle(fontSize: 12, height: 1, color: MyColorTheme.orange),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Fluttertoast.showToast(
                                  msg: "請管理員協助重設",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                alignment: Alignment.center,
                                child: const Text('忘記密碼'),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                if (accountKey.currentState!.validate() & passwordKey.currentState!.validate() & verifyKey.currentState!.validate()) {
                                  context.read<LoginBloc>().add(SignInEvent(accountController.text, passwordController.text, rememberMeSubject.value));
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: MyColorTheme.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: const Text('登入'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )),
            ),
            state is LoginLoadingState
                ? Container(
                    alignment: Alignment.center,
                    color: MyColorTheme.black.withOpacity(.7),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    // color: Colors.blue,
                    child: const CircularProgressIndicator())
                : Container(),
          ],
        );
      },
    );
  }
}
