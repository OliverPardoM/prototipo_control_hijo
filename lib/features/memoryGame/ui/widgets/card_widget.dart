// lib/widgets/card_widget.dart

import 'dart:math';
import 'package:control_parental_child/features/memoryGame/ui/domain/model/card_model.dart';
import 'package:flutter/material.dart';

class MemoryCardWidget extends StatefulWidget {
  final CardModel card;
  final VoidCallback onTap;
  final Color accentColor;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    required this.accentColor,
  });

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFront = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
    _isFront = widget.card.isFaceUp || widget.card.isMatched;
    if (_isFront) _flipController.value = 1.0;
  }

  @override
  void didUpdateWidget(MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldBeUp = widget.card.isFaceUp || widget.card.isMatched;
    if (shouldBeUp && !_isFront) {
      _isFront = true;
      _flipController.forward();
    } else if (!shouldBeUp && _isFront) {
      _isFront = false;
      _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final isFrontVisible = angle <= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFrontVisible
                ? _BackFace(accentColor: widget.accentColor)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _FrontFace(
                      card: widget.card,
                      accentColor: widget.accentColor,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

// ── Back of card (face down) ──────────────────────────────────
class _BackFace extends StatelessWidget {
  final Color accentColor;

  const _BackFace({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative pattern
          ...List.generate(5, (i) {
            return Positioned(
              top: (i * 22.0) - 10,
              left: -10,
              right: -10,
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            );
          }),
          // Center question mark
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Front of card (face up) ───────────────────────────────────
class _FrontFace extends StatelessWidget {
  final CardModel card;
  final Color accentColor;

  const _FrontFace({required this.card, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMatched = card.isMatched;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isMatched
            ? const Color(0xFFE8F5E9)
            : theme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMatched
              ? const Color(0xFF66BB6A)
              : accentColor.withOpacity(0.3),
          width: isMatched ? 3 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isMatched
                ? const Color(0xFF66BB6A).withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: isMatched ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Matched badge
          if (isMatched)
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF66BB6A),
                size: 16,
              ),
            ),
          // Emoji
          Text(card.emoji, style: TextStyle(fontSize: isMatched ? 36 : 40)),
          const SizedBox(height: 4),
          // Label
          Text(
            card.label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isMatched
                  ? const Color(0xFF388E3C)
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
