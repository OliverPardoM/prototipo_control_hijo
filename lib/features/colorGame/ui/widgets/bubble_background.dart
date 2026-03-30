import 'package:flutter/material.dart';

class BubbleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFFEBEE),
      const Color(0xFFE3F2FD),
      const Color(0xFFE8F5E9),
      const Color(0xFFFFFDE7),
    ];
    final positions = [
      Offset(size.width * 0.1, size.height * 0.05),
      Offset(size.width * 0.85, size.height * 0.12),
      Offset(size.width * 0.05, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.8),
    ];
    final radii = [60.0, 80.0, 50.0, 70.0];

    for (int i = 0; i < colors.length; i++) {
      canvas.drawCircle(positions[i], radii[i], Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
