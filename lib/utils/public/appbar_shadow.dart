import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'color_theme.dart';

Widget appBarShadow() {
  return Container(
    height: 2, // 這是陰影的高度
    decoration: BoxDecoration(
      color: Colors.transparent, // 背景顏色可以設為透明
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.7), // 陰影顏色
          offset: const Offset(0, 1), // 陰影偏移
          blurRadius: 1.0, // 模糊半徑
          spreadRadius: 0.2, // 擴展半徑
        ),
      ],
    ),
  );
}

dynamic switchPromptBoxType({required int type, required BuildContext context, Widget? widget, String? showToastText}) async {
  // type
  // 0 : 上面提示
  // 1 : 下面提示
  // 2 : 中間提示
  // 3 : 滑動提示
  // 4 : 日期提示
  switch (type) {
    case 0:
      {
        // 顯示上方
        return Fluttertoast.showToast(
          msg: showToastText!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: MyColorTheme.black,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
    case 1:
      {
        // 顯示下方
        return Fluttertoast.showToast(
          msg: showToastText!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
    case 2:
      {
        // 顯示中間
        return Fluttertoast.showToast(
          msg: showToastText!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: MyColorTheme.black,
          textColor: MyColorTheme.white,
          fontSize: 16.0,
        );
      }
    case 3:
      {
        return showModalBottomSheet(
          context: context,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .85),
          useSafeArea: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (builder) {
            return widget!;
          },
        );
      }
    case 4:
      {
        // 未完成待修改
        var date = DateTime.now();
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: date,
          lastDate: date.add(
            //未來30天可選
            const Duration(days: 30),
          ),
        );
        return selectedDate;
      }

    default:
      {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("提示"),
              content: Text("訊息錯誤"),
            );
          },
        );
      }
  }
}
