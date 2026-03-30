import 'package:flutter/material.dart';

class LinkErrorPage extends StatelessWidget {
  const LinkErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorMessage =
        ModalRoute.of(context)?.settings.arguments as String? ??
        'Código inválido. Verifica e intenta de nuevo.';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.error.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.link_off_rounded,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Error al vincular',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    '/scan-link-code',
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    'Intentar de nuevo',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.popUntil(
                  context,
                  ModalRoute.withName('/scan-link-code'),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
