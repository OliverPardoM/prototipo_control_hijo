// lib/widgets/shape_item_widget.dart

import 'dart:math';
import 'package:control_parental_child/features/ShapeGame/domain/model/shape_model.dart';
import 'package:flutter/material.dart';

class ShapeItemWidget extends StatefulWidget {
  final ShapeItemModel shape;
  final bool isDragging;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const ShapeItemWidget({
    super.key,
    required this.shape,
    this.isDragging = false,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  State<ShapeItemWidget> createState() => ShapeItemWidgetState();
}

class ShapeItemWidgetState extends State<ShapeItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -14.0, end: 14.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 14.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void triggerShake() => _shakeCtrl.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    if (widget.shape.isPlaced) {
      // Ghost to preserve layout
      return const SizedBox(width: 80, height: 80);
    }

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Draggable<ShapeItemModel>(
        data: widget.shape,
        onDragStarted: widget.onDragStarted,
        onDragEnd: (_) => widget.onDragEnd?.call(),
        feedback: Material(
          color: Colors.transparent,
          child: _ShapeCanvas(
            shape: widget.shape,
            size: 88,
            shadow: true,
            scale: 1.12,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.25,
          child: _ShapeCanvas(shape: widget.shape, size: 80),
        ),
        child: _ShapeCanvas(shape: widget.shape, size: 80),
      ),
    );
  }
}

// ─── Actual shape painter ─────────────────────────────────────
class _ShapeCanvas extends StatelessWidget {
  final ShapeItemModel shape;
  final double size;
  final bool shadow;
  final double scale;

  const _ShapeCanvas({
    required this.shape,
    required this.size,
    this.shadow = false,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: CustomPaint(
        size: Size(size, size),
        painter: _ShapePainter(
          type: shape.type,
          color: shape.color,
          shadow: shadow,
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final ShapeType type;
  final Color color;
  final bool shadow;

  const _ShapePainter({
    required this.type,
    required this.color,
    this.shadow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    switch (type) {
      case ShapeType.circle:
        if (shadow) canvas.drawCircle(Offset(cx, cy + 6), r, shadowPaint);
        canvas.drawCircle(Offset(cx, cy), r, paint);

      case ShapeType.square:
        final rect = Rect.fromCenter(
          center: Offset(cx, cy),
          width: r * 1.7,
          height: r * 1.7,
        );
        final rr = RRect.fromRectAndRadius(rect, const Radius.circular(12));
        if (shadow) {
          final sRect = rect.translate(0, 6);
          canvas.drawRRect(
            RRect.fromRectAndRadius(sRect, const Radius.circular(12)),
            shadowPaint,
          );
        }
        canvas.drawRRect(rr, paint);

      case ShapeType.triangle:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.9, cy + r * 0.6)
          ..lineTo(cx - r * 0.9, cy + r * 0.6)
          ..close();
        if (shadow) {
          final sp = Path()
            ..moveTo(cx, cy - r + 6)
            ..lineTo(cx + r * 0.9, cy + r * 0.6 + 6)
            ..lineTo(cx - r * 0.9, cy + r * 0.6 + 6)
            ..close();
          canvas.drawPath(sp, shadowPaint);
        }
        canvas.drawPath(path, paint);

      case ShapeType.star:
        final path = _starPath(cx, cy, r, r * 0.45, 5);
        if (shadow) {
          final sp = _starPath(cx, cy + 6, r, r * 0.45, 5);
          canvas.drawPath(sp, shadowPaint);
        }
        canvas.drawPath(path, paint);

      case ShapeType.diamond:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.65, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r * 0.65, cy)
          ..close();
        if (shadow) {
          final sp = Path()
            ..moveTo(cx, cy - r + 6)
            ..lineTo(cx + r * 0.65, cy + 6)
            ..lineTo(cx, cy + r + 6)
            ..lineTo(cx - r * 0.65, cy + 6)
            ..close();
          canvas.drawPath(sp, shadowPaint);
        }
        canvas.drawPath(path, paint);
    }
  }

  Path _starPath(
    double cx,
    double cy,
    double outerR,
    double innerR,
    int points,
  ) {
    final path = Path();
    final step = pi / points;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = -pi / 2 + i * step;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_ShapePainter old) =>
      old.type != type || old.color != color;
}
