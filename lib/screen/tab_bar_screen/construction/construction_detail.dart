import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';
import 'package:wsp_t3/utils/bloc/video_bloc/video_bloc.dart';

import '../../../utils/api/config.dart';
import '../../../utils/bloc/location_bloc/location_bloc.dart';
import '../../../utils/bloc/location_camera_bloc/location_camera_bloc.dart';
import '../../../utils/bloc/location_camera_record_bloc/location_camera_record_bloc.dart';
import '../../../utils/bloc/login_bloc/login_bloc.dart';
import '../../../utils/entity/camera.dart';
import '../../../utils/entity/location.dart';
import '../../../utils/public/color_theme.dart';
import '../../../utils/public/public_data.dart';
import '../../../utils/public/text_style.dart';

class ConstructionDetail extends StatefulWidget {
  LocationEntity? locationEntity;
  ConstructionDetail({super.key, this.locationEntity});

  @override
  State<ConstructionDetail> createState() => _ConstructionDetailState();
}

class _ConstructionDetailState extends State<ConstructionDetail> {
  // int _selectedIndex = 0;
  VideoBloc videoBloc = VideoBloc();

  BehaviorSubject<int> selectedIndex = BehaviorSubject<int>.seeded(0);
  BehaviorSubject<String> cameraIdStream = BehaviorSubject<String>();

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

  // 當按鈕被點擊時，更新選中的索引
  void _onButtonPressed(int index) {
    print('切換攝影機： ${cameraIdStream.hasValue} is selected: $index');
    if (index == 0) {
      // 辨識
      if (cameraIdStream.hasValue) {
        print('辨識URl-${Config.realTimeVideoIP}/${cameraIdStream.value}-ai/livestream/index.m3u8');
        videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${cameraIdStream.value}-ai/livestream/index.m3u8', isLive: true));
      }
    } else {
      if (cameraIdStream.hasValue) {
        print('原始URl-${Config.realTimeVideoIP}/${cameraIdStream.value}/livestream/index.m3u8');
        videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${cameraIdStream.value}/livestream/index.m3u8', isLive: true));
      }
    }
    selectedIndex.add(index);
  }

  void selectLocationCameraDialog(BuildContext context, LocationEntity locationEntity) {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Container(
            width: 600,
            height: 400,
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
                        '新增攝影機',
                        style: TextStyle(fontSize: MyTextStyle.text_16, color: MyColorTheme.white),
                      ),
                      const SizedBox(width: 20),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
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
                BlocConsumer<LocationCameraBloc, LocationCameraState>(
                  buildWhen: (previous, current) {
                    if (previous.runtimeType == LocationCameraAddingState && current.runtimeType == LocationCameraShowingState) {
                      Fluttertoast.showToast(
                        msg: "新增成功",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 3,
                      );
                      print('context.read<LocationCameraBloc>().state.cameraMap.values.first.id-----------${context.read<LocationCameraBloc>().state.cameraMap.values.first.id}');
                      context.read<LocationCameraRecordBloc>().add(
                            LocationCameraRecordInitialEvent(
                              skip: 0,
                              size: 50,
                              locationId: widget.locationEntity!.id!,
                              cameraId: context.read<LocationCameraBloc>().state.cameraMap.values.first.id,
                            ),
                          );
                      Navigator.of(context).pop();
                    }
                    if (previous.runtimeType == LocationCameraAddingState && current.runtimeType == LocationCameraErrorState) {
                      Fluttertoast.showToast(
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
                        child: state.unSelectedCameraMap.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.symmetric(vertical: 50),
                                      child: const Text(
                                        '目前無攝影機可選擇',
                                        style: TextStyle(color: MyColorTheme.white, fontSize: MyTextStyle.text_20),
                                      )),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: MyColorTheme.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text('返回'),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                                '選擇攝影機',
                                                style: TextStyle(color: MyColorTheme.white),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              context.read<LocationCameraBloc>().state.unSelectedCameraMap.isEmpty
                                                  ? const Text('目前無攝影機可選擇')
                                                  : DropdownButtonFormField<CameraEntity>(
                                                      value: state.unSelectedCameraMap.values.first, // 預設值
                                                      onChanged: (value) {
                                                        state.selectCameraStream.add(value!);
                                                      },
                                                      // validator: (CameraEntity entity) {
                                                      //   if (value == null || value.isEmpty) {
                                                      //     return '請選擇一個選項';
                                                      //   }
                                                      //   return null;
                                                      // },
                                                      items: state.unSelectedCameraMap.values.toList().map((CameraEntity entity) {
                                                        return DropdownMenuItem<CameraEntity>(
                                                          value: entity,
                                                          child: Text(
                                                            entity.name,
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
                                        Expanded(flex: 1, child: Container()),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          flex: 1,
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                print('-----------${state.selectCameraStream.value.name}-------${locationEntity.id}');
                                                context.read<LocationCameraBloc>().add(CreateLocationCameraEvent(locationId: locationEntity.id!, cameraId: state.selectCameraStream.value.id));
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
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void editLocationDialog(bool isEdit, BuildContext context, LocationEntity? locationEntity) {
    String localTypeName = PublicData.locationType[locationEntity!.state!];

    if (isEdit) {
      _nameController.text = locationEntity.name!;
      _managerController.text = locationEntity.manager!;
      _phoneController.text = locationEntity.phone!;
      _descriptionController.text = locationEntity.description!;
      _stateController.text = PublicData.locationType[locationEntity.state!];
      _startDatetimeController.text = DateFormat('yyyy/MM/dd').format(DateTime.fromMillisecondsSinceEpoch(locationEntity.startDatetime!));
      _endDatetimeController.text = DateFormat('yyyy/MM/dd').format(DateTime.fromMillisecondsSinceEpoch(locationEntity.endDatetime!));
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
                    if (previous.runtimeType == LocationEditingState && current.runtimeType == LocationShowingState) {
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
                                          labelText: locationEntity.name,
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
                                          labelText: locationEntity.manager,
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
                                          labelText: locationEntity.phone,
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
                                          labelText: PublicData.getDateForm(locationEntity.startDatetime!),
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
                                          labelText: PublicData.getDateForm(locationEntity.endDatetime!),
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
                                          labelText: locationEntity.description,
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
                                  child: isEdit
                                      ? Container()
                                      : Column(
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
                                              maxLines: 1,
                                              textInputAction: TextInputAction.done,
                                              cursorColor: MyColorTheme.white,
                                              style: const TextStyle(color: MyColorTheme.white),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5),
                                                  borderSide: const BorderSide(color: MyColorTheme.white, width: 1),
                                                ),
                                                labelText: '輸入名稱',
                                                labelStyle: const TextStyle(color: MyColorTheme.white),
                                                floatingLabelBehavior: FloatingLabelBehavior.never,

                                                // // 未獲得焦點時的邊框樣式
                                                // enabledBorder: OutlineInputBorder(
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
                                        if (nameKey.currentState!.validate() & managerKey.currentState!.validate() & phoneKey.currentState!.validate() & descriptionKey.currentState!.validate()) {
                                          print('送出資訊------${widget.locationEntity!.id}---${_nameController.text}---${_managerController.text}---${_phoneController.text}---${PublicData.locationType.indexOf(localTypeName)}---${DateFormat('yyyy/MM/dd').parse(_startDatetimeController.text).toLocal().millisecondsSinceEpoch}---${DateFormat('yyyy/MM/dd').parse(_endDatetimeController.text).toLocal().millisecondsSinceEpoch}');

                                          context.read<LocationBloc>().add(
                                                UpdateLocationEvent(
                                                  id: widget.locationEntity!.id!,
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

  Widget _buildButton(int index, String text) {
    return StreamBuilder<int>(
        stream: selectedIndex,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
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
            ),
          );
        });
  }

  @override
  void initState() {
    context.read<LocationCameraBloc>().add(RefreshLocationCameraEvent(skip: 0, size: 10, locationId: widget.locationEntity!.id!));
    super.initState();
  }

  @override
  void dispose() {
    videoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildButton(0, '辨識影像'),
              _buildButton(1, '原始影像'),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 400,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
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
            height: 20,
          ),
          BlocConsumer<LocationBloc, LocationState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, locationState) {
              LocationEntity entity = locationState.locationEntityItem!;
              return Container(
                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 130,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('案場名稱'),
                                  Text(
                                    entity.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 130,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('開始時間'),
                                  Text(
                                    DateFormat('yyyy/MM/dd').format(
                                      DateTime.fromMillisecondsSinceEpoch(entity.startDatetime!),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 130,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('結束時間'),
                                  Text(
                                    DateFormat('yyyy/MM/dd').format(
                                      DateTime.fromMillisecondsSinceEpoch(entity.endDatetime!),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 130,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('專案狀態'),
                                  Text(
                                    PublicData.locationType[entity.state!],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      context.read<LoginBloc>().state.userEntity!.permission == 0 ? Container():  MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              editLocationDialog(true, context, widget.locationEntity);
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              // margin: const EdgeInsets.symmetric(horizontal: 20),
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
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 130,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('案場負責人'),
                                  Text(
                                    entity.manager ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 130,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('聯絡電話'),
                                  Text(
                                    entity.phone ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 130,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('備註'),
                                  Tooltip(
                                    message: entity.description,
                                    child: Text(
                                      entity.description ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 130,
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(''),
                                  Text(''),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 35,
                          height: 35,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('案場攝影機列表'),
           context.read<LoginBloc>().state.userEntity!.permission == 0 ? Container():   IconButton(
                iconSize: 40,
                onPressed: () {
                  // 新增攝影機

                  selectLocationCameraDialog(context, widget.locationEntity!);
                },
                icon: const Icon(Icons.add_circle_outlined),
                color: MyColorTheme.black,
              ),
            ],
          ),
          BlocConsumer<LocationCameraBloc, LocationCameraState>(
            buildWhen: (previous, current) {
              if (previous.runtimeType == LocationCameraRemovingState && current.runtimeType == LocationCameraShowingState) {
                Fluttertoast.showToast(
                  msg: "移除成功",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 3,
                );
              }
              if (previous.runtimeType == LocationCameraRemovingState && current.runtimeType == LocationCameraErrorState) {
                Fluttertoast.showToast(
                  msg: "移除失敗",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 3,
                );
              }
              return true;
            },
            listener: (context, state) {
              if (state is LocationCameraInitialCompleteState || state is LocationCameraShowingState) {
                // selectCameraStream.add(state.unSelectedCameraMap.values.toList()[0].id);
                if (state.cameraMap.isNotEmpty) {
                  cameraIdStream.add(state.cameraMap.values.toList()[0].id);
                  videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${cameraIdStream.value}-ai/livestream/index.m3u8', isLive: true));
                } else {
                  // 表示資料為空
                  videoBloc.add(VideoLoadErrorEvent());
                }
                // videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${state.cameraMap.values.toList()[0].id}/index.m3u8', isLive: true));
              }
            },
            builder: (context, state) {
              if (state.cameraMap.isEmpty) {
                return const Center(
                  child: Text('暫無攝影機'),
                );
              }
              return SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DataTable(
                    showCheckboxColumn: false,
                    showBottomBorder: true,
                    columns: const [
                      DataColumn(label: Text('攝影機名稱')),
                      DataColumn(label: Text('綁定開始時間')),
                      DataColumn(label: Text('狀態')),
                      DataColumn(label: Text('解除綁定')),
                    ],
                    rows: state.cameraMap.values
                        .toList()
                        .map(
                          (cameraEntity) => DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.white;
                              }
                              return null;
                            }),
                            cells: [
                              DataCell(
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerLeft,
                                  child: Text(cameraEntity.name),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 100,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    DateFormat('yyyy/MM/dd').format(
                                      DateTime.fromMillisecondsSinceEpoch(cameraEntity.startDatetime),
                                    ),
                                  ),
                                ),
                              ),
                              // DataCell(
                              //   Container(
                              //     alignment: Alignment.centerLeft,
                              //     child: Text(cameraEntity.endDatetime.toString()),
                              //   ),
                              // ),
                              DataCell(
                                Container(
                                  width: 100,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    PublicData.cameraType[cameraEntity.state],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 40,
                                  alignment: Alignment.centerLeft,
                                  child:context.read<LoginBloc>().state.userEntity!.permission == 0 ? Container(): IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      context.read<LocationCameraBloc>().add(DeleteLocationCameraEvent(locationId: widget.locationEntity!.id!, cameraId: cameraEntity.id));
                                      print('delete ${cameraEntity.id}');
                                    },
                                  ),
                                ),
                              ),
                            ],
                            onSelectChanged: (isSelected) {
                              print('切換攝影機： ${cameraEntity.id} is selected: $isSelected');
                              cameraIdStream.add(cameraEntity.id);
                              if (selectedIndex.value == 0) {
                                videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${cameraEntity.id}-ai/livestream/index.m3u8', isLive: true));
                              } else {
                                videoBloc.add(VideoLoadEvent('${Config.realTimeVideoIP}/${cameraEntity.id}/livestream/index.m3u8', isLive: true));
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
          ),
          // GestureDetector(
          //   onTap: () {
          //     print('刪除案場');
          //   },
          //   child: Container(
          //     width: double.infinity,
          //     margin: const EdgeInsets.symmetric(vertical: 20),
          //     alignment: Alignment.center,
          //     height: 50,
          //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(10),
          //       color: Colors.red,
          //     ),
          //     child: const Text('刪除案場'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
