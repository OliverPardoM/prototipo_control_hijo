// lib/widgets/color_target_widget.dart

import 'package:control_parental_child/features/colorGame/domain/model/color_item_model.dart';
import 'package:flutter/material.dart';

class ColorTargetWidget extends StatefulWidget {
  final ColorBucketModel bucket;
  final List<ColorItemModel> placedItems;
  final void Function(ColorItemModel item, String bucketId) onItemDropped;

  const ColorTargetWidget({
    super.key,
    required this.bucket,
    required this.placedItems,
    required this.onItemDropped,
  });

  @override
  State<ColorTargetWidget> createState() => _ColorTargetWidgetState();
}

class _ColorTargetWidgetState extends State<ColorTargetWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    _bounceController.forward(from: 0).then((_) => _bounceController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final bucket = widget.bucket;
    final placed = widget.placedItems;
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _bounceAnim,
      child: DragTarget<ColorItemModel>(
        onWillAcceptWithDetails: (details) {
          setState(() => _isHovering = true);
          return true;
        },
        onLeave: (_) => setState(() => _isHovering = false),
        onAcceptWithDetails: (details) {
          setState(() => _isHovering = false);
          _triggerBounce();
          widget.onItemDropped(details.data, bucket.id);
        },
        builder: (context, candidateData, rejectedData) {
          final isActive = _isHovering && candidateData.isNotEmpty;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 130),
            decoration: BoxDecoration(
              color: isActive
                  ? bucket.color.withOpacity(0.25)
                  : bucket.lightColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isActive ? bucket.color : bucket.color.withOpacity(0.35),
                width: isActive ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: bucket.color.withOpacity(isActive ? 0.25 : 0.1),
                  blurRadius: isActive ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: bucket.color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      bucket.label,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: _labelColor(bucket.color),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: placed.isEmpty
                        ? Center(
                            child: Text(
                              isActive ? '¡Suéltalo aquí!' : 'Arrastra aquí',
                              style: TextStyle(
                                color: bucket.color.withOpacity(0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: placed
                                  .map((item) => _PlacedChip(item: item))
                                  .toList(),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _labelColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

class _PlacedChip extends StatefulWidget {
  final ColorItemModel item;
  const _PlacedChip({required this.item});

  @override
  State<_PlacedChip> createState() => _PlacedChipState();
}

class _PlacedChipState extends State<_PlacedChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF43A047).withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF43A047).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.item.emoji, style: const TextStyle(fontSize: 22)),
            const Icon(Icons.check_circle, color: Color(0xFF43A047), size: 12),
          ],
        ),
      ),
    );
  }
}
