import 'package:control_parental_child/features/home/domain/models/game_model.dart';
import 'package:flutter/material.dart';

class GameRepository {
  List<Game> getGames() {
    return const [
      Game(
        title: 'Juego de\nMemoria',
        description: 'Encuentra las parejas iguales',
        icon: Icons.grid_view_rounded,
        color: Color(0xFFFF6B6B),
        route: '/memory',
      ),
      Game(
        title: 'Juego de\nColores',
        description: 'Clasifica por colores',
        icon: Icons.palette_rounded,
        color: Color(0xFFFFB347),
        route: '/color',
      ),
      Game(
        title: 'Juego de\nSonidos',
        description: 'Aprende con el lenguaje',
        icon: Icons.music_note_rounded,
        color: Color(0xFF6BCB77),
        route: '/sound',
      ),
      Game(
        title: 'Juego de\nFormas',
        description: 'Arrastra y suelta figuras',
        icon: Icons.category_rounded,
        color: Color(0xFF4D96FF),
        route: '/shape',
      ),
    ];
  }
}
