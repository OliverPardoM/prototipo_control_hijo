import 'package:control_parental_child/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum OptionState { idle, correct, wrong }

class OptionItemWidget extends StatefulWidget {
  final String emoji;
  final String label;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionItemWidget({
    super.key,
    required this.emoji,
    required this.label,
    required this.state,
    this.onTap,
  });

  @override
  State<OptionItemWidget> createState() => OptionItemWidgetState();
}

class OptionItemWidgetState extends State<OptionItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(OptionItemWidget old) {
    super.didUpdateWidget(old);
    if (widget.state == OptionState.wrong && old.state == OptionState.idle) {
      _controller.forward(from: 0);
    } else if (widget.state == OptionState.correct &&
        old.state == OptionState.idle) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<CustomColors>()!;
    final isCorrect = widget.state == OptionState.correct;
    final isWrong = widget.state == OptionState.wrong;
    final isAnswered = isCorrect || isWrong;

    Color cardColor;
    Color borderColor;
    Color labelColor;
    if (isCorrect) {
      cardColor = colors.background;
      borderColor = const Color(0xFF43A047);
      labelColor = const Color(0xFF2E7D32);
    } else if (isWrong) {
      cardColor = colors.background;
      borderColor = const Color(0xFFE53935);
      labelColor = const Color(0xFFC62828);
    } else {
      cardColor = colors.background;
      borderColor = const Color(0xFF4D96FF).withOpacity(0.3);
      labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = isWrong ? _shakeAnim.value : 0.0;
        final scale = isCorrect ? _scaleAnim.value : 1.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: GestureDetector(
        onTap: isAnswered
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onTap?.call();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(isAnswered ? 0.3 : 0.1),
                blurRadius: isAnswered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji
              Text(widget.emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 8),
              // Label
              Text(
                widget.label,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              // Result icon
              AnimatedOpacity(
                opacity: isAnswered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isCorrect
                      ? const Color(0xFF43A047)
                      : const Color(0xFFE53935),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
