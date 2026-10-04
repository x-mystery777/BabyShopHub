import 'dart:math' as math;

import 'package:flutter/material.dart';

class CloudPainter extends CustomPainter {
  const CloudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawCloud(
      canvas,
      Rect.fromLTWH(-18, -38, 140, 128),
      const Color(0xFFFFF8EA),
    );
    _drawCloud(
      canvas,
      Rect.fromLTWH(-28, size.height - 96, 140, 116),
      const Color(0xFFFFF8EA),
    );
    _drawCloud(
      canvas,
      Rect.fromLTWH(size.width - 132, size.height - 112, 156, 132),
      const Color(0xFFFFE5E4),
      flipHorizontal: true,
    );
  }

  @override
  bool shouldRepaint(covariant CloudPainter oldDelegate) => false;
}

void _drawCloud(
  Canvas canvas,
  Rect bounds,
  Color color, {
  bool flipHorizontal = false,
}) {
  final width = bounds.width;
  final height = bounds.height;
  final base = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-width * 0.08, height * 0.43, width * 1.16, height * 0.7),
        Radius.circular(height * 0.28),
      ),
    );
  final puffs = <Rect>[
    Rect.fromLTWH(-width * 0.13, height * 0.28, width * 0.44, height * 0.62),
    Rect.fromLTWH(width * 0.08, height * 0.02, width * 0.55, height * 0.75),
    Rect.fromLTWH(width * 0.39, height * 0.14, width * 0.48, height * 0.67),
    Rect.fromLTWH(width * 0.67, height * 0.32, width * 0.43, height * 0.58),
  ];
  var cloud = base;
  for (final puff in puffs) {
    final oval = Path()..addOval(puff);
    cloud = Path.combine(PathOperation.union, cloud, oval);
  }

  canvas.save();
  canvas.translate(bounds.left + (flipHorizontal ? width : 0), bounds.top);
  canvas.scale(flipHorizontal ? -1 : 1, 1);
  canvas.drawPath(cloud, Paint()..color = color);
  canvas.restore();
}
