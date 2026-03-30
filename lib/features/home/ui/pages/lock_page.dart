import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_parental_child/core/theme/app_theme.dart';
import '../../domain/provider/game_time_provider.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  static const String _parentPin = '1234';
  final _pinController = TextEditingController();

  bool _showPin = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _unlock(BuildContext context) {
    if (_pinController.text == _parentPin) {
      _pinController.clear();
      setState(() {
        _showPin = false;
        _error = null;
      });

      context.read<GameTimeProvider>().parentUnlock();
    } else {
      setState(() => _error = 'PIN incorrecto');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<CustomColors>()!;

    return Scaffold(
      body: Stack(
        children: [
          _BackgroundGradient(),

          Container(color: colors.background.withOpacity(0.6)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      ),
                      child: Icon(
                        Icons.nightlight_round,
                        size: 100,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Hora de descansar',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _GlassCard(
                      child: Column(
                        children: [
                          Text(
                            'Jugaste bastante hoy 🎮\n'
                            'Es momento de descansar o hacer algo divertido.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const _ActivitySuggestions(),

                    const SizedBox(height: 40),

                    _ParentButton(
                      onTap: () {
                        setState(() {
                          _showPin = true;
                          _error = null;
                          _pinController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_showPin)
            _PinDialog(
              controller: _pinController,
              error: _error,
              onCancel: () => setState(() => _showPin = false),
              onConfirm: () => _unlock(context),
            ),
        ],
      ),
    );
  }
}

class _BackgroundGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;
    return Container(decoration: BoxDecoration(color: colors.background));
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          color: colors.colorScheme.surface,
          child: child,
        ),
      ),
    );
  }
}

class _ParentButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ParentButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: theme.colorScheme.primary,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Acceso padres',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySuggestions extends StatelessWidget {
  const _ActivitySuggestions();

  static const activities = [
    (Icons.brush, 'Dibujar'),
    (Icons.menu_book, 'Leer'),
    (Icons.directions_run, 'Jugar'),
    (Icons.extension, 'Puzzle'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: activities.map((a) {
        return Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: theme.colorScheme.surface.withOpacity(0.6),
              ),
              child: Icon(a.$1, color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: 6),
            Text(a.$2),
          ],
        );
      }).toList(),
    );
  }
}

class _PinDialog extends StatefulWidget {
  final TextEditingController controller;
  final String? error;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _PinDialog({
    required this.controller,
    required this.error,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scale = Tween(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fade = Tween(begin: 0.0, end: 1.0).animate(_animController);

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _isValid => widget.controller.text.length == 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onCancel,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: _GlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.lock,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Acceso de padres',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'PIN de prueba: 1234',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'Ingresa tu PIN',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: widget.controller,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          letterSpacing: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••',
                          counterText: '',
                          errorText: widget.error,
                          filled: true,
                          fillColor: theme.colorScheme.surface.withOpacity(0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) =>
                            _isValid ? widget.onConfirm() : null,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onCancel,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: theme.colorScheme.primary,
                              ),
                              child: ElevatedButton(
                                onPressed: _isValid ? widget.onConfirm : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
