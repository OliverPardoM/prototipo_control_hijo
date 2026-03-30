// lib/widgets/shape_target_widget.dart

import 'dart:math';
import 'package:control_parental_child/features/ShapeGame/domain/model/shape_model.dart';
import 'package:flutter/material.dart';

class ShapeTargetWidget extends StatefulWidget {
  final ShapeTargetModel target;
  final int placedCount;
  final int totalExpected;
  final void Function(ShapeItemModel item, ShapeType targetType) onItemDropped;

  const ShapeTargetWidget({
    super.key,
    required this.target,
    required this.placedCount,
    required this.totalExpected,
    required this.onItemDropped,
  });

  @override
  State<ShapeTargetWidget> createState() => _ShapeTargetWidgetState();
}

class _ShapeTargetWidgetState extends State<ShapeTargetWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = Tween<double>(
      begin: 1.0,
      end: 1.07,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _bounce() =>
      _bounceCtrl.forward(from: 0).then((_) => _bounceCtrl.reverse());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = widget.target;
    final isFull = widget.placedCount >= widget.totalExpected;

    return ScaleTransition(
      scale: _bounceAnim,
      child: DragTarget<ShapeItemModel>(
        onWillAcceptWithDetails: (d) {
          setState(() => _isHovering = true);
          return true;
        },
        onLeave: (_) => setState(() => _isHovering = false),
        onAcceptWithDetails: (d) {
          setState(() => _isHovering = false);
          _bounce();
          widget.onItemDropped(d.data, target.type);
        },
        builder: (context, candidateData, _) {
          final active = _isHovering && candidateData.isNotEmpty;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 110, minWidth: 90),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isFull
                  ? target.color.withOpacity(0.18)
                  : active
                  ? target.color.withOpacity(0.2)
                  : target.lightColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isFull
                    ? const Color(0xFF43A047)
                    : active
                    ? target.color
                    : target.color.withOpacity(0.4),
                width: active || isFull ? 3 : 2,
                style: isFull ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header label
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isFull ? const Color(0xFF43A047) : target.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isFull)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      if (isFull) const SizedBox(width: 4),
                      Text(
                        target.type.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Shape outline + placed count
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dashed outline hint
                    CustomPaint(
                      size: Size(
                        MediaQuery.of(context).size.width * 0.12,
                        MediaQuery.of(context).size.width * 0.12,
                      ),
                      painter: _OutlinePainter(
                        type: target.type,
                        color: target.color.withOpacity(
                          widget.placedCount > 0 ? 0.2 : 0.45,
                        ),
                        dashed: widget.placedCount == 0,
                      ),
                    ),
                    // Placed count badge
                    if (widget.placedCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isFull
                              ? const Color(0xFF43A047)
                              : target.color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.placedCount}/${widget.totalExpected}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    if (widget.placedCount == 0 && active)
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: target.color,
                        size: 28,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // Hint text
                Text(
                  active
                      ? '¡Suéltalo!'
                      : widget.placedCount == 0
                      ? 'Arrastra aquí'
                      : '',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: target.color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Dashed outline painter ───────────────────────────────────
class _OutlinePainter extends CustomPainter {
  final ShapeType type;
  final Color color;
  final bool dashed;

  const _OutlinePainter({
    required this.type,
    required this.color,
    this.dashed = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    Path path;
    switch (type) {
      case ShapeType.circle:
        path = Path()
          ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      case ShapeType.square:
        path = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(cx, cy),
                width: r * 1.7,
                height: r * 1.7,
              ),
              const Radius.circular(10),
            ),
          );
      case ShapeType.triangle:
        path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.9, cy + r * 0.6)
          ..lineTo(cx - r * 0.9, cy + r * 0.6)
          ..close();
      case ShapeType.star:
        path = _starPath(cx, cy, r, r * 0.45, 5);
      case ShapeType.diamond:
        path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.65, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r * 0.65, cy)
          ..close();
    }

    if (dashed) {
      _drawDashed(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const double dashLen = 6.0;
    const double gapLen = 4.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0.0;
      while (dist < metric.length) {
        final double end = (dist + dashLen)
            .clamp(0.0, metric.length)
            .toDouble();
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  Path _starPath(double cx, double cy, double outerR, double innerR, int pts) {
    final path = Path();
    final step = pi / pts;
    for (int i = 0; i < pts * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = -pi / 2 + i * step;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_OutlinePainter old) =>
      old.type != type || old.color != color || old.dashed != dashed;
}
