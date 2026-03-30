import 'package:control_parental_child/features/colorGame/domain/model/color_item_model.dart';
import 'package:control_parental_child/features/home/domain/provider/game_time_provider.dart';
import 'package:control_parental_child/features/home/domain/services/game_time_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../widgets/color_item_widget.dart';
import '../widgets/color_target_widget.dart';

class ColorGameScreen extends StatefulWidget {
  const ColorGameScreen({super.key});

  @override
  State<ColorGameScreen> createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends State<ColorGameScreen>
    with TickerProviderStateMixin {
  static const String _gameId = 'color_game';

  late List<ColorItemModel> _items;
  final Map<String, List<ColorItemModel>> _bucketContents = {
    'red': [],
    'blue': [],
    'green': [],
    'yellow': [],
  };
  int _correctCount = 0;
  int _totalAttempts = 0;
  bool _gameWon = false;

  final Map<String, GlobalKey<ColorItemWidgetState>> _itemKeys = {};

  late AnimationController _winController;
  late Animation<double> _winScale;
  late AnimationController _confettiController;

  GameTimeProvider? _gameTimeProvider;

  String? _flashErrorBucket;

  static const Color _accent = Color(0xFFFFB347);

  @override
  void initState() {
    super.initState();
    _gameTimeProvider = Provider.of<GameTimeProvider>(context, listen: false);

    _winController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _winScale = CurvedAnimation(
      parent: _winController,
      curve: Curves.elasticOut,
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _resetGame();

    _gameTimeProvider?.startGameSession(_gameId);
  }

  @override
  void dispose() {
    GameTimeService.endGameSession(_gameId);
    _winController.dispose();
    _confettiController.dispose();
    super.dispose();
    if (!_gameWon && _gameTimeProvider != null) {
      _gameTimeProvider!.endGameSession(_gameId);
    }
  }

  void _resetGame() {
    final items = ColorGameData.generateItems();
    final keys = <String, GlobalKey<ColorItemWidgetState>>{};
    for (final item in items) {
      keys[item.id] = GlobalKey<ColorItemWidgetState>();
    }

    setState(() {
      _items = items;
      _itemKeys
        ..clear()
        ..addAll(keys);
      _bucketContents..forEach((k, _) => _bucketContents[k] = []);
      _correctCount = 0;
      _totalAttempts = 0;
      _gameWon = false;
      _flashErrorBucket = null;
    });
    _winController.reset();
    _confettiController.reset();
  }

  void _onItemDropped(ColorItemModel item, String bucketId) {
    _totalAttempts++;

    if (item.targetId == bucketId) {
      HapticFeedback.heavyImpact();
      setState(() {
        final idx = _items.indexWhere((i) => i.id == item.id);
        if (idx != -1) _items[idx] = item.copyWith(isPlaced: true);
        _bucketContents[bucketId]!.add(item);
        _correctCount++;
      });

      if (_correctCount == _items.length) {
        Future.delayed(const Duration(milliseconds: 400), _onGameWon);
      }
    } else {
      HapticFeedback.mediumImpact();
      _itemKeys[item.id]?.currentState?.triggerShake();

      setState(() => _flashErrorBucket = bucketId);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _flashErrorBucket = null);
      });
    }
  }

  void _onGameWon() {
    GameTimeService.endGameSession(_gameId);
    setState(() => _gameWon = true);
    _winController.forward(from: 0);
    _confettiController.forward(from: 0);
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BubblePainter())),

          Column(
            children: [
              // ── App bar ──────────────────────────────────
              _buildAppBar(theme),

              // ── Stats row ────────────────────────────────
              _buildStatsRow(theme),

              const SizedBox(height: 8),

              // ── Buckets grid ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.count(
                  crossAxisCount: size.width > 500 ? 4 : 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: size.width > 500 ? 0.9 : 1.0,
                  children: ColorGameData.buckets.map((bucket) {
                    final placed = _bucketContents[bucket.id] ?? [];
                    final hasError = _flashErrorBucket == bucket.id;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: hasError
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            )
                          : null,
                      child: ColorTargetWidget(
                        bucket: bucket,
                        placedItems: placed,
                        onItemDropped: _onItemDropped,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // ── Divider label ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.hand,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.45,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Arrastra los objetos',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.45,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Draggable items ───────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildItemsArea(theme),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),

          // ── Win overlay ──────────────────────────────────
          if (_gameWon) _buildWinOverlay(theme),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  Widget _buildAppBar(ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFB347),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 14),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const FaIcon(
                FontAwesomeIcons.palette,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Juego de Colores',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: _resetGame,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Reiniciar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    final remaining = _items.where((i) => !i.isPlaced).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _StatPill(
            icon: Icons.check_circle_rounded,
            label: 'Correctos',
            value: '$_correctCount',
            color: const Color(0xFF43A047),
          ),
          const SizedBox(width: 8),
          _StatPill(
            icon: Icons.touch_app_rounded,
            label: 'Intentos',
            value: '$_totalAttempts',
            color: _accent,
          ),
          const SizedBox(width: 8),
          _StatPill(
            icon: Icons.inventory_2_rounded,
            label: 'Faltan',
            value: '$remaining',
            color: const Color(0xFF1E88E5),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsArea(ThemeData theme) {
    final pending = _items.where((i) => !i.isPlaced).toList();

    if (pending.isEmpty) {
      return Center(
        child: Text(
          '¡Todos colocados!',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: const Color(0xFF43A047),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];
        return ColorItemWidget(key: _itemKeys[item.id], item: item);
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  Widget _buildWinOverlay(ThemeData theme) {
    final accuracy = _totalAttempts > 0
        ? ((_correctCount / _totalAttempts) * 100).round()
        : 100;

    return Container(
      color: Colors.black54,
      child: Center(
        child: ScaleTransition(
          scale: _winScale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated trophy
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: const Text('🏆', style: TextStyle(fontSize: 64)),
                ),
                const SizedBox(height: 12),
                Text(
                  '¡Muy bien!',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: _accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Clasificaste todos los colores correctamente ',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _WinStat(label: 'Correctos', value: '$_correctCount'),
                      _WinStat(label: 'Intentos', value: '$_totalAttempts'),
                      _WinStat(label: 'Precisión', value: '$accuracy%'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Inicio'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _resetGame,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('¡Otra vez!'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Background painter
// ─────────────────────────────────────────────────────────────
class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFFEBEE),
      const Color(0xFFE3F2FD),
      const Color(0xFFE8F5E9),
      const Color(0xFFFFFDE7),
    ];
    final positions = [
      Offset(size.width * 0.1, size.height * 0.05),
      Offset(size.width * 0.85, size.height * 0.12),
      Offset(size.width * 0.05, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.8),
    ];
    final radii = [60.0, 80.0, 50.0, 70.0];

    for (int i = 0; i < colors.length; i++) {
      canvas.drawCircle(positions[i], radii[i], Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WinStat extends StatelessWidget {
  final String label;
  final String value;
  const _WinStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFFB347),
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
