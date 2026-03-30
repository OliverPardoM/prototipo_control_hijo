// lib/features/home/ui/pages/home_screen.dart

import 'package:control_parental_child/features/ShapeGame/ui/pages/shape_game_page.dart';
import 'package:control_parental_child/features/colorGame/ui/pages/color_game_page.dart';
import 'package:control_parental_child/features/home/domain/provider/game_time_provider.dart';
import 'package:control_parental_child/features/home/ui/pages/lock_page.dart';
import 'package:control_parental_child/features/home/ui/widgets/recomendation_card.dart';

import 'package:control_parental_child/features/memoryGame/ui/pages/memory_game_page.dart';
import 'package:control_parental_child/features/soundGame/ui/pages/sound_game_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<GameModel> _games = [
    GameModel(
      title: 'Juego de\nMemoria',
      description: 'Encuentra las parejas iguales',
      icon: Icons.grid_view_rounded,
      color: const Color(0xFFFF6B6B),
      iconColor: Colors.white,
      destination: const MemoryGameScreen(),
    ),
    GameModel(
      title: 'Juego de\nColores',
      description: 'Clasifica por colores',
      icon: Icons.palette_rounded,
      color: const Color(0xFFFFB347),
      iconColor: Colors.white,
      destination: const ColorGameScreen(),
    ),
    GameModel(
      title: 'Juego de\nSonidos',
      description: 'Aprende con el lenguaje',
      icon: Icons.music_note_rounded,
      color: const Color(0xFF6BCB77),
      iconColor: Colors.white,
      destination: const SoundGameScreen(),
    ),
    GameModel(
      title: 'Juego de\nFormas',
      description: 'Arrastra y suelta figuras',
      icon: Icons.category_rounded,
      color: const Color(0xFF4D96FF),
      iconColor: Colors.white,
      destination: const ShapeGameScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      body: Consumer<GameTimeProvider>(
        builder: (context, provider, child) {
          if (provider.isBlocked) return const LockScreen();
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          const Color(0xFF0077B6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.white.withOpacity(
                                        0.25,
                                      ),
                                      child: const Icon(
                                        Icons.child_care_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '¡Hola, pequeño!',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                        Text(
                                          '¿Qué jugamos hoy?',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.shield_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  tooltip: 'Control Parental',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: List.generate(5, (i) {
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: i < 3
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '3 de 5 juegos completados ⭐',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.only(top: 16),
                sliver: SliverToBoxAdapter(
                  child: RecommendationCard(
                    minutesPlayed: provider.minutesPlayedToday,
                  ),
                ),
              ),

              // Section title
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Icon(
                        Icons.videogame_asset_rounded,
                        color: theme.colorScheme.onSurface,
                        size: 40,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mis Juegos',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Grid of games
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == _games.length - 1 && _games.length.isOdd) {
                      return _WideGameCard(game: _games[index]);
                    }
                    return GameCard(game: _games[index]);
                  }, childCount: _games.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size.width > 600 ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// WideGameCard (tu código existente)
class _WideGameCard extends StatefulWidget {
  final GameModel game;
  const _WideGameCard({required this.game});

  @override
  State<_WideGameCard> createState() => _WideGameCardState();
}

class _WideGameCardState extends State<_WideGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) => FadeTransition(
                opacity: animation,
                child: widget.game.destination,
              ),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ).then((_) {
            // ✅ Al regresar del juego, recargar los minutos
            print('🔄 Regresando de juego, recargando minutos...');
            final provider = Provider.of<GameTimeProvider>(
              context,
              listen: false,
            );
            provider.loadTodayMinutes();
          });
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: widget.game.color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.game.color.withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        widget.game.icon,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.game.title.replaceAll('\n', ' '),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.game.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 28,
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
}
