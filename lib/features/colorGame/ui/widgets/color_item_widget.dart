import 'package:control_parental_child/features/colorGame/domain/model/color_item_model.dart';
import 'package:flutter/material.dart';

class ColorItemWidget extends StatefulWidget {
  final ColorItemModel item;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const ColorItemWidget({
    super.key,
    required this.item,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  State<ColorItemWidget> createState() => ColorItemWidgetState();
}

class ColorItemWidgetState extends State<ColorItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnim =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void triggerShake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.isPlaced) {
      return _buildCard(opacity: 0.0);
    }

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Draggable<ColorItemModel>(
        data: widget.item,
        onDragStarted: widget.onDragStarted,
        onDragEnd: (_) => widget.onDragEnd?.call(),
        feedback: _buildCard(scale: 1.1, shadow: true),
        childWhenDragging: _buildCard(opacity: 0.3),
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard({
    double scale = 1.0,
    double opacity = 1.0,
    bool shadow = false,
  }) {
    final color = widget.item.color;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5), width: 2.5),
            boxShadow: shadow
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.item.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 2),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
