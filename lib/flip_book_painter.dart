import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FlipBookPainter extends CustomPainter {
  final List<Offset> offsets;

  FlipBookPainter(this.offsets) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..isAntiAlias = true
      ..strokeWidth = 6.0;

    for (var i = 0; i < offsets.length; i++) {
      if (shouldDrawLine(i)) {
        canvas.drawLine(offsets[i], offsets[i + 1], paint);
      } else if (shouldDrawPoint(i)) {
        canvas.drawPoints(PointMode.points, [offsets[i]], paint);
      }
    }
  }

  bool shouldDrawPoint(int i) => offsets[i] != null && offsets.length > i + 1 && offsets[i + 1] == null;

  bool shouldDrawLine(int i) => offsets[i] != null && offsets.length > i + 1 && offsets[i + 1] != null;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
