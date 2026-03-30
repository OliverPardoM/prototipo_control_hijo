import 'dart:async';
import 'dart:math';
import 'package:control_parental_child/features/home/domain/provider/game_time_provider.dart';
import 'package:control_parental_child/features/memoryGame/ui/domain/model/card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/card_widget.dart';

// ─────────────────────────────────────────────────────────────
// Difficulty levels
// ─────────────────────────────────────────────────────────────
enum Difficulty { easy, medium, hard }

extension DifficultyExt on Difficulty {
  int get pairs {
    switch (this) {
      case Difficulty.easy:
        return 4;
      case Difficulty.medium:
        return 6;
      case Difficulty.hard:
        return 8;
    }
  }

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Fácil';
      case Difficulty.medium:
        return 'Normal';
      case Difficulty.hard:
        return 'Difícil';
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF6BCB77);
      case Difficulty.medium:
        return const Color(0xFFFFB347);
      case Difficulty.hard:
        return const Color(0xFFFF6B6B);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Memory Game Screen
// ─────────────────────────────────────────────────────────────
class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen>
    with TickerProviderStateMixin {
  static const String _gameId = 'memory_game';
  // ── Game state ─────────────────────────────────────────────
  List<CardModel> _cards = [];
  int? _firstSelectedIndex;
  int? _secondSelectedIndex;
  bool _isChecking = false;
  int _attempts = 0;
  int _matchedPairs = 0;
  Difficulty _difficulty = Difficulty.easy;
  bool _gameWon = false;
  bool _gameStarted = false;

  // ── Preview phase ──────────────────────────────────────────
  bool _isPreviewPhase = false;
  int _previewCountdown = 0;
  Timer? _previewTimer;

  // ── Timer ──────────────────────────────────────────────────
  int _elapsedSeconds = 0;
  Timer? _timer;
  GameTimeProvider? _gameTimeProvider;
  // ── Win animation ──────────────────────────────────────────
  late AnimationController _winController;
  late Animation<double> _winScaleAnim;
  late AnimationController _starController;
  late Animation<double> _starAnim;

  // ── Accent color per session ───────────────────────────────
  final Color _accentColor = const Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    _gameTimeProvider = Provider.of<GameTimeProvider>(context, listen: false);
    // ✅ Registrar inicio del juego
    _winController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _winScaleAnim = CurvedAnimation(
      parent: _winController,
      curve: Curves.elasticOut,
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _starAnim = CurvedAnimation(parent: _starController, curve: Curves.linear);

    _startGame();

    _gameTimeProvider?.startGameSession(_gameId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _previewTimer?.cancel();
    _winController.dispose();
    _starController.dispose();
    if (!_gameWon && _gameTimeProvider != null) {
      _gameTimeProvider!.endGameSession(_gameId);
    }

    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // Preview duration per difficulty
  // ─────────────────────────────────────────────────────────
  int get _previewSeconds {
    switch (_difficulty) {
      case Difficulty.easy:
        return 4;
      case Difficulty.medium:
        return 5;
      case Difficulty.hard:
        return 6;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Game initialization
  // ─────────────────────────────────────────────────────────
  void _startGame() {
    _timer?.cancel();
    _previewTimer?.cancel();

    final allEmojis = List.of(GameEmojis.all)..shuffle(Random());
    final selected = allEmojis.take(_difficulty.pairs).toList();

    final cardList = <CardModel>[];
    int idCounter = 0;
    for (final item in selected) {
      cardList.add(
        CardModel(
          id: idCounter,
          emoji: item['emoji']!,
          label: item['label']!,
          isFaceUp: true, // start face up for preview
        ),
      );
      cardList.add(
        CardModel(
          id: idCounter,
          emoji: item['emoji']!,
          label: item['label']!,
          isFaceUp: true,
        ),
      );
      idCounter++;
    }
    cardList.shuffle(Random());

    setState(() {
      _cards = cardList;
      _firstSelectedIndex = null;
      _secondSelectedIndex = null;
      _isChecking = false;
      _attempts = 0;
      _matchedPairs = 0;
      _gameWon = false;
      _gameStarted = false;
      _elapsedSeconds = 0;
      _isPreviewPhase = true;
      _previewCountdown = _previewSeconds;
    });

    _startPreviewCountdown();
  }

  void _startPreviewCountdown() {
    _previewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_previewCountdown <= 1) {
        timer.cancel();
        _hideAllCards();
      } else {
        setState(() => _previewCountdown--);
      }
    });
  }

  void _hideAllCards() {
    setState(() {
      _isPreviewPhase = false;
      _previewCountdown = 0;
      _cards = _cards.map((c) => c.copyWith(isFaceUp: false)).toList();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  String get _timeString {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─────────────────────────────────────────────────────────
  // Card tap logic
  // ─────────────────────────────────────────────────────────
  void _onCardTap(int index) {
    if (_isPreviewPhase) return;
    if (_isChecking) return;
    if (_cards[index].isMatched) return;
    if (_cards[index].isFaceUp) return;
    if (_firstSelectedIndex == index) return;

    HapticFeedback.selectionClick();

    if (!_gameStarted) {
      _gameStarted = true;
      _startTimer();
    }

    setState(() {
      _cards[index] = _cards[index].copyWith(isFaceUp: true);
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _secondSelectedIndex = index;
      _attempts++;
      _isChecking = true;
      _checkMatch();
    }
  }

  void _checkMatch() {
    final first = _cards[_firstSelectedIndex!];
    final second = _cards[_secondSelectedIndex!];

    if (first.id == second.id) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _cards[_firstSelectedIndex!] = _cards[_firstSelectedIndex!].copyWith(
            isMatched: true,
          );
          _cards[_secondSelectedIndex!] = _cards[_secondSelectedIndex!]
              .copyWith(isMatched: true);
          _matchedPairs++;
          _firstSelectedIndex = null;
          _secondSelectedIndex = null;
          _isChecking = false;
        });
        if (_matchedPairs == _difficulty.pairs) {
          _onGameWon();
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _cards[_firstSelectedIndex!] = _cards[_firstSelectedIndex!].copyWith(
            isFaceUp: false,
          );
          _cards[_secondSelectedIndex!] = _cards[_secondSelectedIndex!]
              .copyWith(isFaceUp: false);
          _firstSelectedIndex = null;
          _secondSelectedIndex = null;
          _isChecking = false;
        });
      });
    }
  }

  void _onGameWon() {
    _timer?.cancel();
    setState(() => _gameWon = true);
    _winController.forward(from: 0);
  }

  // ─────────────────────────────────────────────────────────
  // Stars rating
  // ─────────────────────────────────────────────────────────
  int get _starsEarned {
    final maxAttempts = _difficulty.pairs * 2;
    if (_attempts <= maxAttempts) return 3;
    if (_attempts <= maxAttempts * 1.5) return 2;
    return 1;
  }

  // ─────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // ── Main content ──────────────────────────────────
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                pinned: true,
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                title: Row(
                  children: const [
                    FaIcon(FontAwesomeIcons.brain, size: 20),
                    SizedBox(width: 8),
                    Text('Juego de Memoria'),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _startGame();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Reiniciar',
                  ),
                ],
                expandedHeight: 130,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
                        child: Row(
                          children: [
                            _StatChip(
                              icon: Icons.touch_app_rounded,
                              label: 'Intentos',
                              value: '$_attempts',
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Pares',
                              value: '$_matchedPairs/${_difficulty.pairs}',
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              icon: Icons.timer_outlined,
                              label: 'Tiempo',
                              value: _timeString,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Difficulty selector ─────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: Difficulty.values.map((d) {
                      final isSelected = _difficulty == d;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: GestureDetector(
                              onTap: () {
                                if (_difficulty == d) return;
                                setState(() => _difficulty = d);
                                _startGame();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? d.color
                                      : d.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? d.color
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    d.label,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : d.color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ── Cards grid ─────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => MemoryCardWidget(
                      card: _cards[index],
                      onTap: () => _onCardTap(index),
                      accentColor: _accentColor,
                    ),
                    childCount: _cards.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _crossAxisCount(size.width),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: size.width > 600
                        ? 0.9
                        : (_difficulty == Difficulty.hard ? 0.75 : 0.82),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),

          // ── Win overlay ───────────────────────────────────
          if (_gameWon) _buildWinOverlay(theme),

          // ── Preview overlay banner ────────────────────────
          if (_isPreviewPhase) _buildPreviewBanner(theme),
        ],
      ),
    );
  }

  int _crossAxisCount(double width) {
    if (width > 600) return 4;
    if (_difficulty == Difficulty.hard) return 4;
    return 3;
  }

  // ─────────────────────────────────────────────────────────
  // Preview banner (shown while cards are face-up)
  // ─────────────────────────────────────────────────────────
  Widget _buildPreviewBanner(ThemeData theme) {
    final progress = _previewCountdown / _previewSeconds;

    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.eye,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '¡Memoriza las cartas!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_difficulty.color),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Se ocultarán en $_previewCountdown segundo${_previewCountdown == 1 ? '' : 's'}...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Win overlay
  // ─────────────────────────────────────────────────────────
  Widget _buildWinOverlay(ThemeData theme) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: ScaleTransition(
          scale: _winScaleAnim,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated stars
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
                  '¡Lo lograste!',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: _accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '¡Encontraste todos los pares!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _WinStat(label: 'Intentos', value: '$_attempts'),
                      _WinStat(label: 'Tiempo', value: _timeString),
                      _StarStat(stars: _starsEarned),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
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
                        onPressed: () {
                          _winController.reset();
                          _startGame();
                        },
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('¡Otra vez!'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
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
// Helper widgets
// ─────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _StarStat extends StatelessWidget {
  final int stars;

  const _StarStat({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        stars,
        (index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: FaIcon(FontAwesomeIcons.star, size: 16, color: Colors.amber),
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
            color: const Color(0xFF4D96FF),
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
