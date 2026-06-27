import 'dart:math';
import 'package:flutter/material.dart';
import '../models/stage_data.dart';
import '../shared/app_colors.dart';

class MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final int index;
  final bool disabled;
  final bool wrongMatch;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    required this.index,
    this.disabled = false,
    this.wrongMatch = false,
  });

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = false;

  late AnimationController _tapController;
  late Animation<double> _tapScale;

  late AnimationController _shakeController;
  late Animation<double> _shakeOffset;

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _flipController, curve: Curves.easeInOut));
    _flipController.addListener(() {
      if (_flipController.value >= 0.5 && !_showFront) {
        setState(() => _showFront = true);
      }
    });

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _tapScale = Tween(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 4.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.linear));

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    if (widget.card.isFlipped || widget.card.isMatched) {
      _flipController.value = 1.0;
      _showFront = true;
    }
    if (widget.card.isMatched) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldShow = widget.card.isFlipped || widget.card.isMatched;
    if (shouldShow && !_showFront && !_flipController.isAnimating) {
      _flipController.forward();
    } else if (!shouldShow && _showFront && !_flipController.isAnimating) {
      _flipController.reverse().then((_) {
        if (mounted) setState(() => _showFront = false);
      });
    }

    if (widget.card.isMatched && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!widget.card.isMatched && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.reset();
    }

    if (widget.wrongMatch && !oldWidget.wrongMatch && !_shakeController.isAnimating) {
      _shakeController.forward().then((_) => _shakeController.reset());
    }
  }

  void onTapDown() {
    if (!widget.disabled && !widget.card.isFlipped && !widget.card.isMatched) {
      _tapController.forward();
    }
  }

  void onTapUp() {
    _tapController.reverse();
  }

  void onTapCancel() {
    _tapController.reverse();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _tapController.dispose();
    _shakeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_tapScale, _shakeOffset, _glowController]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(_shakeOffset.value, 0),
          child: Transform.scale(
            scale: _tapScale.value,
            child: GestureDetector(
              onTap: widget.disabled ? null : widget.onTap,
              onTapDown: (_) => onTapDown(),
              onTapUp: (_) => onTapUp(),
              onTapCancel: onTapCancel,
              child: _buildCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    final isMatched = widget.card.isMatched;

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: isMatched
                  ? [
                      BoxShadow(
                        color: widget.card.color.withValues(alpha: 0.2 + _glowController.value * 0.3),
                        blurRadius: 8 + _glowController.value * 8,
                        spreadRadius: 1 + _glowController.value * 2,
                      ),
                    ]
                  : null,
            ),
            child: _showFront
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildFront(),
                  )
                : _buildBack(),
          ),
        );
      },
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardBackGradient1, AppColors.cardBackGradient2],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline_rounded,
                color: Colors.white.withValues(alpha: 0.9), size: 32),
            const SizedBox(height: 4),
            Text(
              '?',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFront() {
    final card = widget.card;
    final isMatched = card.isMatched;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMatched ? card.color.withValues(alpha: 0.5) : card.color,
          width: isMatched ? 2 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: card.color.withValues(alpha: isMatched ? 0.2 : 0.3),
            blurRadius: isMatched ? 6 : 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(card.icon, size: 30, color: card.color),
          const SizedBox(height: 2),
          Text(
            '${card.id + 1}',
            style: TextStyle(
              fontSize: 11,
              color: card.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MemoryCard {
  final int id;
  final IconData icon;
  final Color color;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.icon,
    required this.color,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

List<MemoryCard> generateCards({required int pairs, required List<int> usedIds}) {
  final available = <int>[];
  for (int i = 0; i < cardIcons.length; i++) {
    if (!usedIds.contains(i)) available.add(i);
  }
  if (pairs > available.length) {
    available.addAll(List.generate(pairs - available.length, (i) => i));
  }
  available.shuffle();
  final selected = available.take(pairs).toList();
  final cards = <MemoryCard>[];
  for (final id in selected) {
    cards.add(MemoryCard(id: id, icon: cardIcons[id], color: cardColors[id]));
    cards.add(MemoryCard(id: id, icon: cardIcons[id], color: cardColors[id]));
  }
  cards.shuffle();
  return cards;
}
