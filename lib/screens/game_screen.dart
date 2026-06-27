import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/stage_data.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../shared/app_colors.dart';
import '../shared/app_text_styles.dart';
import '../shared/game_shell.dart';
import '../widgets/memory_card.dart';
import '../widgets/stage_banner.dart';
import '../widgets/confetti_overlay.dart';

class GameScreen extends StatefulWidget {
  final SoundService? sound;
  final StorageService storage;
  final int startStage;

  const GameScreen({
    super.key,
    required this.sound,
    required this.storage,
    required this.startStage,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late GameState _gameState;
  late StageData _stageData;
  late List<MemoryCard> _cards;
  int? _firstIndex;
  int? _secondIndex;
  bool _isChecking = false;
  bool _won = false;
  bool _gameComplete = false;
  int _pairsFound = 0;
  int _moves = 0;
  bool _showStageIntro = true;
  final List<int> _usedIds = [];

  late AnimationController _celebrateController;
  late Animation<double> _celebrateAnimation;
  late AnimationController _pulseController;
  late AnimationController _introController;
  late Animation<double> _introScale;
  late Animation<double> _introFade;

  bool _newHighScore = false;

  @override
  void initState() {
    super.initState();
    _gameState = widget.storage.loadGameState();
    _gameState.currentStage = widget.startStage.clamp(1, totalStages);

    _celebrateController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _celebrateAnimation = CurvedAnimation(
      parent: _celebrateController,
      curve: Curves.elasticOut,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _introController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _introScale = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.elasticOut),
    );
    _introFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _initStage();
    _showStageIntroSequence();
  }

  void _showStageIntroSequence() {
    _showStageIntro = true;
    _introController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _showStageIntro = false);
      });
    });
  }

  void _initStage() {
    _stageData = getStageData(_gameState.currentStage);
    _usedIds.clear();
    _cards = generateCards(pairs: _stageData.pairs, usedIds: []);
    _firstIndex = null;
    _secondIndex = null;
    _isChecking = false;
    _won = false;
    _pairsFound = 0;
    _moves = 0;
    _celebrateController.reset();
    _showStageIntro = true;
    _newHighScore = false;
  }

  void _onCardTap(int index) {
    if (_isChecking || _won || _gameComplete || _showStageIntro) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;

    widget.sound?.tap();

    setState(() {
      _cards[index].isFlipped = true;
      if (_firstIndex == null) {
        _firstIndex = index;
      } else if (_secondIndex == null) {
        _secondIndex = index;
        _moves++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    _isChecking = true;
    final first = _cards[_firstIndex!];
    final second = _cards[_secondIndex!];

    if (first.id == second.id) {
      widget.sound?.match();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          first.isMatched = true;
          second.isMatched = true;
          _pairsFound++;
          _firstIndex = null;
          _secondIndex = null;
          _isChecking = false;
          if (_pairsFound == _stageData.pairs) {
            _onStageComplete();
          }
        });
      });
    } else {
      widget.sound?.wrong();
      _triggerWrongMatch(_firstIndex!, _secondIndex!);
      Future.delayed(Duration(milliseconds: _stageData.revealMs), () {
        if (!mounted) return;
        setState(() {
          first.isFlipped = false;
          second.isFlipped = false;
          _firstIndex = null;
          _secondIndex = null;
          _isChecking = false;
        });
      });
    }
  }

  void _triggerWrongMatch(int i1, int i2) {
    setState(() {});
  }

  void _onStageComplete() {
    _won = true;
    _celebrateController.forward();

    final stageScore = _stageData.stage * 10 + (_stageData.pairs * 50 ~/ _moves.clamp(1, 999));
    _gameState.totalScore += stageScore;

    final oldHigh = _gameState.highScore;
    if (_gameState.totalScore > _gameState.highScore) {
      _gameState.highScore = _gameState.totalScore;
    }
    _newHighScore = _gameState.highScore > oldHigh;

    if (_stageData.stage < totalStages) {
      _gameState.currentStage++;
    }
    widget.storage.saveGameState(_gameState);

    if (_stageData.stage >= totalStages) {
      _gameComplete = true;
      widget.sound?.gameComplete();
    } else {
      widget.sound?.stageComplete();
    }
  }

  void _goToNextStage() {
    setState(() {
      _gameState.totalScore += _stageData.stage * 50;
      widget.storage.saveGameState(_gameState);
      _initStage();
    });
    _showStageIntroSequence();
  }

  void _restartStage() {
    setState(() {
      _initStage();
    });
    _showStageIntroSequence();
  }

  @override
  void dispose() {
    _celebrateController.dispose();
    _pulseController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameShell(
      title: _gameComplete
          ? 'Congratulations!'
          : _won
              ? 'Stage ${_stageData.stage} Complete!'
              : 'Stage ${_stageData.stage}',
      onBack: () {
        widget.storage.saveGameState(_gameState);
        Navigator.pop(context);
      },
      isMuted: widget.sound?.isMuted ?? false,
      onMuteToggle: () {
        widget.sound?.toggleMute();
        setState(() {});
      },
      child: Stack(
        children: [
          _buildContent(),
          if (_showStageIntro) _buildStageIntro(),
          if (_won && !_gameComplete)
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiOverlay(
                  animation: _celebrateAnimation,
                  accentColor: AppColors.tertiary,
                ),
              ),
            ),
          if (_gameComplete)
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiOverlay(
                  animation: _pulseController,
                  accentColor: AppColors.tertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStageIntro() {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _introFade,
        child: Container(
          color: AppColors.overlay,
          child: Center(
            child: AnimatedBuilder(
              animation: _introScale,
              builder: (context, _) {
                return Transform.scale(
                  scale: _introScale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 3),
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('STAGE', style: AppTextStyles.overlay),
                      Text(
                        '${_stageData.stage}',
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 4.0,
                          shadows: [
                            Shadow(color: AppColors.primary, blurRadius: 40),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_stageData.pairs} pairs  \u2022  ${_stageData.revealMs}ms speed',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryOf(context)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_gameComplete) return _buildGameComplete();

    return Column(
      children: [
        StageBanner(
          currentStage: _stageData.stage,
          totalStages: totalStages,
          score: _gameState.totalScore,
          highScore: _gameState.highScore,
          moves: _moves,
          stagePairs: _stageData.pairs,
        ),
        if (!_won)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 14,
                        color: _pairsFound > 0 ? AppColors.success : AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '$_pairsFound/${_stageData.pairs}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondaryOf(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Expanded(
          child: _won ? _buildStageComplete() : _buildGameGrid(),
        ),
      ],
    );
  }

  Widget _buildGameGrid() {
    final cols = _stageData.columns;
    final rows = (_cards.length / cols).ceil();
    final spacing = 8.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxCardW = (constraints.maxWidth - spacing * (cols - 1)) / cols;
          final maxCardH = (constraints.maxHeight - spacing * (rows - 1)) / rows;
          final cardSize = maxCardW < maxCardH ? maxCardW : maxCardH;
          final gridH = rows * cardSize + (rows - 1) * spacing;
          final gridW = cols * cardSize + (cols - 1) * spacing;
          return Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: gridW,
              height: gridH,
              child: Column(
                children: List.generate(rows, (r) {
                  return SizedBox(
                    height: cardSize,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: r < rows - 1 ? spacing : 0),
                      child: Row(
                        children: List.generate(cols, (c) {
                          final i = r * cols + c;
                          if (i >= _cards.length) {
                            return SizedBox(width: cardSize);
                          }
                          final isWrong = _isChecking &&
                              !_cards[i].isMatched &&
                              (i == _firstIndex || i == _secondIndex) &&
                              _cards[_firstIndex ?? 0].id != _cards[_secondIndex ?? 0].id;
                          return Padding(
                            padding: EdgeInsets.only(right: c < cols - 1 ? spacing : 0),
                            child: SizedBox(
                              width: cardSize,
                              height: cardSize,
                              child: MemoryCardWidget(
                                card: _cards[i],
                                index: i,
                                onTap: () => _onCardTap(i),
                                disabled: _isChecking || _won,
                                wrongMatch: isWrong,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStageComplete() {
    final stageScore =
        _stageData.stage * 10 + (_stageData.pairs * 50 ~/ _moves.clamp(1, 999));
    return FadeTransition(
      opacity: _celebrateAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          AnimatedBuilder(
            animation: _celebrateAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.3 + _celebrateAnimation.value * 0.7,
                child: child,
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.success, Color(0xFF388E3C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Stage ${_stageData.stage} Complete!',
              style: AppTextStyles.success),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$_moves moves  \u2022  +$stageScore pts',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${_gameState.totalScore}',
                  style: AppTextStyles.gold,
                ),
                if (_newHighScore) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4), width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.tertiary),
                        SizedBox(width: 6),
                        Text(
                          'NEW HIGH SCORE!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.tertiary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(flex: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _goToNextStage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 6,
                      shadowColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      _stageData.stage >= totalStages
                          ? 'See Results \u2192'
                          : 'Next Stage \u2192',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _restartStage,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Retry This Stage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildGameComplete() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.85 + _pulseController.value * 0.15,
              child: child,
            );
          },
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                  colors: [AppColors.tertiary, Color(0xFFFFA500)],
              ),
              boxShadow: [
                BoxShadow(
                    color: AppColors.tertiary.withValues(alpha: 0.5),
                    blurRadius: 35,
                    spreadRadius: 6,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 72,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('You Win!', style: AppTextStyles.success),
        const SizedBox(height: 6),
        Text(
          'All 50 Stages Completed!',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondaryOf(context)),
        ),
        const SizedBox(height: 28),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 60),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            children: [
              Text(
                '${_gameState.totalScore}',
                style: AppTextStyles.goldLarge,
              ),
              const SizedBox(height: 2),
              Text('Final Score',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondaryOf(context))),
              const SizedBox(height: 10),
              Container(height: 1, color: AppColors.dividerOf(context)),
              const SizedBox(height: 10),
              Text(
                '${_gameState.highScore}',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text('High Score',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondaryOf(context))),
            ],
          ),
        ),
        const Spacer(flex: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                _gameState.currentStage = 1;
                _gameState.totalScore = 0;
                widget.storage.saveGameState(_gameState);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
                shadowColor: AppColors.tertiary.withValues(alpha: 0.5),
              ),
              child: const Text('Play Again', style: AppTextStyles.button),
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
