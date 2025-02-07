import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wsp_t3/utils/bloc/incident_camera_bloc/incident_camera_bloc.dart';

import '../../../../utils/api/config.dart';
import '../../../../utils/bloc/camera_list_statistic_bloc/camera_list_statistic_bloc.dart';
import '../../../../utils/bloc/camera_manager_bloc/camera_manager_bloc.dart';
import '../../../../utils/bloc/incident_bloc/incident_bloc.dart';
import '../../../../utils/bloc/video_record_bloc/video_record_bloc.dart';
import '../../../../utils/entity/incident.dart';
import '../../../../utils/public/color_theme.dart';
import '../../../../utils/public/public_data.dart';
import '../../../../utils/public/text_style.dart';
import '../video_record.dart';

// 影像管理/影像記錄
class VideoLogTabScreen extends StatefulWidget {
  const VideoLogTabScreen({super.key});

  @override
  State<VideoLogTabScreen> createState() => _VideoLogTabScreenState();
}

class _VideoLogTabScreenState extends State<VideoLogTabScreen> {
  BehaviorSubject<int> selectedIndexStream = BehaviorSubject<int>.seeded(0);
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  // CameraListStatisticBloc cameraListStatisticBloc = CameraListStatisticBloc();
  IncidentCameraBloc incidentCameraBloc = IncidentCameraBloc();

  VideoRecordBloc videoRecordBloc = VideoRecordBloc();
  BehaviorSubject<String> selectCameraStream = BehaviorSubject<String>.seeded('');

  // bool _isExpanded = false;
  final BehaviorSubject<bool> _isExpandedStream = BehaviorSubject<bool>.seeded(false); // 控制輸入框的展開/收縮
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  String stateName = '';

  // 當按鈕被點擊時，更新選中的索引
  void _onButtonPressed(int index) {
    selectedIndexStream.add(index);
  }

  @override
  void initState() {
    context.read<CameraManagerBloc>().add(CameraManagerInitialEvent(skip: 0, size: 10));
    _verticalController.addListener(
      () {
        if (_verticalController.position.pixels >= _verticalController.position.maxScrollExtent - 200 && context.read<CameraListStatisticBloc>().state is! CameraListStatisticLoadingMore && context.read<CameraListStatisticBloc>().state is! CameraListStatisticReadMax) {
          // 當滾動到底部附近且尚未加載更多或達到最大數據時，發送拉取更多的事件
          print('拉取更多資料');
          context.read<CameraListStatisticBloc>().add(
                CameraListStatisticLoadMoreEvent(
                  skip: context.read<CameraListStatisticBloc>().state.cameraListStatisticViewModelList.length,
                  size: 20,
                  cameraId: context.read<CameraManagerBloc>().state.cameraIdStream.value,
                ),
              );
        }
      },
    );
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
                  bloc: incidentCameraBloc,
                  buildWhen: (previous, current) {
                    if (previous.runtimeType == IncidentCameraEditingState && current.runtimeType == IncidentCameraShowing) {
                      Fluttertoast.showToast(
                        msg: "更新成功",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 3,
                      );
                    }
                    if (previous.runtimeType == IncidentCameraEditingState && current.runtimeType == IncidentCameraError) {
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
                                          incidentCameraBloc.add(UpdateIncidentCameraEvent(isEdit: true, incidentId: entity.id, state: PublicData.stateListName.indexOf(stateName), isPinned: entity.isPinned));
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

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.red, // 主色調，影響選中的日期顏色
            colorScheme: ColorScheme.light(
              primary: Colors.red, // 選中日期的背景顏色
              onPrimary: Colors.white, // 選中日期文字的顏色
              surface: Colors.red.shade100, // 日期選擇器的表面顏色
            ),
            datePickerTheme: DatePickerThemeData(
              rangeSelectionBackgroundColor: MyColorTheme.red.withOpacity(.5), // 選中範圍的背景顏色
              rangeSelectionOverlayColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? MyColorTheme.red.withOpacity(.3) : Colors.transparent),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // 確定和取消按鈕的文字顏色
              ),
            ),
            dialogBackgroundColor: Colors.white, // 日期選擇器背景顏色
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black), // 日期文字顏色
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        // print('pickedDateRange.start---${pickedDateRange.start.millisecondsSinceEpoch}---pickedDateRange.end---${pickedDateRange.end.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)).millisecondsSinceEpoch}');
        context.read<CameraListStatisticBloc>().add(
              CameraListStatisticSearchEvent(
                skip: 0,
                size: 30,
                startDatetime: pickedDateRange.start.millisecondsSinceEpoch,
                endDatetime: pickedDateRange.end.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)).millisecondsSinceEpoch,
              ),
            );
        _selectedDateRange = pickedDateRange;
      });
    }
  }

  Widget _buildButton(int index, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: StreamBuilder<int>(
          stream: selectedIndexStream,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container();
            }
            return ElevatedButton(
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
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Row(
                children: [
                  // 左側表格區域
                  BlocConsumer<CameraManagerBloc, CameraManagerState>(
                    listener: (context, cameraManagerState) {
                      if (cameraManagerState is CameraManagerInitialCompleteState) {
                        print('cameraId-----------${cameraManagerState.cameraManagerMap.values.toList()[0].id}');
                        context.read<CameraListStatisticBloc>().add(
                              CameraListStatisticInitEvent(
                                skip: 0,
                                size: 50,
                                cameraId: cameraManagerState.cameraManagerMap.values.toList()[0].id,
                                cameraName: cameraManagerState.cameraManagerMap.values.toList()[0].cameraName,
                              ),
                            );
                      }
                    },
                    builder: (context, cameraManagerState) {
                      return Expanded(
                        flex: 2,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: cameraManagerState.cameraManagerMap.isEmpty
                              ? const Center(child: Text('目前無攝影機資訊'))
                              : DataTable(
                                  showCheckboxColumn: false,
                                  showBottomBorder: true,
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        '狀態',
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        '攝影機名稱',
                                      ),
                                    ),
                                  ],
                                  rows: cameraManagerState.cameraManagerMap.values
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
                                            DataCell(Container(
                                              width: 10,
                                              height: 10,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: row.state == 0 ? Colors.red : Colors.green,
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                            )),
                                            DataCell(
                                              Container(
                                                child: Text(
                                                  row.cameraName,
                                                ),
                                              ),
                                            ),
                                          ],
                                          onSelectChanged: (isSelected) {
                                            selectCameraStream.add(row.id);
                                            context.read<CameraListStatisticBloc>().add(
                                                  CameraListStatisticInitEvent(
                                                    skip: 0,
                                                    size: 50,
                                                    cameraId: row.id,
                                                    cameraName: row.cameraName,
                                                  ),
                                                );
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                      );
                    },
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: BlocConsumer<CameraListStatisticBloc, CameraListStatisticState>(
                      listener: (context, state) {
                        if (state is CameraListStatisticInitialComplete) {
                          incidentCameraBloc.add(
                            IncidentCameraInitialEvent(
                              skip: 0,
                              size: 30,
                              cameraId: context.read<CameraManagerBloc>().state.cameraManagerMap.values.first.id,
                              startDatetime: PublicData.truncateToDateMilliseconds(state.cameraListStatisticViewModelList.first.date),
                              endDatetime: PublicData.truncateToDateMilliseconds(state.cameraListStatisticViewModelList.first.date + 86400000) - 1000, //強制添加24小時 -1秒
                            ),
                          );
                          videoRecordBloc.add(
                            VideoRecordInitEvent(
                              cameraId: context.read<CameraManagerBloc>().state.cameraManagerMap.values.first.id,
                              startDatetime: PublicData.truncateToDateMilliseconds(state.cameraListStatisticViewModelList.first.date),
                              endDatetime: PublicData.truncateToDateMilliseconds(state.cameraListStatisticViewModelList.first.date + 86400000) - 1000, //強制添加24小時 -1秒
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        switch (state.runtimeType) {
                          case CameraListStatisticInitial:
                          case CameraListStatisticLoading:
                            {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          case CameraListStatisticShowing:
                          case CameraListStatisticLoadingMore:
                          case CameraListStatisticInitialComplete:
                          case CameraListStatisticReadMax:
                            {
                              return Scrollbar(
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
                                        // height: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: DataTable(
                                          showCheckboxColumn: false,
                                          showBottomBorder: true,
                                          columns: const [
                                            DataColumn(label: Text('影像日期')),
                                            DataColumn(label: Text('攝影機名稱')),
                                            DataColumn(label: Text('異常數量')),
                                            DataColumn(label: Text('影像數量')),
                                          ],
                                          rows: state.cameraListStatisticViewModelList
                                              .map(
                                                (row) => DataRow(
                                                  color: WidgetStateProperty.resolveWith<Color?>(
                                                    (Set<WidgetState> states) {
                                                      if (states.contains(WidgetState.hovered)) {
                                                        return Colors.white;
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  cells: [
                                                    DataCell(
                                                      Text(
                                                        PublicData.getDateForm(row.date),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        row.cameraName,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        row.incidentCount.toString(),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        row.recordCount.toString(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                  onSelectChanged: (isSelected) {
                                                    print('選擇某天影像的：影像日期：${row.date}--攝影機ID:${row.cameraId}---攝影機名稱：${row.cameraName}--異常數量：${row.incidentCount}--影像數量：${row.recordCount}');

                                                    incidentCameraBloc.add(
                                                      IncidentCameraInitialEvent(
                                                        skip: 0,
                                                        size: 30,
                                                        cameraId: row.cameraId,
                                                        startDatetime: PublicData.truncateToDateMilliseconds(row.date),
                                                        endDatetime: PublicData.truncateToDateMilliseconds(row.date + 86400000) - 1000, //強制添加24小時 -1秒
                                                      ),
                                                    );
                                                    videoRecordBloc.add(
                                                      VideoRecordInitEvent(
                                                        cameraId: row.cameraId,
                                                        startDatetime: PublicData.truncateToDateMilliseconds(row.date),
                                                        endDatetime: PublicData.truncateToDateMilliseconds(row.date + 86400000) - 1000, //強制添加24小時 -1秒
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          default:
                            {
                              return const SizedBox.shrink();
                            }
                        }
                      },
                    ),
                  ),
                  // 右側區域
                  Expanded(
                    flex: 7,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 上方按鈕
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _buildButton(0, '異常事件'),
                                  _buildButton(1, '影像紀錄'),
                                ],
                              ),
                              StreamBuilder<int>(
                                stream: selectedIndexStream,
                                builder: (context, snapshot) {
                                  if (snapshot.data == null) {
                                    return Container();
                                  }
                                  return (snapshot.data == 1)
                                      ? Container()
                                      : StreamBuilder<bool>(
                                          stream: _isExpandedStream,
                                          builder: (context, snapshot) {
                                            if (snapshot.data == null) {
                                              return Container();
                                            }
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // 動畫容器，控制展開效果
                                                AnimatedContainer(
                                                  duration: const Duration(milliseconds: 300),
                                                  constraints: BoxConstraints(
                                                    maxWidth: snapshot.data! ? 300 : 0, // 動態控制寬度
                                                    maxHeight: 60,
                                                  ),
                                                  height: snapshot.data! ? 50 : 0, // 控制高度
                                                  child: snapshot.data!
                                                      ? TextFormField(
                                                          controller: _searchController,
                                                          decoration: InputDecoration(
                                                            hintText: '輸入搜索內容',
                                                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                          onFieldSubmitted: (value) {
                                                            print('輸入內容為：$value');
                                                            incidentCameraBloc.add(
                                                              IncidentCameraSearchEvent(
                                                                skip: 0,
                                                                size: 30,
                                                                cameraId: context.read<CameraManagerBloc>().state.cameraManagerMap.values.first.id,
                                                                startDatetime: PublicData.truncateToDateMilliseconds(context.read<CameraListStatisticBloc>().state.cameraListStatisticViewModelList.first.date),
                                                                endDatetime: PublicData.truncateToDateMilliseconds(context.read<CameraListStatisticBloc>().state.cameraListStatisticViewModelList.first.date + 86400000) - 1000, //強制添加24小時 -1秒
                                                                incidentState: PublicData.getTextToincidentState(value),
                                                                keyword: value,
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(width: 10), // 搜索按鈕間距
                                                // 搜索或關閉按鈕
                                                IconButton(
                                                  icon: Icon(snapshot.data! ? Icons.close : Icons.search),
                                                  onPressed: () {
                                                    _isExpandedStream.add(!snapshot.data!); // 點擊切換展開狀態
                                                    print('按鈕-------${_isExpandedStream.value}');
                                                    if (_isExpandedStream.value == false) {
                                                      _searchController.clear();
                                                      incidentCameraBloc.add(
                                                        IncidentCameraInitialEvent(
                                                          skip: 0,
                                                          size: 30,
                                                          cameraId: incidentCameraBloc.state.cameraId!,
                                                          startDatetime: incidentCameraBloc.state.startDatetime!,
                                                          endDatetime: incidentCameraBloc.state.endDatetime!,
                                                        ),
                                                      );
                                                    }
                                                    // _isExpandedStream.add(!snapshot.data!); // 點擊切換展開狀態
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                },
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(height: 2, color: Colors.grey),
                          ),
                          // 動態內容區域
                          StreamBuilder<int>(
                              stream: selectedIndexStream,
                              builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                  return Container();
                                }
                                return Expanded(
                                  child: IndexedStack(
                                    sizing: StackFit.expand,
                                    index: snapshot.data,
                                    children: [
                                      BlocProvider(
                                        create: (context) => incidentCameraBloc,
                                        child: BlocConsumer<IncidentCameraBloc, IncidentCameraState>(
                                          bloc: incidentCameraBloc,
                                          buildWhen: (previous, current) {
                                            if (previous.runtimeType == IncidentCameraEditingState && current.runtimeType == IncidentCameraShowing) {
                                              Navigator.of(context).pop();
                                            }
                                            return true;
                                          },
                                          listener: (context, state) {},
                                          builder: (context, state) {
                                            switch (state.runtimeType) {
                                              case IncidentCameraInitial:
                                              case IncidentCameraLoading:
                                                {
                                                  return const Center(child: CircularProgressIndicator());
                                                }
                                              case IncidentCameraShowing:
                                              case IncidentCameraLoadingMore:
                                              case IncidentCameraReadMoreMaxState:
                                                {
                                                  if (state.incidentCameraMap.isEmpty) {
                                                    return Center(
                                                      child: Container(
                                                        child: const Text('目前暫無異常事件'),
                                                      ),
                                                    );
                                                  }
                                                  return Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      state is IncidentCameraLoadingMore
                                                          ? Center(
                                                              child: Container(
                                                                child: const CircularProgressIndicator(),
                                                              ),
                                                            )
                                                          : Container(),
                                                      ListView.builder(
                                                        itemCount: state.incidentCameraMap.length,
                                                        shrinkWrap: true,
                                                        itemBuilder: (context, index) {
                                                          if (index > state.incidentCameraMap.length - 5 && state.runtimeType != IncidentCameraReadMoreMaxState && _searchController.text == '') {
                                                            incidentCameraBloc.add(IncidentCameraLoadMoreEvent(skip: state.incidentCameraMap.length, size: 20));
                                                          }

                                                          IncidentEntity entity = state.incidentCameraMap.values.toList()[index];
                                                          return Column(
                                                            children: [
                                                              MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    stateName = PublicData.stateListName[entity.state];
                                                                    _showEditDialog(entity);
                                                                    // PublicData.selectIncidentSubject.add(entity);
                                                                    // PublicData.incidentScaffoldKey.currentState?.openEndDrawer();
                                                                  },
                                                                  child: Container(
                                                                    margin: const EdgeInsets.symmetric(vertical: 10),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        // 左側紅色區塊
                                                                        Flexible(
                                                                          flex: 2,
                                                                          child: SizedBox(
                                                                            height: 200,
                                                                            child: CachedNetworkImage(
                                                                              imageUrl: "${Config.mediaSocketUrl}/file/${entity.imageUrl}",
                                                                              fit: BoxFit.cover,
                                                                              progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                                                                                decoration: const BoxDecoration(
                                                                                  borderRadius: BorderRadius.all(
                                                                                    Radius.circular(10),
                                                                                  ),
                                                                                ),
                                                                                width: 400,
                                                                                child: Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Container(
                                                                                decoration: const BoxDecoration(
                                                                                  borderRadius: BorderRadius.all(
                                                                                    Radius.circular(10),
                                                                                  ),
                                                                                ),
                                                                                width: 400,
                                                                                child: const Icon(Icons.error),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(width: 10), // 添加間距
                                                                        // 右側資訊區塊
                                                                        Flexible(
                                                                          flex: 3,
                                                                          child: Container(
                                                                            height: 200,
                                                                            padding: const EdgeInsets.only(left: 20, bottom: 20),
                                                                            child: Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(PublicData.getDateTimeForm(entity.startDatetime)),
                                                                                Container(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                    color: Colors.grey.shade300,
                                                                                    border: Border.all(
                                                                                      color: Colors.grey.shade300,
                                                                                      width: 1,
                                                                                    ),
                                                                                  ),
                                                                                  child: Text(PublicData.stateListName[entity.state]),
                                                                                ),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    const Text('偵測到不符合'),
                                                                                    SelectableText(entity.title),
                                                                                    Text(PublicData.getArticles(entity.type)),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const Divider(
                                                                height: 1,
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                }
                                              default:
                                                {
                                                  return Container();
                                                }
                                            }
                                          },
                                        ),
                                      ),
                                      BlocProvider(
                                        create: (context) => videoRecordBloc,
                                        child: VideoRecord(bloc: videoRecordBloc),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
