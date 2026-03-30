import 'package:flutter/material.dart';

class Game {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const Game({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
