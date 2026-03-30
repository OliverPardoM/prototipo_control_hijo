// lib/models/shape_model.dart

import 'package:flutter/material.dart';

enum ShapeType { circle, square, triangle, star, diamond }

extension ShapeTypeExt on ShapeType {
  String get label {
    switch (this) {
      case ShapeType.circle:
        return 'Círculo';
      case ShapeType.square:
        return 'Cuadrado';
      case ShapeType.triangle:
        return 'Triángulo';
      case ShapeType.star:
        return 'Estrella';
      case ShapeType.diamond:
        return 'Rombo';
    }
  }

  String get emoji {
    switch (this) {
      case ShapeType.circle:
        return '⚪';
      case ShapeType.square:
        return '⬜';
      case ShapeType.triangle:
        return '🔺';
      case ShapeType.star:
        return '⭐';
      case ShapeType.diamond:
        return '🔷';
    }
  }
}

class ShapeItemModel {
  final String id;
  final ShapeType type;
  final Color color;
  bool isPlaced;

  ShapeItemModel({
    required this.id,
    required this.type,
    required this.color,
    this.isPlaced = false,
  });

  ShapeItemModel copyWith({bool? isPlaced}) => ShapeItemModel(
    id: id,
    type: type,
    color: color,
    isPlaced: isPlaced ?? this.isPlaced,
  );
}

class ShapeTargetModel {
  final String id; // matches ShapeType.name
  final ShapeType type;
  final Color color;
  final Color lightColor;

  const ShapeTargetModel({
    required this.id,
    required this.type,
    required this.color,
    required this.lightColor,
  });
}

// ─── Difficulty config ────────────────────────────────────────
enum ShapeDifficulty { easy, medium, hard }

extension ShapeDifficultyExt on ShapeDifficulty {
  String get label {
    switch (this) {
      case ShapeDifficulty.easy:
        return 'Fácil';
      case ShapeDifficulty.medium:
        return 'Normal';
      case ShapeDifficulty.hard:
        return 'Difícil';
    }
  }

  Color get color {
    switch (this) {
      case ShapeDifficulty.easy:
        return const Color(0xFF6BCB77);
      case ShapeDifficulty.medium:
        return const Color(0xFFFFB347);
      case ShapeDifficulty.hard:
        return const Color(0xFFFF6B6B);
    }
  }

  List<ShapeType> get types {
    switch (this) {
      case ShapeDifficulty.easy:
        return [ShapeType.circle, ShapeType.square, ShapeType.triangle];
      case ShapeDifficulty.medium:
        return [
          ShapeType.circle,
          ShapeType.square,
          ShapeType.triangle,
          ShapeType.star,
        ];
      case ShapeDifficulty.hard:
        return ShapeType.values;
    }
  }

  // How many items per shape type
  int get itemsPerShape => this == ShapeDifficulty.hard ? 1 : 2;
}

// ─── Static color palette per shape ──────────────────────────
class ShapeGameData {
  static const Map<ShapeType, ShapeTargetModel> targets = {
    ShapeType.circle: ShapeTargetModel(
      id: 'circle',
      type: ShapeType.circle,
      color: Color(0xFF4D96FF),
      lightColor: Color(0xFFE3F2FD),
    ),
    ShapeType.square: ShapeTargetModel(
      id: 'square',
      type: ShapeType.square,
      color: Color(0xFFFF6B6B),
      lightColor: Color(0xFFFFEBEE),
    ),
    ShapeType.triangle: ShapeTargetModel(
      id: 'triangle',
      type: ShapeType.triangle,
      color: Color(0xFF6BCB77),
      lightColor: Color(0xFFE8F5E9),
    ),
    ShapeType.star: ShapeTargetModel(
      id: 'star',
      type: ShapeType.star,
      color: Color(0xFFFFB347),
      lightColor: Color(0xFFFFF3E0),
    ),
    ShapeType.diamond: ShapeTargetModel(
      id: 'diamond',
      type: ShapeType.diamond,
      color: Color(0xFFC77DFF),
      lightColor: Color(0xFFF3E5F5),
    ),
  };

  // Item color variants per shape
  static const Map<ShapeType, List<Color>> itemColors = {
    ShapeType.circle: [Color(0xFF4D96FF), Color(0xFF0288D1)],
    ShapeType.square: [Color(0xFFFF6B6B), Color(0xFFE53935)],
    ShapeType.triangle: [Color(0xFF6BCB77), Color(0xFF43A047)],
    ShapeType.star: [Color(0xFFFFB347), Color(0xFFFFA000)],
    ShapeType.diamond: [Color(0xFFC77DFF), Color(0xFF9C27B0)],
  };

  static List<ShapeItemModel> generateItems(ShapeDifficulty diff) {
    final items = <ShapeItemModel>[];
    int idx = 0;
    for (final type in diff.types) {
      final colors = itemColors[type]!;
      for (int i = 0; i < diff.itemsPerShape; i++) {
        items.add(
          ShapeItemModel(
            id: '${type.name}_$i',
            type: type,
            color: colors[i % colors.length],
          ),
        );
        idx++;
      }
    }
    items.shuffle();
    return items;
  }
}
