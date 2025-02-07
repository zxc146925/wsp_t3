import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:wsp_t3/utils/bloc/engineering_bloc/engineering_bloc.dart';

import '../../utils/bloc/account_bloc/account_bloc.dart';
import '../../utils/bloc/login_bloc/login_bloc.dart';
import '../../utils/entity/engineering.dart';
import '../../utils/entity/user.dart';
import '../../utils/public/appbar_shadow.dart';
import '../../utils/public/color_theme.dart';
import '../../utils/public/text_style.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List<String> permissionList = ['一般權限', '管理員'];
  String permission = '一般權限';
  Map<String, EngineeringEntity> engineeringMap = {};
  late String engineeringName;

  final GlobalKey<FormFieldState> mailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> passwordKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> nameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> phoneKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> permissionKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> engineeringKey = GlobalKey<FormFieldState>();

  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _permissionController = TextEditingController();
  final TextEditingController _engineeringController = TextEditingController();

  @override
  void initState() {
    context.read<AccountBloc>().add(AccountInitEvent(skip: 0, size: 30, user: context.read<LoginBloc>().state.userEntity!));
    engineeringMap = context.read<EngineeringBloc>().state.engineeringMap;
    engineeringName = engineeringMap.values.toList()[0].name;
    super.initState();
  }

  String? getIdByName(String name, Map<String, EngineeringEntity> engineeringMap) {
    // 遍歷 Map，找到對應的 key
    try {
      return engineeringMap.entries.firstWhere((entry) => entry.value.name == name).key;
    } catch (e) {
      // 如果沒有找到，返回 null 或拋出錯誤
      return null;
    }
  }

  Future<void> _showEditDialog(bool isEdit, UserEntity? entity) async {
    // 如果更新需要把Item的資料綁上去
    if (isEdit) {
      _mailController.text = entity!.mail ?? '';
      _nameController.text = entity.name ?? '';
      _phoneController.text = entity.phone ?? '';
      _permissionController.text = permissionList[entity.permission] ?? '';
    } else {
      _mailController.text = '';
      _nameController.text = '';
      _phoneController.text = '';
      _permissionController.text = '';
    }

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
                      Text(
                        isEdit ? '編輯使用者' : '新增使用者',
                        style: const TextStyle(fontSize: MyTextStyle.text_16, color: MyColorTheme.white),
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
                BlocConsumer<AccountBloc, AccountState>(
                  buildWhen: (previous, current) {
                    if (previous.runtimeType == AccountEditingState && current.runtimeType == AccountShowingState) {
                      isEdit
                          ? Fluttertoast.showToast(
                              msg: "更新成功",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 3,
                            )
                          : Fluttertoast.showToast(
                              msg: "新增成功",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 3,
                            );
                    }
                    if (previous.runtimeType == AccountEditingState && current.runtimeType == AccountEditErrorState) {
                      isEdit
                          ? Fluttertoast.showToast(
                              msg: "更新失敗",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 3,
                            )
                          : Fluttertoast.showToast(
                              msg: "新增失敗",
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
                                          '帳號',
                                          style: TextStyle(color: MyColorTheme.white),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        TextFormField(
                                          key: mailKey,
                                          maxLines: 1,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return '請勿空白';
                                            }
                                            return null;
                                          },
                                          controller: _mailController,
                                          textInputAction: TextInputAction.done,
                                          cursorColor: MyColorTheme.white,
                                          style: const TextStyle(color: MyColorTheme.white),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                            ),
                                            labelText: isEdit ? entity!.mail : '輸入帳號',
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
                                          '名稱',
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
                                            labelText: isEdit ? entity!.name : '輸入名稱',
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
                                          '電話',
                                          style: TextStyle(color: MyColorTheme.white),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        TextFormField(
                                          key: phoneKey,
                                          maxLines: 1,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return '請勿空白';
                                            }
                                            return null;
                                          },
                                          controller: _phoneController,
                                          textInputAction: TextInputAction.done,
                                          cursorColor: MyColorTheme.white,
                                          style: const TextStyle(color: MyColorTheme.white),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5),
                                              borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                            ),
                                            labelText: isEdit ? entity!.phone : '輸入電話',
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
                                    child: context.read<LoginBloc>().state.userEntity!.permission == 0
                                        ? Container()
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '權限',
                                                style: TextStyle(color: MyColorTheme.white),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              DropdownButtonFormField<String>(
                                                key: permissionKey,
                                                value: isEdit ? permissionList[entity!.permission] : permissionList[0], // 預設值
                                                onChanged: (value) {
                                                  print('value-----${permissionList[permissionList.indexOf(value!)]}');
                                                  permission = value;
                                                },
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return '請選擇一個選項';
                                                  }
                                                  return null;
                                                },
                                                items: permissionList.map((String value) {
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
                                                  labelText: isEdit ? entity!.permission.toString() : '請選擇一個選項',
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
                            isEdit
                                ? Container()
                                : Container(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    child: Row(
                                      children: [
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
                                                cursorColor: MyColorTheme.white,
                                                style: const TextStyle(color: MyColorTheme.white),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                    borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                                  ),
                                                  labelText: '輸入密碼',
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
                                                '工程',
                                                style: TextStyle(color: MyColorTheme.white),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              DropdownButtonFormField<String>(
                                                key: engineeringKey,
                                                value: engineeringName, // 預設值
                                                onChanged: (value) {
                                                  // print('value-----${permissionList[permissionList.indexOf(value!)]}');
                                                  // permission = value;
                                                },
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return '請選擇一個選項';
                                                  }
                                                  return null;
                                                },
                                                items: engineeringMap.values.toList().map((EngineeringEntity engineeringEntity) {
                                                  return DropdownMenuItem<String>(
                                                    value: engineeringEntity.name,
                                                    child: Text(
                                                      engineeringEntity.name,
                                                      style: const TextStyle(color: MyColorTheme.white),
                                                    ),
                                                  );
                                                }).toList(),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                    borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                                  ),
                                                  labelText: '請選擇一個選項',
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
                                          if (isEdit & mailKey.currentState!.validate() & nameKey.currentState!.validate() & phoneKey.currentState!.validate() & permissionKey.currentState!.validate()) {
                                            context.read<AccountBloc>().add(UpdateAccountEvent(id: entity!.id, mail: _mailController.text, name: _nameController.text, phone: _phoneController.text, permission: permissionList.indexOf(permission)));
                                          } else if (mailKey.currentState!.validate() & nameKey.currentState!.validate() & phoneKey.currentState!.validate() & permissionKey.currentState!.validate() & passwordKey.currentState!.validate() & engineeringKey.currentState!.validate()) {
                                            String? engineeringId = getIdByName(engineeringName, engineeringMap);
                                            // print('新增使用者：${_mailController.text}----${_nameController.text}----${_phoneController.text}----${permissionList.indexOf(permission)}---${_passwordController.text}----$engineeringId');
                                            context.read<AccountBloc>().add(CreateAccountEvent(mail: _mailController.text, name: _nameController.text, phone: _phoneController.text, permission: permissionList.indexOf(permission), password: _passwordController.text, engineeringId: engineeringId!));
                                          } else {
                                            print('部分欄位驗證失敗');
                                          }

                                          // _ipController.text = entity.ip;
                                          // _nameController.text = entity.cameraName;
                                          // _protocolController.text = entity.protocol;
                                          // _portController.text = entity.port.toString();
                                          // _webController.text = entity.web;
                                          // _urlPathController.text = entity.urlPath;
                                          // _accountController.text = entity.account;
                                          // _passwordController.text = entity.password;
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: MyColorTheme.white,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: isEdit ? const Text('儲存') : const Text('送出'),
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        appBarShadow(),
        Column(
          children: [
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(left: 40, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("帳號列表"),
                  Row(
                    children: [
                      const Icon(Icons.search),
                      IconButton(
                        iconSize: 40,
                        onPressed: () {
                          _showEditDialog(false, null);
                        },
                        icon: const Icon(Icons.add_circle_outlined),
                        color: MyColorTheme.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            BlocConsumer<AccountBloc, AccountState>(
              buildWhen: (previous, current) {
                if ((previous.runtimeType == AccountEditingState || previous.runtimeType == AccountAddingState) && current.runtimeType == AccountShowingState) {
                  Navigator.of(context).pop();
                }
                return true;
              },
              listener: (context, accountState) {},
              builder: (context, accountState) {
                switch (accountState.runtimeType) {
                  case AccountInitialState:
                  case AccountLoadingState:
                  case AccountEditingState:
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

                  case AccountShowingState:
                    {
                      return Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                            child: accountState.userMap.isEmpty
                                ? const Center(child: Text('暫無帳號資訊'))
                                : DataTable(
                                    showCheckboxColumn: false,
                                    showBottomBorder: true,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          '姓名',
                                          // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                        ),
                                      ),
                                      DataColumn(
                                          label: SizedBox(
                                        width: 400,
                                        child: Text(
                                          '帳號',
                                          // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                        ),
                                      )),
                                      DataColumn(
                                        label: Text(
                                          '電話',
                                          // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                        ),
                                      ),
                                      // DataColumn(
                                      //   label: Text(
                                      //     '身份',
                                      //     // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                      //   ),
                                      // ),
                                      DataColumn(
                                        label: Text(
                                          '權限',
                                          // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          '加入日期',
                                          // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                        ),
                                      ),
                                    ],
                                    rows: accountState.userMap.values
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
                                              DataCell(Text(row.name)),
                                              DataCell(Text(row.mail)),
                                              DataCell(Text(row.phone)),
                                              // DataCell(Text(row.identity.toString())),
                                              DataCell(Text(permissionList[row.permission])),
                                              DataCell(
                                                Text(
                                                  DateFormat('yyyy/MM/dd').format(
                                                    DateTime.fromMillisecondsSinceEpoch(row.createDatetime),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            onSelectChanged: (isSelected) {
                                              _showEditDialog(true, row);
                                              // print('Item ${row.id} is selected: ${row.name}'),
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
            )
          ],
        ),
      ],
    );
  }
}
