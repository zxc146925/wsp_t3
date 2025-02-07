import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wsp_t3/utils/entity/incident.dart';
import 'package:wsp_t3/utils/public/color_theme.dart';
import 'package:wsp_t3/utils/public/public_data.dart';
import '../../../utils/bloc/camera_list_statistic_bloc/camera_list_statistic_bloc.dart';
import '../../../utils/bloc/camera_manager_bloc/camera_manager_bloc.dart';
import '../../../utils/public/appbar_shadow.dart';
import 'tab_screen/video_live.dart';
import 'tab_screen/video_log.dart';
import 'tab_screen/video_manager.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  BehaviorSubject<int> selectedIndexStream = BehaviorSubject<int>.seeded(0);
  final BehaviorSubject<bool> _isExpandedStream = BehaviorSubject<bool>.seeded(false); // 控制輸入框的展開/收縮
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    print('初始影像管理');
    super.initState();
  }

  // 當按鈕被點擊時，更新選中的索引
  void _onButtonPressed(int index) {
    selectedIndexStream.add(index);
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

  // @override
  // bool get wantKeepAlive => true;

  // Future<void> _selectDate(bool isStart) async {
  //   DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //     builder: (context, child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           primaryColor: Colors.blue,
  //           textButtonTheme: TextButtonThemeData(
  //             style: TextButton.styleFrom(foregroundColor: Colors.blue),
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );

  //   if (pickedDate != null) {
  //     setState(() {
  //       if (isStart) {
  //         _startDate = pickedDate;
  //       } else {
  //         _endDate = pickedDate;
  //       }
  //     });
  //   }
  // }

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<IncidentEntity>(
        stream: PublicData.selectIncidentSubject,
        builder: (context, snapshot) {
          return Scaffold(
            // key:PublicData.incidentScaffoldKey,
            // endDrawer: snapshot.data != null ? videoIncidentDrawer(context, PublicData.selectIncidentSubject.valueOrNull) : null,
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                appBarShadow(),
                Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildButton(0, '實時影像'),
                                _buildButton(1, '影像紀錄'),
                                _buildButton(2, '攝影機管理'),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                StreamBuilder<int>(
                                    stream: selectedIndexStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.data == null) {
                                        return Container();
                                      }
                                      return (snapshot.data == 0) || (snapshot.data == 2)
                                          ? Container()
                                          : StreamBuilder<bool>(
                                              stream: _isExpandedStream,
                                              builder: (context, snapshot) {
                                                if (snapshot.data == null) {
                                                  return Container();
                                                }
                                                return Row(
                                                  children: [
                                                    AnimatedContainer(
                                                      duration: const Duration(milliseconds: 300),
                                                      constraints: BoxConstraints(
                                                        maxWidth: snapshot.data! ? MediaQuery.of(context).size.width : 0, // 控制展開寬度
                                                      ),
                                                      height: 50,
                                                      child: SingleChildScrollView(
                                                        scrollDirection: Axis.horizontal, // 防止溢出
                                                        child: Row(
                                                          children: [
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: MyColorTheme.black, // 按鈕的背景顏色
                                                                foregroundColor: Colors.white, // 按鈕的文字顏色
                                                                // textStyle: const TextStyle(fontSize: 16), // 按鈕文字的樣式
                                                              ),
                                                              onPressed: () => _selectDateRange(context),
                                                              child: Text(
                                                                _selectedDateRange == null ? '選擇日期範圍' : '${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.end)}',
                                                              ),
                                                            ),
                                                            const SizedBox(width: 16),
                                                            // ElevatedButton(
                                                            //   onPressed: () {},
                                                            //   child: const Text('確定'),
                                                            // ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(snapshot.data! ? Icons.close : Icons.search),
                                                      onPressed: () {
                                                        if (_selectedDateRange != null) {
                                                          _selectedDateRange = null;
                                                          context.read<CameraListStatisticBloc>().add(
                                                                CameraListStatisticInitEvent(
                                                                  skip: 0,
                                                                  size: 20,
                                                                  cameraId: context.read<CameraManagerBloc>().state.cameraManagerMap.values.toList()[0].id,
                                                                  cameraName: context.read<CameraManagerBloc>().state.cameraManagerMap.values.toList()[0].cameraName,
                                                                ),
                                                              );
                                                        }
                                                        _isExpandedStream.add(!snapshot.data!); // 點擊切換展開狀態
                                                        // setState(() {
                                                        //   _isExpanded = !_isExpanded; // 點擊切換展開狀態
                                                        // });
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                    }),
                                const SizedBox(width: 10),
                              ],
                            ),

                            // Row(
                            //   children: [
                            //     StreamBuilder<int>(
                            //         stream: selectedIndexStream,
                            //         builder: (context, snapshot) {
                            //           if (snapshot.data == null) {
                            //             return Container();
                            //           }
                            //           return (snapshot.data == 0) ? Container() : const Icon(Icons.search);
                            //         }),
                            //     const SizedBox(width: 10),
                            //     // 新增使用，目前暫時關閉
                            //     // _selectedIndex == 2
                            //     //     ? MouseRegion(
                            //     //         cursor: SystemMouseCursors.click,
                            //     //         child: GestureDetector(
                            //     //           onTap: () {
                            //     //             PoPo.showCameraDialog(false, context,null);
                            //     //           },
                            //     //           child: Container(
                            //     //             width: 30,
                            //     //             height: 30,
                            //     //             decoration: BoxDecoration(
                            //     //               borderRadius: BorderRadius.circular(50),
                            //     //               color: MyColorTheme.black,
                            //     //             ),
                            //     //             child: const Icon(
                            //     //               Icons.add,
                            //     //               color: Colors.white,
                            //     //             ),
                            //     //           ),
                            //     //         ),
                            //     //       )
                            //     //     : Container(),
                            //   ],
                            // )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<int>(
                          stream: selectedIndexStream,
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Container();
                            }
                            return IndexedStack(
                              sizing: StackFit.expand,
                              index: snapshot.data,
                              children: const [
                                VideoLiveTabScreen(),
                                VideoLogTabScreen(),
                                VideoManagerTabScreen(),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
