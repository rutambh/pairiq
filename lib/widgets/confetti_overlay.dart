import 'dart:math';
import 'package:flutter/material.dart';
import '../shared/app_colors.dart';

class ConfettiPiece {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double rotation;
  final double size;
  final Color color;
  final double delay;

  ConfettiPiece({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.rotation,
    required this.size,
    required this.color,
    required this.delay,
  });
}

class ConfettiOverlay extends StatefulWidget {
  final Animation<double> animation;
  final Color accentColor;

  const ConfettiOverlay({
    super.key,
    required this.animation,
    this.accentColor = AppColors.tertiary,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late List<ConfettiPiece> _pieces;
  final _random = Random(42);

  @override
  void initState() {
    super.initState();
    _pieces = List.generate(30, (i) {
      final x = 0.5 + (_random.nextDouble() - 0.5) * 0.8;
      final y = 0.5 + (_random.nextDouble() - 0.5) * 0.8;
      final angle = _random.nextDouble() * 2 * pi;
      final dist = 0.2 + _random.nextDouble() * 0.5;
      return ConfettiPiece(
        startX: x,
        startY: y,
        endX: x + cos(angle) * dist,
        endY: y + sin(angle) * dist + 0.2,
        rotation: _random.nextDouble() * 4 * pi,
        size: 4 + _random.nextDouble() * 6,
        color: [
          widget.accentColor,
          AppColors.primary,
          AppColors.secondary,
          AppColors.success,
          AppColors.tertiary,
          AppColors.primaryFixed,
        ][_random.nextInt(6)],
        delay: _random.nextDouble() * 0.3,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return Stack(
              children: _pieces.map((piece) {
                final t = ((widget.animation.value - piece.delay) / (1.0 - piece.delay)).clamp(0.0, 1.0);
                final opacity = t < 0.0
                    ? 0.0
                    : t > 0.8
                        ? (1.0 - (t - 0.8) / 0.2)
                        : 1.0;
                final x = (piece.startX + (piece.endX - piece.startX) * t) * w;
                final y = (piece.startY + (piece.endY - piece.startY) * t) * h;
                return Positioned(
                  left: x - piece.size / 2,
                  top: y - piece.size / 2,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: piece.rotation * t,
                      child: Container(
                        width: piece.size,
                        height: piece.size * 1.5,
                        decoration: BoxDecoration(
                          color: piece.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
