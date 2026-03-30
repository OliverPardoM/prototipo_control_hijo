// lib/models/color_item_model.dart

import 'package:flutter/material.dart';

class ColorItemModel {
  final String id;
  final String emoji;
  final String label;
  final Color color;
  final String targetId;
  bool isPlaced;
  bool isDragging;

  ColorItemModel({
    required this.id,
    required this.emoji,
    required this.label,
    required this.color,
    required this.targetId,
    this.isPlaced = false,
    this.isDragging = false,
  });

  ColorItemModel copyWith({bool? isPlaced, bool? isDragging}) {
    return ColorItemModel(
      id: id,
      emoji: emoji,
      label: label,
      color: color,
      targetId: targetId,
      isPlaced: isPlaced ?? this.isPlaced,
      isDragging: isDragging ?? this.isDragging,
    );
  }
}

class ColorBucketModel {
  final String id;
  final String label;
  final Color color;
  final Color lightColor;

  const ColorBucketModel({
    required this.id,
    required this.label,
    required this.color,
    required this.lightColor,
  });
}

class ColorGameData {
  static const List<ColorBucketModel> buckets = [
    ColorBucketModel(
      id: 'red',
      label: 'Rojo',
      color: Color(0xFFE53935),
      lightColor: Color(0xFFFFEBEE),
    ),
    ColorBucketModel(
      id: 'blue',
      label: 'Azul',
      color: Color(0xFF1E88E5),
      lightColor: Color(0xFFE3F2FD),
    ),
    ColorBucketModel(
      id: 'green',
      label: 'Verde',
      color: Color(0xFF43A047),
      lightColor: Color(0xFFE8F5E9),
    ),
    ColorBucketModel(
      id: 'yellow',
      label: 'Amarillo',
      color: Color(0xFFFDD835),
      lightColor: Color(0xFFFFFDE7),
    ),
  ];

  static List<ColorItemModel> generateItems() {
    final raw = [
      _i('r1', '🍎', 'Manzana', const Color(0xFFE53935), 'red'),
      _i('r2', '🌹', 'Rosa', const Color(0xFFE53935), 'red'),
      _i('r3', '🎈', 'Globo', const Color(0xFFE53935), 'red'),
      _i('b1', '🫐', 'Arándano', const Color(0xFF1E88E5), 'blue'),
      _i('b2', '🐬', 'Delfín', const Color(0xFF1E88E5), 'blue'),
      _i('b3', '💎', 'Diamante', const Color(0xFF1E88E5), 'blue'),
      _i('g1', '🍀', 'Trébol', const Color(0xFF43A047), 'green'),
      _i('g2', '🐸', 'Rana', const Color(0xFF43A047), 'green'),
      _i('g3', '🥦', 'Brócoli', const Color(0xFF43A047), 'green'),
      _i('y1', '🌟', 'Estrella', const Color(0xFFFDD835), 'yellow'),
      _i('y2', '🍋', 'Limón', const Color(0xFFFDD835), 'yellow'),
      _i('y3', '🌻', 'Girasol', const Color(0xFFFDD835), 'yellow'),
    ];
    raw.shuffle();
    return raw;
  }

  static ColorItemModel _i(
    String id,
    String emoji,
    String label,
    Color color,
    String target,
  ) => ColorItemModel(
    id: id,
    emoji: emoji,
    label: label,
    color: color,
    targetId: target,
  );
}
