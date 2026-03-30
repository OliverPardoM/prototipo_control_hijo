import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:control_parental_child/features/home/domain/provider/game_time_provider.dart';
import 'package:control_parental_child/features/home/domain/services/game_time_service.dart';
import 'package:control_parental_child/features/soundGame/domain/model/sound_question_model.dart';
import 'package:control_parental_child/features/soundGame/ui/widgets/sound_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/option_item_widget.dart';

class SoundGameScreen extends StatefulWidget {
  const SoundGameScreen({super.key});

  @override
  State<SoundGameScreen> createState() => _SoundGameScreenState();
}

class _SoundGameScreenState extends State<SoundGameScreen>
    with TickerProviderStateMixin {
  static const String _gameId = 'sound_game';
  // ── Audio ──────────────────────────────────────────────────
  final AudioPlayer _sfxPlayer = AudioPlayer(); // correct / wrong
  final AudioPlayer _mainPlayer = AudioPlayer(); // animal sounds

  // ── Game state ─────────────────────────────────────────────
  static const int _totalRounds = 5;
  late List<SoundQuestion> _questionPool;
  int _currentRound = 0;
  int _correctCount = 0;
  bool _answered = false;
  bool _gameOver = false;
  String? _selectedId;
  SoundButtonState _soundState = SoundButtonState.idle;

  // Shuffled options for current question
  List<SoundOption> _shuffledOptions = [];
  GameTimeProvider? _gameTimeProvider;

  // ── Animations ─────────────────────────────────────────────
  late AnimationController _winController;
  late Animation<double> _winScale;
  late AnimationController _progressController;

  // ── Round transition ───────────────────────────────────────
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  static const Color _accent = Color(0xFF6BCB77);

  // ─────────────────────────────────────────────────────────
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

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _mainPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _soundState = state == PlayerState.playing
            ? SoundButtonState.playing
            : SoundButtonState.idle;
      });
    });

    _startGame();
    _gameTimeProvider?.startGameSession(_gameId);
  }

  @override
  void dispose() {
    GameTimeService.endGameSession(_gameId);
    _mainPlayer.dispose();
    _sfxPlayer.dispose();
    _winController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    if (_gameTimeProvider != null) {
      _gameTimeProvider!.endGameSession(_gameId);
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  void _startGame() {
    final shuffled = List.of(SoundGameData.all)..shuffle(Random());
    _questionPool = shuffled.take(_totalRounds).toList();
    setState(() {
      _currentRound = 0;
      _correctCount = 0;
      _answered = false;
      _gameOver = false;
      _selectedId = null;
    });
    _winController.reset();
    _loadRound();
  }

  void _loadRound() {
    final q = _questionPool[_currentRound];
    final opts = List.of(q.options)..shuffle(Random());
    setState(() {
      _shuffledOptions = opts;
      _answered = false;
      _selectedId = null;
      _soundState = SoundButtonState.idle;
    });
    if (!_fadeController.isAnimating) {
      _fadeController.forward(from: 0);
    }
    // Auto-play sound after a short delay
    Future.delayed(const Duration(milliseconds: 500), _playSound);
  }

  // ─────────────────────────────────────────────────────────
  Future<void> _playSound() async {
    if (_answered) return;
    try {
      await _mainPlayer.stop();
      await _mainPlayer.play(
        AssetSource(
          _questionPool[_currentRound].audioAsset.replaceFirst('assets/', ''),
        ),
      );
    } catch (e) {
      // Audio asset not found — still allow game to be played visually
      debugPrint('Audio error: $e');
    }
  }

  Future<void> _playSfx(String asset) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(asset.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('SFX error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  void _onOptionTap(String optionId) {
    if (_answered) return;
    final correct = _questionPool[_currentRound].correctId;
    final isCorrect = optionId == correct;

    setState(() {
      _answered = true;
      _selectedId = optionId;
      if (isCorrect) _correctCount++;
    });

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      _playSfx('assets/audio/correct.mp3');
    } else {
      HapticFeedback.mediumImpact();
      _playSfx('assets/audio/wrong.mp3');
    }

    // Advance after delay
    Future.delayed(const Duration(milliseconds: 1400), _nextRound);
  }

  void _nextRound() {
    if (!mounted) return;
    _mainPlayer.stop();
    if (_currentRound + 1 >= _totalRounds) {
      setState(() => _gameOver = true);
      _winController.forward(from: 0);
    } else {
      setState(() => _currentRound++);
      _loadRound();
    }
  }

  // ─────────────────────────────────────────────────────────
  SoundQuestion get _current => _questionPool[_currentRound];

  OptionState _stateFor(String id) {
    if (!_answered) return OptionState.idle;
    if (id == _current.correctId) return OptionState.correct;
    if (id == _selectedId) return OptionState.wrong;
    return OptionState.idle;
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
          _BackgroundPainter(accentColor: _accent),

          Column(
            children: [
              _buildAppBar(theme),

              // Progress bar
              _buildProgressBar(theme),

              Expanded(
                child: _gameOver
                    ? const SizedBox.shrink()
                    : FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildGameContent(theme, size),
                      ),
              ),
            ],
          ),

          if (_gameOver) _buildGameOverOverlay(theme),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  Widget _buildAppBar(ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF6BCB77),
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
              const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Juego de Sonidos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Score chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_correctCount / $_totalRounds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final rawProgress = (_currentRound + 1) / _totalRounds;
    final progress = rawProgress.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregunta ${_currentRound + 1} de $_totalRounds',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              // Round dots
              Row(
                children: List.generate(_totalRounds, (i) {
                  Color dotColor;
                  if (i < _currentRound) {
                    dotColor = const Color(0xFF43A047);
                  } else if (i == _currentRound) {
                    dotColor = _accent;
                  } else {
                    dotColor = theme.colorScheme.outline;
                  }
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentRound ? 20 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(_accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(ThemeData theme, Size size) {
    final crossCount = size.width > 500 ? 4 : 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          // Sound button
          SoundButtonWidget(
            state: _soundState,
            hint: _current.hint,
            onTap: _playSound,
          ),

          const SizedBox(height: 32),

          // Options grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: _shuffledOptions.length,
            itemBuilder: (context, i) {
              final opt = _shuffledOptions[i];
              return OptionItemWidget(
                emoji: opt.emoji,
                label: opt.label,
                state: _stateFor(opt.id),
                onTap: () => _onOptionTap(opt.id),
              );
            },
          ),

          const SizedBox(height: 24),

          // Answer feedback banner
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _answered
                ? _AnswerBanner(
                    key: ValueKey(_currentRound),
                    isCorrect: _selectedId == _current.correctId,
                    correctLabel: _current.options
                        .firstWhere((o) => o.id == _current.correctId)
                        .label,
                  )
                : const SizedBox(height: 48),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  Widget _buildGameOverOverlay(ThemeData theme) {
    final percent = (_correctCount / _totalRounds * 100).round();
    final emoji = percent >= 80
        ? '🏆'
        : percent >= 60
        ? '⭐'
        : '💪';
    final message = percent >= 80
        ? '¡Excelente!'
        : percent >= 60
        ? '¡Muy bien!'
        : '¡Sigue practicando!';

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
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Text(emoji, style: const TextStyle(fontSize: 64)),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: _accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Acertaste $_correctCount de $_totalRounds sonidos',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final filled =
                        i <
                        (percent >= 80
                            ? 3
                            : percent >= 60
                            ? 2
                            : 1);
                    return Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 40,
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(label: 'Correctas', value: '$_correctCount'),
                      _Stat(
                        label: 'Errores',
                        value: '${_totalRounds - _correctCount}',
                      ),
                      _Stat(label: 'Precisión', value: '$percent%'),
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
// Answer feedback banner
// ─────────────────────────────────────────────────────────────
class _AnswerBanner extends StatelessWidget {
  final bool isCorrect;
  final String correctLabel;

  const _AnswerBanner({
    super.key,
    required this.isCorrect,
    required this.correctLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? const Color(0xFF43A047) : const Color(0xFFE53935);
    final bg = isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final icon = isCorrect ? '🎉' : '❌';
    final text = isCorrect
        ? '¡Correcto! Es un $correctLabel'
        : 'Era el $correctLabel';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text(
            text,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Background widget
// ─────────────────────────────────────────────────────────────
class _BackgroundPainter extends StatelessWidget {
  final Color accentColor;
  const _BackgroundPainter({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _BgPainter(accentColor)),
    );
  }
}

class _BgPainter extends CustomPainter {
  final Color accent;
  const _BgPainter(this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final blobs = [
      (
        Offset(size.width * 0.1, size.height * 0.06),
        70.0,
        accent.withOpacity(0.08),
      ),
      (
        Offset(size.width * 0.9, size.height * 0.15),
        90.0,
        accent.withOpacity(0.05),
      ),
      (
        Offset(size.width * 0.05, size.height * 0.75),
        55.0,
        accent.withOpacity(0.07),
      ),
      (
        Offset(size.width * 0.92, size.height * 0.85),
        75.0,
        accent.withOpacity(0.06),
      ),
    ];
    for (final (pos, r, color) in blobs) {
      canvas.drawCircle(pos, r, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────
// Stat chip
// ─────────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

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
