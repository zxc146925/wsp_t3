import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../../../utils/bloc/incident_bloc/incident_bloc.dart';
import '../../../utils/public/appbar_shadow.dart';
import '../../../utils/public/color_theme.dart';
import '../../../utils/public/public_data.dart';
import '../../../utils/view_model/incident_list.dart';
import 'anomaly_drawer.dart';

class AnomalyScreen extends StatefulWidget {
  const AnomalyScreen({super.key});

  @override
  State<AnomalyScreen> createState() => _AnomalyScreenState();
}

class _AnomalyScreenState extends State<AnomalyScreen> with AutomaticKeepAliveClientMixin {
  // List<AnomalyEntity> anomalyList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final BehaviorSubject<IncidentListViewModel> selectIncidentSubject = BehaviorSubject<IncidentListViewModel>();

  bool _isExpanded = false; // 控制輸入框的展開/收縮
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    // anomalyList = getAnomalyEntityData();
    super.initState();
    // 設定滾動監聽器
    _scrollController.addListener(
      () {
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && context.read<IncidentBloc>().state is! IncidentLoadingMoreState && context.read<IncidentBloc>().state is! IncidentReadMoreMaxState) {
          // 當滾動到底部附近且尚未加載更多或達到最大數據時，發送拉取更多的事件
          print('拉取更多資料');
          if (_searchController.text == '' && _selectedDateRange == null) {
            context.read<IncidentBloc>().add(
                  IncidentLoadMoreEvent(
                    skip: context.read<IncidentBloc>().state.incidentMap.length,
                    size: 30,
                  ),
                );
          } else {
            // 搜尋的讀取更多資料
            context.read<IncidentBloc>().add(
                  IncidentSearchLoadMoreEvent(
                    skip: context.read<IncidentBloc>().state.incidentMap.length,
                    size: 30,
                    keyword: _searchController.text,
                    startDatetime: _selectedDateRange?.start.millisecondsSinceEpoch == null ? null : PublicData.truncateToDateMilliseconds(_selectedDateRange!.start.millisecondsSinceEpoch),
                    endDatetime: _selectedDateRange?.start.millisecondsSinceEpoch == null ? null : PublicData.truncateToDateMilliseconds(_selectedDateRange!.end.add(const Duration(days: 1)).millisecondsSinceEpoch) - 1000,
                    incidentState: PublicData.getTextToincidentState(
                      _searchController.text,
                    ),
                  ),
                );
          }
        }
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
        // context.read<CameraListStatisticBloc>().add(
        //       CameraListStatisticSearchEvent(
        //         skip: 0,
        //         size: 30,
        //         startDatetime: pickedDateRange.start.millisecondsSinceEpoch,
        //         endDatetime: pickedDateRange.end.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)).millisecondsSinceEpoch,
        //       ),
        //     );
        _selectedDateRange = pickedDateRange;
      });
    }
  }

  void _onIconTap(IncidentListViewModel row) {
    print('更新最愛----${row.id}---${row.isPinned}');
    context.read<IncidentBloc>().add(UpdateIncidentEvent(isEdit: false, incidentId: row.id, state: row.state, isPinned: !row.isPinned));
    // setState(() {
    //   row.isPinned = !row.isPinned;
    // });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<IncidentListViewModel>(
        stream: selectIncidentSubject,
        builder: (context, snapshot) {
          return Scaffold(
            key: _scaffoldKey,
            endDrawer: snapshot.data != null ? anomalyDrawer('異常資訊', context, selectIncidentSubject.valueOrNull) : null,
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                appBarShadow(),
                Column(
                  children: [
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("異常列表"),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 動畫容器，控制展開效果
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                constraints: BoxConstraints(
                                    maxWidth: _isExpanded ? MediaQuery.of(context).size.width * 0.4 : 0, // 動態控制寬度
                                    maxHeight: 60),
                                height: _isExpanded ? 50 : 0, // 控制高度
                                child: Visibility(
                                  visible: _isExpanded, // 當展開時顯示內容
                                  child: Row(
                                    children: [
                                      // 選擇日期範圍按鈕
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: MyColorTheme.black, // 背景顏色
                                          foregroundColor: Colors.white, // 文字顏色
                                        ),
                                        onPressed: () => _selectDateRange(context),
                                        child: Text(
                                          _selectedDateRange == null ? '選擇日期' : '${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.end)}',
                                        ),
                                      ),
                                      const SizedBox(width: 10), // 間距
                                      // 搜索輸入框
                                      Expanded(
                                        child: TextFormField(
                                          controller: _searchController,
                                          decoration: InputDecoration(
                                            hintText: '輸入搜索內容',
                                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10), // 間距
                                      // 搜索確定按鈕
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: MyColorTheme.black, // 背景顏色
                                          foregroundColor: Colors.white, // 文字顏色
                                        ),
                                        onPressed: () {
                                          // print('搜尋內容: ${_searchController.text}');
                                          // print('開始時間: ${_selectedDateRange?.start.millisecondsSinceEpoch == null ? null : PublicData.truncateToDateMilliseconds(_selectedDateRange!.start.millisecondsSinceEpoch)}');
                                          // print('結束時間: ${_selectedDateRange?.start.millisecondsSinceEpoch == null ? null : PublicData.truncateToDateMilliseconds(_selectedDateRange!.end.add(const Duration(days: 1)).millisecondsSinceEpoch) - 1000}');
                                          // print('incidentState--${PublicData.getTextToincidentState(_searchController.text)}');

                                          // 可在此處加入搜索的功能
                                          context.read<IncidentBloc>().add(
                                                IncidentSearchEvent(
                                                  skip: 0,
                                                  size: 30,
                                                  keyword: _searchController.text,
                                                  startDatetime: _selectedDateRange?.start.millisecondsSinceEpoch == null ? null : PublicData.truncateToDateMilliseconds(_selectedDateRange!.start.millisecondsSinceEpoch),
                                                  endDatetime: _selectedDateRange?.start.millisecondsSinceEpoch == null ? null : PublicData.truncateToDateMilliseconds(_selectedDateRange!.end.add(const Duration(days: 1)).millisecondsSinceEpoch) - 1000,
                                                  incidentState: PublicData.getTextToincidentState(_searchController.text),
                                                ),
                                              );
                                        },
                                        child: const Text('確定'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10), // 搜索按鈕間距
                              // 搜索或關閉按鈕
                              IconButton(
                                icon: Icon(_isExpanded ? Icons.close : Icons.search),
                                onPressed: () {
                                  if (_isExpanded == true) {
                                    context.read<IncidentBloc>().add(IncidentInitEvent(skip: 0, size: 30));
                                    _selectedDateRange = null;
                                    _searchController.text = '';
                                  }
                                  setState(() {
                                    _isExpanded = !_isExpanded; // 切換展開狀態
                                  });
                                },
                              ),
                            ],
                          ),
                          // Icon(
                          //   Icons.search,
                          // ),
                        ],
                      ),
                    ),
                    BlocConsumer<IncidentBloc, IncidentState>(
                      listener: (context, incidentState) {
                        // TODO: implement listener
                      },
                      builder: (context, incidentState) {
                        switch (incidentState.runtimeType) {
                          case IncidentLoadingState:
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
                          case IncidentLoadingMoreState:
                          case IncidentReadMoreMaxState:
                          case IncidentEditingState:
                          case IncidentShowingState:
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
                                  child: incidentState.incidentMap.isEmpty
                                      ? const Center(child: Text('暫無異常資訊'))
                                      : SingleChildScrollView(
                                          controller: _scrollController,
                                          scrollDirection: Axis.vertical,
                                          child: DataTable(
                                            showCheckboxColumn: false,
                                            showBottomBorder: true,
                                            columns: const [
                                              DataColumn(label: Text('')),
                                              DataColumn(
                                                label: Text(
                                                  '處理狀態',
                                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                                ),
                                              ),
                                              DataColumn(
                                                  label: SizedBox(
                                                width: 600,
                                                child: Text(
                                                  '異常類型',
                                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                                ),
                                              )),
                                              DataColumn(
                                                label: Text(
                                                  '案場名稱',
                                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  '攝影機',
                                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  '日期',
                                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  '時間',
                                                  // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                                                ),
                                              ),
                                            ],
                                            rows: incidentState.incidentMap.values
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
                                                      DataCell(
                                                        IconButton(
                                                          icon: Icon(
                                                            row.isPinned ? Icons.bookmark : Icons.bookmark_border,
                                                          ),
                                                          onPressed: () => _onIconTap(row),
                                                        ),
                                                      ),
                                                      DataCell(Text(PublicData.stateListName[row.state])),
                                                      DataCell(Text(row.title)),
                                                      DataCell(Text(row.locationName)),
                                                      DataCell(Text(row.cameraName)),
                                                      DataCell(Text(
                                                        DateFormat('yyyy/MM/dd').format(
                                                          DateTime.fromMillisecondsSinceEpoch(row.createDatetime),
                                                        ),
                                                      )),
                                                      DataCell(Text(
                                                        DateFormat('HH:mm').format(
                                                          DateTime.fromMillisecondsSinceEpoch(row.createDatetime),
                                                        ),
                                                      )),
                                                    ],
                                                    onSelectChanged: (isSelected) {
                                                      selectIncidentSubject.add(row);
                                                      print('Item ${row.id} is selected: ${row.isPinned}');
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
              ],
            ),
          );
        });
  }
}
