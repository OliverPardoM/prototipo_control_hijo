import 'package:flutter/material.dart';

class RecommendationCard extends StatelessWidget {
  final int minutesPlayed;

  const RecommendationCard({super.key, required this.minutesPlayed});

  String _getMessage() {
    if (minutesPlayed < 60) {
      return '¡Sigue aprendiendo! 🎮';
    } else if (minutesPlayed >= 60 && minutesPlayed <= 120) {
      return 'Prueba un juego educativo 📚';
    } else {
      return 'Hora de descansar 😊';
    }
  }

  String _getSubMessage() {
    if (minutesPlayed < 60) {
      return 'Has jugado $minutesPlayed minutos hoy. ¡Qué bien!';
    } else if (minutesPlayed >= 60 && minutesPlayed <= 120) {
      return 'Llevas $minutesPlayed minutos jugando. ¿Listo para aprender más?';
    } else {
      return 'Has jugado $minutesPlayed minutos. ¡Es momento de un descanso!';
    }
  }

  IconData _getIcon() {
    if (minutesPlayed < 60) {
      return Icons.emoji_emotions_rounded;
    } else if (minutesPlayed >= 60 && minutesPlayed <= 120) {
      return Icons.school_rounded;
    } else {
      return Icons.nights_stay_rounded;
    }
  }

  Color _getIconBackgroundColor(ThemeData theme) {
    if (minutesPlayed < 60) {
      return Colors.green.withOpacity(0.2);
    } else if (minutesPlayed >= 60 && minutesPlayed <= 120) {
      return Colors.orange.withOpacity(0.2);
    } else {
      return Colors.red.withOpacity(0.2);
    }
  }

  Color _getIconColor(ThemeData theme) {
    if (minutesPlayed < 60) {
      return Colors.green.shade700;
    } else if (minutesPlayed >= 60 && minutesPlayed <= 120) {
      return Colors.orange.shade700;
    } else {
      return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(theme),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(_getIcon(), size: 32, color: _getIconColor(theme)),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMessage(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubMessage(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Small progress indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    '${minutesPlayed}min',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
