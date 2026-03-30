// lib/screens/shape_game_screen.dart

import 'package:control_parental_child/features/ShapeGame/domain/model/shape_model.dart';
import 'package:control_parental_child/features/ShapeGame/ui/widgets/shape_item.dart';
import 'package:control_parental_child/features/ShapeGame/ui/widgets/shape_target.dart';
import 'package:control_parental_child/features/home/domain/provider/game_time_provider.dart';
import 'package:control_parental_child/features/home/domain/services/game_time_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ShapeGameScreen extends StatefulWidget {
  const ShapeGameScreen({super.key});

  @override
  State<ShapeGameScreen> createState() => _ShapeGameScreenState();
}

class _ShapeGameScreenState extends State<ShapeGameScreen>
    with TickerProviderStateMixin {
  static const String _gameId = 'shape_game';
  // ── State ──────────────────────────────────────────────────
  late List<ShapeItemModel> _items;
  final Map<ShapeType, int> _placedCounts = {};
  int _correctCount = 0;
  int _errorCount = 0;
  bool _gameWon = false;
  ShapeDifficulty _difficulty = ShapeDifficulty.easy;

  // Error flash per target
  ShapeType? _flashErrorTarget;
  GameTimeProvider? _gameTimeProvider;

  // Item keys for shake
  final Map<String, GlobalKey<ShapeItemWidgetState>> _itemKeys = {};

  // ── Animations ─────────────────────────────────────────────
  late AnimationController _winCtrl;
  late Animation<double> _winScale;
  late AnimationController _starCtrl;
  late Animation<double> _starAnim;

  static const Color _accent = Color(0xFF4D96FF);

  @override
  void initState() {
    super.initState();
    _gameTimeProvider = Provider.of<GameTimeProvider>(context, listen: false);

    _winCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _winScale = CurvedAnimation(parent: _winCtrl, curve: Curves.elasticOut);
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _starAnim = CurvedAnimation(parent: _starCtrl, curve: Curves.linear);
    _startGame();
    _gameTimeProvider?.startGameSession(_gameId);
  }

  @override
  void dispose() {
    GameTimeService.endGameSession(_gameId);
    _winCtrl.dispose();
    _starCtrl.dispose();
    if (!_gameWon && _gameTimeProvider != null) {
      _gameTimeProvider!.endGameSession(_gameId);
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  void _startGame() {
    final items = ShapeGameData.generateItems(_difficulty);
    final keys = <String, GlobalKey<ShapeItemWidgetState>>{};
    for (final item in items) {
      keys[item.id] = GlobalKey<ShapeItemWidgetState>();
    }
    final counts = <ShapeType, int>{};
    for (final t in _difficulty.types) {
      counts[t] = 0;
    }

    setState(() {
      _items = items;
      _itemKeys
        ..clear()
        ..addAll(keys);
      _placedCounts
        ..clear()
        ..addAll(counts);
      _correctCount = 0;
      _errorCount = 0;
      _gameWon = false;
      _flashErrorTarget = null;
    });
    _winCtrl.reset();
  }

  // ─────────────────────────────────────────────────────────
  void _onItemDropped(ShapeItemModel item, ShapeType targetType) {
    if (item.type == targetType) {
      // Correct
      HapticFeedback.heavyImpact();
      setState(() {
        final idx = _items.indexWhere((i) => i.id == item.id);
        if (idx != -1) _items[idx] = item.copyWith(isPlaced: true);
        _placedCounts[targetType] = (_placedCounts[targetType] ?? 0) + 1;
        _correctCount++;
      });

      final totalItems = _items.length;
      if (_correctCount == totalItems) {
        Future.delayed(const Duration(milliseconds: 500), _onGameWon);
      }
    } else {
      //  Wrong
      HapticFeedback.mediumImpact();
      _itemKeys[item.id]?.currentState?.triggerShake();

      setState(() => _flashErrorTarget = targetType);
      Future.delayed(
        const Duration(milliseconds: 600),
        () => mounted ? setState(() => _flashErrorTarget = null) : null,
      );

      setState(() => _errorCount++);
    }
  }

  void _onGameWon() {
    GameTimeService.endGameSession(_gameId);
    setState(() => _gameWon = true);
    _winCtrl.forward(from: 0);
  }

  // ─────────────────────────────────────────────────────────
  int get _starsEarned {
    final ratio = _correctCount / max(1, _correctCount + _errorCount);
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.7) return 2;
    return 1;
  }

  int _expectedPerType(ShapeType t) => _items.where((i) => i.type == t).length;

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background
          Positioned.fill(child: _Background()),

          Column(
            children: [
              _buildAppBar(theme),
              _buildStats(theme),
              _buildDifficultySelector(theme),

              const SizedBox(height: 12),

              // ── Targets (top) ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: _buildTargets(size),
              ),

              // ── Divider ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Arrastra las figuras',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
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

              // ── Items (bottom) ─────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildItems(),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),

          if (_gameWon) _buildWinOverlay(theme),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  Widget _buildAppBar(ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF4D96FF),

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
              const FaIcon(
                FontAwesomeIcons.shapes,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Juego de Formas',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: _startGame,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Reiniciar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: ShapeDifficulty.values.map((d) {
          final sel = _difficulty == d;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  if (_difficulty == d) return;
                  setState(() => _difficulty = d);
                  _startGame();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? d.color : d.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel ? d.color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      d.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: sel ? Colors.white : d.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStats(ThemeData theme) {
    final remaining = _items.where((i) => !i.isPlaced).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          _StatPill(
            icon: Icons.check_circle_rounded,
            label: 'Correctas',
            value: '$_correctCount',
            color: _accent,
          ),
          const SizedBox(width: 8),
          _StatPill(
            icon: Icons.cancel_rounded,
            label: 'Errores',
            value: '$_errorCount',
            color: const Color(0xFFFF6B6B),
          ),
          const SizedBox(width: 8),
          _StatPill(
            icon: Icons.hourglass_bottom_rounded,
            label: 'Faltan',
            value: '$remaining',
            color: const Color(0xFF4D96FF),
          ),
        ],
      ),
    );
  }

  Widget _buildTargets(Size size) {
    final types = _difficulty.types;

    return SizedBox(
      height: 160, // altura fija para que ListView sepa el espacio
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final target = ShapeGameData.targets[type]!;
          final hasError = _flashErrorTarget == type;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: SizedBox(
              width: 140, // ancho fijo para cada target
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: hasError
                    ? BoxDecoration(borderRadius: BorderRadius.circular(24))
                    : null,
                child: Material(
                  // importante para Draggable/semantics
                  color: Colors.transparent,
                  child: ShapeTargetWidget(
                    target: target,
                    placedCount: _placedCounts[type] ?? 0,
                    totalExpected: _expectedPerType(type),
                    onItemDropped: _onItemDropped,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItems() {
    final pending = _items.where((i) => !i.isPlaced).toList();

    if (pending.isEmpty) {
      return Center(
        child: Text(
          '¡Todas colocadas!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: _accent,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Center(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: _items
            .map(
              (item) => SizedBox(
                width: 80,
                height: 90,
                child: ShapeItemWidget(key: _itemKeys[item.id], shape: item),
              ),
            )
            .toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  Widget _buildWinOverlay(ThemeData theme) {
    final stars = _starsEarned;
    final accuracy = _correctCount + _errorCount > 0
        ? (_correctCount / (_correctCount + _errorCount) * 100).round()
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
                RotationTransition(
                  turns: _starAnim,
                  child: const FaIcon(
                    FontAwesomeIcons.star,
                    size: 56,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  stars == 3 ? '¡Perfecto!' : '¡Muy bien!',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: _accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Clasificaste todas las figuras',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                      _WinStat(label: 'Figuras', value: '$_correctCount'),
                      _WinStat(label: 'Errores', value: '$_errorCount'),
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
                        onPressed: _startGame,
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
// Background
// ─────────────────────────────────────────────────────────────
class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BgPainter(), child: const SizedBox.expand());
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final blobs = [
      (Offset(s.width * 0.08, s.height * 0.05), 65.0, const Color(0xFFE8F5E9)),
      (Offset(s.width * 0.9, s.height * 0.12), 80.0, const Color(0xFFE3F2FD)),
      (Offset(s.width * 0.05, s.height * 0.72), 55.0, const Color(0xFFFFF3E0)),
      (Offset(s.width * 0.92, s.height * 0.82), 70.0, const Color(0xFFF3E5F5)),
    ];
    for (final (pos, r, color) in blobs) {
      canvas.drawCircle(pos, r, Paint()..color = color);
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
            color: const Color(0xFF6BCB77),
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

// needed for accuracy calc
int max(int a, int b) => a > b ? a : b;
