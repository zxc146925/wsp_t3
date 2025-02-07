import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/bloc/history_bloc/history_bloc.dart';
import '../../../utils/bloc/login_bloc/login_bloc.dart';
import '../../../utils/bloc/smart_chat_bloc/smart_chat_bloc.dart';
import '../../../utils/entity/history.dart';
import '../../../utils/public/public_data.dart';
import '../anomaly/anomaly_detail.dart';

Drawer smartDrawer(String title, BuildContext context, GlobalKey<ScaffoldState> scaffold) {
  print('title--------$title');
  switch (title) {
    case '異常通知':
      {
        return Drawer(
          backgroundColor: Colors.transparent,
          width: 670,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.8),
              border: Border.all(
                color: const Color.fromRGBO(208, 208, 208, 1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '通知列表',
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Divider(
                    height: 1,
                    color: Colors.black,
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: 15,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ExpansionTile(
                                // tilePadding: EdgeInsets.zero,
                                // childrenPadding: EdgeInsets.zero,
                                leading: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  width: 15,
                                ),
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        // padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: const Text(
                                          '偵測到不符合職安保命條款第一條, 偵測到不符合職安保命條款第一條, 偵測到不符合職安保命條款第一條',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 10, bottom: 10),
                                      child: Text(
                                        '09/10 12:22',
                                      ),
                                    )
                                  ],
                                ),
                                children: [
                                  AnomalyDetail(null),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    case '詢問歷史':
      {
        return Drawer(
          backgroundColor: Colors.transparent,
          width: 670,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.8),
              border: Border.all(
                color: const Color.fromRGBO(208, 208, 208, 1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '歷史列表',
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Divider(
                    height: 1,
                    color: Colors.black,
                  ),
                ),
                Flexible(
                  child: BlocConsumer<HistoryBloc, HistoryState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      switch (state.runtimeType) {
                        case HistoryLoadingState:
                          {
                            return Container(
                              padding: const EdgeInsets.only(top: 10),
                              color: Colors.transparent,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        case HistoryLoadMoreState:
                        case HistoryLoadMoreMaxState:
                        case HistoryShowingState:
                          {
                            return ListView.builder(
                              itemCount: state.historyMap.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if (index > state.historyMap.length - 3 && state.runtimeType != HistoryLoadMoreMaxState) {
                                  print('下拉更多');
                                  context.read<HistoryBloc>().add(
                                        HistoryLoadMoreEvent(skip: state.historyMap.length, size: 20, userId: context.read<LoginBloc>().state.userEntity!.id),
                                      );
                                }
                                HistoryEntity entity = state.historyMap.values.toList()[index];
                                return (state.historyMap.isEmpty)
                                    ? Center(
                                        child: Container(
                                          child: const Text('暫無異常通知'),
                                        ),
                                      )
                                    : MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            context.read<SmartChatBloc>().add(SmartChatOpenHistoryContentEvent(skip: 0, size: 200, chatroomId: entity.id));
                                            scaffold.currentState?.closeEndDrawer();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                            margin: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(5),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(top: 0, right: 0, child: Text(PublicData.formatRecordDate(entity.createDatetime))),
                                                Text(
                                                  entity.title.toString(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                              },
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
              ],
            ),
          ),
        );
      }
    default:
      {
        return const Drawer();
      }
  }
}
