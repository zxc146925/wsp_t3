
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wsp_t3/utils/bloc/location_bloc/location_bloc.dart';
import 'package:wsp_t3/utils/entity/location.dart';

import '../../../utils/bloc/engineering_bloc/engineering_bloc.dart';
import '../../../utils/bloc/login_bloc/login_bloc.dart';
import '../../../utils/entity/engineering.dart';
import '../../../utils/public/appbar_shadow.dart';
import '../../../utils/public/color_theme.dart';
import '../../../utils/public/public_data.dart';
import '../../../utils/public/text_style.dart';
import 'construction_drawer.dart';

class ConstructionScreen extends StatefulWidget {
  const ConstructionScreen({super.key});

  @override
  State<ConstructionScreen> createState() => _ConstructionScreenState();
}

class _ConstructionScreenState extends State<ConstructionScreen> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BehaviorSubject<String> openDrawerTitleStream = BehaviorSubject<String>.seeded('');
  String localTypeName = PublicData.locationType[0];
  late BehaviorSubject<LocationEntity?> openDrawerLocationStream = BehaviorSubject.seeded(null);
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  final GlobalKey<FormFieldState> nameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> managerKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> phoneKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> stateKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> startDatetimeKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> endDatetimeKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> descriptionKey = GlobalKey<FormFieldState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _managerController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _startDatetimeController = TextEditingController();
  final TextEditingController _endDatetimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // 工程使用
  final GlobalKey<FormFieldState> contractorKey = GlobalKey<FormFieldState>();
  final TextEditingController _contractorController = TextEditingController();

  final GlobalKey<FormFieldState> inspectorKey = GlobalKey<FormFieldState>();
  final TextEditingController _inspectorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('案場初始');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.read<LocationBloc>().add(
              RefreshLocationEvent(
                skip: 0,
                size: 10,
                engineering: context.read<EngineeringBloc>().state.engineeringMap.entries.first.value,
              ),
            );
      }
    });
  }

  void _onRowTap(Map<String, dynamic> row) {
    print('row tapped----${row['id']}----${row['name']}}');
    // _showRowDetails(row);
  }

  void _onIconTap(Map<String, dynamic> row) {
    setState(() {
      row['selected'] = !row['selected'];
    });
  }

  Future<void> _selectDate(bool isStart, BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      cancelText: '取消',
      confirmText: '確定',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: MyColorTheme.red, // 主色調，影響選中的日期顏色
            dialogBackgroundColor: MyColorTheme.white, // 日期選擇器的背景顏色
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              buttonColor: MyColorTheme.black, // 確定和取消按鈕的背景顏色
            ),
            colorScheme: const ColorScheme.light(
              primary: MyColorTheme.red, // 日期選中的顏色
              onPrimary: MyColorTheme.white, // 日期選中後的文字顏色
            ).copyWith(
              secondary: MyColorTheme.red, // 副色調（通常影響按鈕的Hover顏色）
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: MyColorTheme.black, // 確定、取消按鈕的文字顏色
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && isStart) {
      // 開始時間使用
      setState(() {
        _startDatetimeController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
      });
    } else if (pickedDate != null && !isStart) {
      // 結束時間使用
      setState(() {
        _endDatetimeController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
      });
    }
  }

  void updateEngineeringDialog(bool isEdit, BuildContext context, EngineeringEntity engineeringEntity) {
    if (isEdit) {
      _nameController.text = engineeringEntity.name;
      _inspectorController.text = engineeringEntity.inspector;
      _contractorController.text = engineeringEntity.contractor;
      _descriptionController.text = engineeringEntity.description;
      _phoneController.text = engineeringEntity.phone;
      _managerController.text = engineeringEntity.engineer;
      _startDatetimeController.text = DateFormat('yyyy/MM/dd').format(DateTime.fromMillisecondsSinceEpoch(engineeringEntity.startDatetime));
      _endDatetimeController.text = DateFormat('yyyy/MM/dd').format(DateTime.fromMillisecondsSinceEpoch(engineeringEntity.endDatetime));
    }

    showDialog(
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
                        isEdit ? '編輯工程' : '新增工程',
                        style: const TextStyle(fontSize: MyTextStyle.text_16, color: MyColorTheme.white),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.close,
                          color: MyColorTheme.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: MyColorTheme.white,
                  thickness: 1,
                ),
                BlocConsumer<EngineeringBloc, EngineeringState>(
                  buildWhen: (previous, current) {
                    if (previous.runtimeType == EngineeringEditingState && current.runtimeType == EngineeringShowingState) {
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
                      Navigator.of(context).pop();
                    }
                    if (previous.runtimeType == EngineeringEditingState && current.runtimeType == EngineeringErrorState) {
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
                  listener: (context, state) {
                    // TODO: implement listener
                  },
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
                                        '工程名稱',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: nameKey,
                                        controller: _nameController,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入工程名稱',
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
                                        '監造單位',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: inspectorKey,
                                        controller: _inspectorController,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入監造單位',
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
                                        '施工廠商',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: contractorKey,
                                        controller: _contractorController,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入施工廠商',
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
                                        '工程概要',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: descriptionKey,
                                        controller: _descriptionController,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入工程概要',
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
                                        controller: _phoneController,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入電話',
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
                                        '專任工程人員',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: managerKey,
                                        controller: _managerController,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入專任工程人員',
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
                                        '開始時間',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        maxLines: 1,
                                        key: startDatetimeKey,
                                        controller: _startDatetimeController,
                                        readOnly: true, // 禁止手動輸入
                                        onTap: () => _selectDate(true, context), // 點擊時顯示日期選擇器

                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入開始時間',
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
                                        '結束時間',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        maxLines: 1,
                                        key: endDatetimeKey,
                                        controller: _endDatetimeController,
                                        readOnly: true, // 禁止手動輸入
                                        onTap: () => _selectDate(false, context), // 點擊時顯示日期選擇器
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入結束時間',
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
                                //       )
                                //     :
                                Expanded(flex: 1, child: Container()),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 1,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (DateFormat('yyyy/MM/dd').parse(_startDatetimeController.text).toLocal().millisecondsSinceEpoch > DateFormat('yyyy/MM/dd').parse(_endDatetimeController.text).toLocal().millisecondsSinceEpoch) {
                                          print('開始時間----${DateFormat('yyyy/MM/dd').parse(_startDatetimeController.text).toLocal().millisecondsSinceEpoch}---結束時間----${DateFormat('yyyy/MM/dd').parse(_endDatetimeController.text).toLocal().millisecondsSinceEpoch}');
                                          Fluttertoast.showToast(
                                            msg: "開始時間不能大於結束時間",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 3,
                                            backgroundColor: MyColorTheme.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                          return;
                                        }
                                        if (nameKey.currentState!.validate() & inspectorKey.currentState!.validate() & contractorKey.currentState!.validate() & descriptionKey.currentState!.validate() & phoneKey.currentState!.validate() & managerKey.currentState!.validate()) {
                                          // print('送出資訊-----id:${engineeringEntity.id}---${_nameController.text}---${_inspectorController.text}---${_contractorController.text}-----${_descriptionController.text}-----${_phoneController.text}-----${_managerController.text}------${DateFormat('yyyy/MM/dd').parse(_startDatetimeController.text).toLocal().millisecondsSinceEpoch}---${DateFormat('yyyy/MM/dd').parse(_endDatetimeController.text).toLocal().millisecondsSinceEpoch}');
                                          context.read<EngineeringBloc>().add(
                                                UpdateEngineeringEvent(
                                                  id: engineeringEntity.id,
                                                  name: _nameController.text,
                                                  inspector: _inspectorController.text,
                                                  contractor: _contractorController.text,
                                                  phone: _phoneController.text,
                                                  engineer: _managerController.text,
                                                  description: _descriptionController.text,
                                                  startDatetime: DateFormat('yyyy/MM/dd').parse(_startDatetimeController.text).toLocal().millisecondsSinceEpoch,
                                                  endDatetime: DateFormat('yyyy/MM/dd').parse(_endDatetimeController.text).toLocal().millisecondsSinceEpoch,
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

  void createLocationDialog(bool isEdit, BuildContext context, String engineeringId) {
    showDialog(
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
                        isEdit ? '編輯案場' : '新增案場',
                        style: const TextStyle(fontSize: MyTextStyle.text_16, color: MyColorTheme.white),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.close,
                          color: MyColorTheme.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: MyColorTheme.white,
                  thickness: 1,
                ),
                BlocConsumer<LocationBloc, LocationState>(
                  buildWhen: (previous, current) {
                    if ((previous.runtimeType == LocationEditingState || previous.runtimeType == LocationAddingState) && current.runtimeType == LocationShowingState) {
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
                      Navigator.of(context).pop();
                    }
                    if (previous.runtimeType == LocationEditingState && current.runtimeType == LocationEditErrorState) {
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
                                        '案場名稱',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: nameKey,
                                        controller: _nameController,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入案場名稱',
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
                                        '案場負責人',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: managerKey,
                                        controller: _managerController,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入案場負責人',
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
                                        controller: _phoneController,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入電話',
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
                                        '案場狀態',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      DropdownButtonFormField<String>(
                                        value: localTypeName, // 預設值
                                        onChanged: (value) {
                                          localTypeName = value!;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return '請選擇一個選項';
                                          }
                                          return null;
                                        },
                                        items: PublicData.locationType.map((String value) {
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
                                          labelText: localTypeName,
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
                                        '開始時間',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        maxLines: 1,
                                        key: startDatetimeKey,
                                        controller: _startDatetimeController,
                                        readOnly: true, // 禁止手動輸入
                                        onTap: () => _selectDate(true, context), // 點擊時顯示日期選擇器

                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入開始時間',
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
                                        '結束時間',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        maxLines: 1,
                                        key: endDatetimeKey,
                                        controller: _endDatetimeController,
                                        readOnly: true, // 禁止手動輸入
                                        onTap: () => _selectDate(false, context), // 點擊時顯示日期選擇器
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入結束時間',
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
                                        '備註',
                                        style: TextStyle(color: MyColorTheme.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        key: descriptionKey,
                                        controller: _descriptionController,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: MyColorTheme.white,
                                        style: const TextStyle(color: MyColorTheme.white),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '請勿空白';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                          ),
                                          labelText: '輸入備註',
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
                                Expanded(child: Container())
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                isEdit == true
                                    ? Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: MyColorTheme.red,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text('刪除'),
                                        ),
                                      )
                                    : Expanded(flex: 1, child: Container()),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 1,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (DateFormat('yyyy/MM/dd').parse(_startDatetimeController.text).toLocal().millisecondsSinceEpoch > DateFormat('yyyy/MM/dd').parse(_endDatetimeController.text).toLocal().millisecondsSinceEpoch) {
                                          print('開始時間----${DateFormat('yyyy/MM/dd').parse(_startDatetimeController.text).toLocal().millisecondsSinceEpoch}---結束時間----${DateFormat('yyyy/MM/dd').parse(_endDatetimeController.text).toLocal().millisecondsSinceEpoch}');
                                          Fluttertoast.showToast(
                                            msg: "開始時間不能大於結束時間",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 3,
                                            backgroundColor: MyColorTheme.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                          return;
                                        }
                                        if (nameKey.currentState!.validate() & managerKey.currentState!.validate() & phoneKey.currentState!.validate() & descriptionKey.currentState!.validate()) {
                                          print('送出資訊----engineeringId:$engineeringId----${_nameController.text}---${_managerController.text}---${_phoneController.text}---${PublicData.locationType.indexOf(localTypeName)}---${DateFormat('yyyy/MM/dd').parse(_startDatetimeController.text).toLocal().millisecondsSinceEpoch}---${DateFormat('yyyy/MM/dd').parse(_endDatetimeController.text).toLocal().millisecondsSinceEpoch}');

                                          context.read<LocationBloc>().add(
                                                CreateLocationEvent(
                                                  engineeringId: engineeringId,
                                                  name: _nameController.text,
                                                  manager: _managerController.text,
                                                  phone: _phoneController.text,
                                                  state: PublicData.locationType.indexOf(localTypeName),
                                                  description: _descriptionController.text,
                                                  startDatetime: DateFormat('yyyy/MM/dd').parse(_startDatetimeController.text).toLocal().millisecondsSinceEpoch,
                                                  endDatetime: DateFormat('yyyy/MM/dd').parse(_endDatetimeController.text).toLocal().millisecondsSinceEpoch,
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
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LocationEntity?>(
        stream: openDrawerLocationStream,
        builder: (context, snapshot) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            endDrawer: ConstructionDrawer(
              locationEntity: snapshot.data,
            ),
            body: BlocConsumer<EngineeringBloc, EngineeringState>(
              listener: (context, engineeringState) {},
              builder: (context, engineeringState) {
                return Column(
                  children: [
                    appBarShadow(),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("工程列表"),

                          // IconButton(
                          //   iconSize: 40,
                          //   onPressed: () {
                          //     // updateEngineeringDialog(false, context);
                          //   },
                          //   icon: const Icon(Icons.add_circle_outlined),
                          //   color: MyColorTheme.black,
                          // ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                ),
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                  child: Scrollbar(
                                    thumbVisibility: true, // 顯示水平滾動條
                                    controller: _horizontalController,
                                    child: SingleChildScrollView(
                                      controller: _horizontalController, // 水平滾動控制器
                                      scrollDirection: Axis.horizontal,
                                      child: Scrollbar(
                                        thumbVisibility: true, // 顯示垂直滾動條
                                        controller: _verticalController,
                                        child: SingleChildScrollView(
                                          controller: _verticalController, // 垂直滾動控制器
                                          child: Container(
                                            height: MediaQuery.of(context).size.height,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: DataTable(
                                              showCheckboxColumn: false,
                                              showBottomBorder: true,
                                              columns: const [
                                                DataColumn(label: Text('工程名稱')),
                                                DataColumn(label: Text('監造單位')),
                                                DataColumn(label: Text('施工廠商')),
                                                DataColumn(label: Text('影響數量')),
                                              ],
                                              rows: engineeringState.engineeringMap.values
                                                  .toList()
                                                  .map(
                                                    (engineering) => DataRow(
                                                      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                                        if (states.contains(WidgetState.hovered)) {
                                                          return Colors.white;
                                                        }
                                                        return null;
                                                      }),
                                                      cells: [
                                                        DataCell(Text(engineering.name)),
                                                        DataCell(Text(engineering.inspector)),
                                                        DataCell(
                                                          Container(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(engineering.contractor),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: 100,
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(
                                                              engineering.cameraCount.toString(),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      onSelectChanged: (isSelected) => {
                                                        print('Item ${engineering.id} is selected: $isSelected'),
                                                      },
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            BlocConsumer<EngineeringBloc, EngineeringState>(
                              listener: (context, engineeringBloc) {
                                // TODO: implement listener
                              },
                              builder: (context, engineeringBloc) {
                                EngineeringEntity entity = engineeringBloc.engineeringMap.values.first;
                                return Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 10, right: 15, left: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade300, width: 1),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("${entity.name}工程  案場列表"),
                                            Row(
                                              children: [
                                                Text(
                                                  DateFormat('yyyy/MM/dd').format(
                                                    DateTime.fromMillisecondsSinceEpoch(entity.startDatetime),
                                                  ),
                                                ),
                                                const Icon(Icons.arrow_right),
                                                Text(
                                                  DateFormat('yyyy/MM/dd').format(
                                                    DateTime.fromMillisecondsSinceEpoch(entity.endDatetime),
                                                  ),
                                                ),
                                              ],
                                            ),
                                           context.read<LoginBloc>().state.userEntity!.permission == 0 ? Container(): IconButton(
                                              iconSize: 40,
                                              onPressed: () {
                                                createLocationDialog(false, context, entity.id);
                                              },
                                              icon: const Icon(Icons.add_circle_outlined),
                                              color: MyColorTheme.black,
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey, width: 1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text('專任工程人員'),
                                                      Text(entity.engineer),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 30),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text('聯絡電話'),
                                                      Text(entity.phone),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 30),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text('工程概要'),
                                                      SizedBox(
                                                        width: 400,
                                                        child: Text(
                                                          entity.description,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            context.read<LoginBloc>().state.userEntity!.permission == 0 ? Container():  IconButton(
                                                icon: Container(
                                                  padding: const EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(50),
                                                    color: MyColorTheme.black,
                                                  ),
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  // 處理按鈕點擊事件
                                                  updateEngineeringDialog(true, context, entity);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        BlocConsumer<LocationBloc, LocationState>(
                                          listener: (context, locationState) {},
                                          builder: (context, locationState) {
                                            if (locationState.engineeringEntity == null) {
                                              return Container();
                                            }
                                            switch (locationState.runtimeType) {
                                              case LocationInitial:
                                              case LocationLoadingState:
                                                {
                                                  return const Center(
                                                    child: CircularProgressIndicator(),
                                                  );
                                                }
                                              case LocationShowingState:
                                                {
                                                  return Expanded(
                                                    child: (locationState is LocationLoadingState)
                                                        ? const Center(child: CircularProgressIndicator())
                                                        : SizedBox(
                                                            width: MediaQuery.of(context).size.width,
                                                            child: SingleChildScrollView(
                                                              child: DataTable(
                                                                showCheckboxColumn: false,
                                                                showBottomBorder: true,
                                                                columns: const [
                                                                  DataColumn(
                                                                    label: Text(
                                                                      '案場名稱',
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      '案場負責人',
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      '聯絡電話',
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      '案場狀態',
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      '開始時間',
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      '結束時間',
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      '備註',
                                                                    ),
                                                                  ),
                                                                ],
                                                                rows: locationState.locationMap.values
                                                                    .toList()
                                                                    .map(
                                                                      (locationItem) => DataRow(
                                                                        color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                                                          if (states.contains(WidgetState.hovered)) {
                                                                            return Colors.white;
                                                                          }
                                                                          return null;
                                                                        }),
                                                                        cells: [
                                                                          DataCell(Text(locationItem.name ?? '')),
                                                                          DataCell(Text(locationItem.manager ?? '')),
                                                                          DataCell(
                                                                            Container(
                                                                              alignment: Alignment.centerLeft,
                                                                              child: Text(
                                                                                locationItem.phone ?? '',
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(Text(PublicData.locationType[locationItem.state!])),
                                                                          DataCell(
                                                                            Text(
                                                                              DateFormat('yyyy/MM/dd').format(
                                                                                DateTime.fromMillisecondsSinceEpoch(locationItem.startDatetime!),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            Text(
                                                                              DateFormat('yyyy/MM/dd').format(
                                                                                DateTime.fromMillisecondsSinceEpoch(locationItem.endDatetime!),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            Container(
                                                                              width: 100,
                                                                              alignment: Alignment.centerLeft,
                                                                              child: Text(
                                                                                locationItem.description ?? '',
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                        onSelectChanged: (isSelected) {
                                                                          print('Item ${locationItem.id} is selected: $isSelected');
                                                                          locationState.locationEntityItem = locationItem;
                                                                          openDrawerLocationStream.add(locationItem);
                                                                          _scaffoldKey.currentState?.openEndDrawer();
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
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        });
  }
}
