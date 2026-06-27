import 'package:flutter/material.dart';

class StageData {
  final int stage;
  final int pairs;
  final int revealMs;

  const StageData({
    required this.stage,
    required this.pairs,
    required this.revealMs,
  });

  int get totalCards => pairs * 2;

  int get columns {
    if (totalCards <= 8) return 4;
    if (totalCards <= 12) return 4;
    if (totalCards <= 16) return 4;
    if (totalCards <= 20) return 5;
    return 5;
  }

  double get childAspectRatio => totalCards <= 12 ? 1.0 : 0.9;
}

const int totalStages = 50;

StageData getStageData(int stage) {
  final clamped = stage.clamp(1, totalStages);

  int pairs;
  if (clamped <= 10) {
    pairs = 3;
  } else if (clamped <= 20) {
    pairs = 4;
  } else if (clamped <= 30) {
    pairs = 5;
  } else if (clamped <= 40) {
    pairs = 6;
  } else {
    pairs = 7;
  }

  final revealMs = (2200 - (clamped - 1) * 30).clamp(700, 2200);

  return StageData(stage: clamped, pairs: pairs, revealMs: revealMs);
}

const List<IconData> cardIcons = [
  Icons.apple,
  Icons.eco_rounded,
  Icons.flight_rounded,
  Icons.pets_rounded,
  Icons.star_rounded,
  Icons.favorite_rounded,
  Icons.home_rounded,
  Icons.directions_car_rounded,
  Icons.music_note_rounded,
  Icons.local_pizza_rounded,
  Icons.palette_rounded,
  Icons.bolt_rounded,
  Icons.cake_rounded,
  Icons.camera_alt_rounded,
  Icons.diamond_rounded,
  Icons.lightbulb_rounded,
  Icons.nights_stay_rounded,
  Icons.wb_sunny_rounded,
  Icons.rocket_launch_rounded,
  Icons.anchor_rounded,
];

const List<Color> cardColors = [
  Color(0xFFE8734A),
  Color(0xFF4A90D9),
  Color(0xFF5B8C5A),
  Color(0xFFD4A843),
  Color(0xFFB05E8A),
  Color(0xFF6BB8B8),
  Color(0xFFE8734A),
  Color(0xFF4A90D9),
  Color(0xFF9B59B6),
  Color(0xFFE67E22),
  Color(0xFF1ABC9C),
  Color(0xFFF1C40F),
  Color(0xFFE74C3C),
  Color(0xFF3498DB),
  Color(0xFF2ECC71),
  Color(0xFFF39C12),
  Color(0xFF9B59B6),
  Color(0xFF34495E),
  Color(0xFFE91E63),
  Color(0xFF00BCD4),
];
