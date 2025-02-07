import 'package:flutter/material.dart';
import 'dart:math';

//驗證碼
class CustomVertificationWidget extends StatefulWidget {
  final String code;
  final int dotCount;
  final double width;
  final double height;
  final Color? backgroundColor;
  const CustomVertificationWidget({
    super.key,
    required this.code,
    this.backgroundColor,
    // 設定背景圈圈數
    this.dotCount = 0,
    this.width = 150,
    this.height = 40,
  });

  @override
  State<CustomVertificationWidget> createState() => _CustomVertificationWidgetState();
}

class _CustomVertificationWidgetState extends State<CustomVertificationWidget> {
  Map getRandomDate() {
    List list = widget.code.split("");
    double x = 0.0;
    double maxFontSize = 35.0;

    List mList = [];
    for (String item in list) {
      // Color color = Color.fromARGB(
      //   255,
      //   Random().nextInt(255),
      //   Random().nextInt(255),
      //   Random().nextInt(255),
      // );
      Color color = Colors.black;
      int fontWeight = Random().nextInt(9);
      TextSpan span = TextSpan(
        text: item,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.values[fontWeight],
          fontSize: maxFontSize - Random().nextInt(10),
        ),
      );
      TextPainter painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      double y = Random().nextInt(widget.height.toInt()).toDouble() - painter.height;
      if (y < 0) {
        y = 0;
      }
      Map strMap = {
        "painter": painter,
        "x": x,
        "y": y,
      };
      mList.add(strMap);
      x += painter.width + 3;
    }
    double offsetX = (widget.width - x) / 2;
    List dotData = [];
    for (var i = 0; i < widget.dotCount; i++) {
      int r = Random().nextInt(255);
      int g = Random().nextInt(255);
      int b = Random().nextInt(255);
      double x = Random().nextInt(widget.width.toInt() - 5).toDouble();
      double y = Random().nextInt(widget.height.toInt() - 5).toDouble();
      double dotWidth = Random().nextInt(6).toDouble();
      Color color = Color.fromARGB(255, r, g, b);
      Map dot = {
        "x": x,
        "y": y,
        "dotWidth": dotWidth,
        "color": color,
      };
      dotData.add(dot);
    }
    Map checkCodeDrawData = {
      "painterData": mList,
      "offsetX": offsetX,
      "dotData": dotData,
    };
    return checkCodeDrawData;
  }

  Size getTextSize(String text, TextStyle style) {
    final TextPainter textPainer = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: double.infinity,
      );
    return textPainer.size;
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = 0.0;
    Map drawData = getRandomDate();
    maxWidth = getTextSize(
      '8' * widget.code.length,
      TextStyle(fontWeight: FontWeight.values[8], fontSize: 25),
    ).width;
    return Container(
      color: widget.backgroundColor,
      width: maxWidth > widget.width ? maxWidth : widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: CustomVertificationPainter(
          drawData: drawData,
        ),
      ),
    );
  }
}

class CustomVertificationPainter extends CustomPainter {
  final Map drawData;
  CustomVertificationPainter({required this.drawData});

  final Paint _paint = Paint()
    ..color = Colors.grey
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 1.0
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    List mList = drawData['painterData'];

    double offsetX = drawData['offsetX'];
    canvas.translate(offsetX, 0);

    for (var item in mList) {
      TextPainter painter = item['painter'];
      double x = item['x'];
      double y = item['y'];
      painter.paint(
        canvas,
        Offset(x, y),
      );
    }

    canvas.translate(-offsetX, 0);
    List dotData = drawData['dotData'];
    for (var item in dotData) {
      double x = item['x'];
      double y = item['y'];
      double dotWidth = item['dotWidth'];
      Color color = item['color'];
      _paint.color = color;
      canvas.drawOval(Rect.fromLTWH(x, y, dotWidth, dotWidth), _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
