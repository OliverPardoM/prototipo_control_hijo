// lib/widgets/sound_button_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SoundButtonState { idle, playing, done }

class SoundButtonWidget extends StatefulWidget {
  final SoundButtonState state;
  final String hint;
  final VoidCallback onTap;

  const SoundButtonWidget({
    super.key,
    required this.state,
    required this.hint,
    required this.onTap,
  });

  @override
  State<SoundButtonWidget> createState() => _SoundButtonWidgetState();
}

class _SoundButtonWidgetState extends State<SoundButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(SoundButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == SoundButtonState.playing) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = widget.state == SoundButtonState.playing;

    return Column(
      children: [
        // Hint text
        Text(
          widget.hint,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.75),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Pulse rings + button
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                if (isPlaying)
                  Transform.scale(
                    scale: _pulseAnim.value * 1.35,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4D96FF).withOpacity(0.12),
                      ),
                    ),
                  ),
                // Middle ring
                if (isPlaying)
                  Transform.scale(
                    scale: _pulseAnim.value * 1.15,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4D96FF).withOpacity(0.18),
                      ),
                    ),
                  ),
                child!,
              ],
            );
          },
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isPlaying
                      ? [const Color(0xFF1565C0), const Color(0xFF4D96FF)]
                      : [const Color(0xFF4D96FF), const Color(0xFF0288D1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF4D96FF,
                    ).withOpacity(isPlaying ? 0.5 : 0.3),
                    blurRadius: isPlaying ? 24 : 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                isPlaying
                    ? Icons.volume_up_rounded
                    : Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),
        AnimatedOpacity(
          opacity: isPlaying ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: Text(
            isPlaying ? 'Escuchando...' : 'Toca para escuchar 🔊',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF4D96FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
