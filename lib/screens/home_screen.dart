import 'package:flutter/material.dart';
import '../shared/app_colors.dart';
import '../shared/app_text_styles.dart';
import '../shared/game_shell.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  SoundService? _sound;
  StorageService? _storage;
  int _highScore = 0;
  int _lastStage = 1;
  bool _loaded = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _logoPulse;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _logoPulse = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _init();
  }

  Future<void> _init() async {
    _sound = await SoundService.getInstance();
    _storage = await StorageService.getInstance();
    final state = _storage!.loadGameState();
    _highScore = state.highScore;
    _lastStage = state.currentStage;
    if (mounted) {
      setState(() => _loaded = true);
      _fadeController.forward();
      _sound?.startMusic();
    }
  }

  Future<void> _startGame() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          sound: _sound,
          storage: _storage!,
          startStage: _lastStage,
        ),
      ),
    );
    _reloadState();
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _reloadState() {
    if (!mounted || _storage == null) return;
    final state = _storage!.loadGameState();
    setState(() {
      _highScore = state.highScore;
      _lastStage = state.currentStage;
    });
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
            const SizedBox(width: 10),
            const Text('Reset Progress', style: AppTextStyles.dialogTitle),
          ],
        ),
        content: const Text(
          'This will erase all your progress including high score and current stage. This cannot be undone.',
          style: AppTextStyles.dialogContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset',
                style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage!.resetProgress();
      if (mounted) {
        setState(() {
          _highScore = 0;
          _lastStage = 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Text('Progress has been reset', style: AppTextStyles.toast),
              ],
            ),
            backgroundColor: AppColors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _logoPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameShell(
      title: '',
      hideTitle: true,
      isMuted: _sound?.isMuted ?? false,
      onMuteToggle: () {
        _sound?.toggleMute();
        setState(() {});
      },
      child: _loaded
          ? FadeTransition(
              opacity: _fadeAnimation,
              child: _buildBody(),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Loading...', style: AppTextStyles.stageLabel),
                ],
              ),
            ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const Spacer(flex: 2),
        _buildLogo(),
        const SizedBox(height: 24),
        Text('Pair IQ', style: AppTextStyles.title.copyWith(color: AppColors.textPrimaryOf(context))),
        const SizedBox(height: 28),
        _buildStatsCard(),
        const Spacer(flex: 2),
        _buildMenuButtons(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoPulse,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.92 + _logoPulse.value * 0.08,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryContainer, AppColors.cardBackGradient2],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(Icons.psychology_rounded, size: 72, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceContainerHighestOf(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              Icons.emoji_events_rounded,
              'High Score',
              _highScore.toString(),
              AppColors.tertiary,
            ),
          ),
          Container(
            width: 1,
            height: 44,
            color: AppColors.dividerOf(context),
          ),
          Expanded(
            child: _statItem(
              Icons.flag_rounded,
              'Last Stage',
              '$_lastStage / 50',
              AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondaryOf(context))),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildMenuButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        children: [
          _buildPlayButton(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildSecondaryButton('Reset', Icons.refresh_rounded, _confirmReset)),
              const SizedBox(width: 14),
              Expanded(child: _buildSecondaryButton('Settings', Icons.settings_rounded, _openSettings)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 6,
          shadowColor: AppColors.primary.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 30),
            const SizedBox(width: 10),
            Text('PLAY STAGE $_lastStage', style: AppTextStyles.button),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, IconData icon, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
          foregroundColor: AppColors.textPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(text,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryOf(context))),
          ],
        ),
      ),
    );
  }
}
