import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wsp_t3/screen/tab_bar_screen/construction/construction_detail.dart';

import '../../../utils/entity/location.dart';
import '../../../utils/public/color_theme.dart';
import 'construction_incident_list.dart';
import 'construction_video_log.dart';

class ConstructionDrawer extends StatefulWidget {
  LocationEntity? locationEntity;
  ConstructionDrawer({
    super.key,
    this.locationEntity,
  });

  @override
  State<ConstructionDrawer> createState() => _ConstructionDrawerState();
}

class _ConstructionDrawerState extends State<ConstructionDrawer> {
  BehaviorSubject<int> selectIndexStream = BehaviorSubject<int>.seeded(0);

  // 當按鈕被點擊時，更新選中的索引
  void _onButtonPressed(int index) {
    selectIndexStream.add(index);
  }

  Widget _buildButton(int index, String text) {
    return StreamBuilder<int>(
        stream: selectIndexStream,
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
  Widget build(BuildContext context) {
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
          color: Colors.white,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildButton(0, '案場資訊'),
                    _buildButton(1, '影像紀錄'),
                    _buildButton(2, '異常事件'),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              height: 1,
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<int>(
                stream: selectIndexStream,
                builder: (context, snapshot) {
                  return Expanded(
                    child: IndexedStack(
                      sizing: StackFit.expand,
                      index: snapshot.data ?? 0,
                      children: [
                        ConstructionDetail(locationEntity: widget.locationEntity),
                        ConstructionVideoLog(locationEntity: widget.locationEntity!),
                        ConstructionIncidentList(locationEntity: widget.locationEntity!),
                      ],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
