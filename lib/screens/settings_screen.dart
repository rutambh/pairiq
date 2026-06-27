import 'package:flutter/material.dart';
import '../shared/app_colors.dart';
import '../shared/app_text_styles.dart';
import '../shared/game_shell.dart';
import '../app.dart';
import '../services/sound_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SoundService? _sound;
  SettingsService? _settings;
  ThemeMode _theme = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _sound = await SoundService.getInstance();
    _settings = await SettingsService.getInstance();
    if (mounted) {
      setState(() => _theme = _settings!.themeMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameShell(
      title: 'Settings',
      onBack: () => Navigator.pop(context),
      isMuted: _sound?.isMuted ?? false,
      onMuteToggle: () {
        _sound?.toggleMute();
        setState(() {});
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final isMuted = _sound?.isMuted ?? false;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Appearance'),
          const SizedBox(height: 12),
          _buildThemeSection(),
          const SizedBox(height: 20),
          _buildSectionHeader('Audio'),
          const SizedBox(height: 12),
          _buildAudioTile(isMuted),
          const SizedBox(height: 20),
          _buildSectionHeader('Game'),
          const SizedBox(height: 12),
          _buildInfoTile(
            Icons.flag_rounded,
            'Stage Range',
            '50 stages (3–7 pairs, 2200–700ms reveal)',
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            Icons.score_rounded,
            'Scoring',
            'Stage pts + pairs bonus, high score tracked',
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            Icons.storage_rounded,
            'Save',
            'Auto-saves after each stage, resumes last stage',
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('About'),
          const SizedBox(height: 12),
          _buildAboutCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(text, style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariantOf(context))),
    );
  }

  Widget _buildThemeSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceContainerHighestOf(context), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconCircle(Icons.palette_outlined),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme', style: AppTextStyles.bodyLg.copyWith(color: AppColors.textPrimaryOf(context))),
                    const SizedBox(height: 2),
                    Text('Personalize your look',
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariantOf(context))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _themeOption('Light', Icons.light_mode, ThemeMode.light)),
                const SizedBox(width: 8),
                Expanded(child: _themeOption('Dark', Icons.dark_mode, ThemeMode.dark)),
                const SizedBox(width: 8),
                Expanded(child: _themeOption('System', Icons.settings_brightness, ThemeMode.system)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(String label, IconData icon, ThemeMode value) {
    final selected = _theme == value;
    return GestureDetector(
      onTap: () {
        setState(() => _theme = value);
        _settings?.setThemeMode(value);
        PairIQApp.onThemeChanged?.call(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceContainerLowOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceContainerHighestOf(context),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.onSurfaceVariantOf(context), size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.onSurfaceVariantOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioTile(bool isMuted) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceContainerHighestOf(context), width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _iconCircle(Icons.music_note_outlined),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sound Effects & Music', style: AppTextStyles.bodyLg.copyWith(color: AppColors.textPrimaryOf(context))),
                const SizedBox(height: 2),
                Text('Game audio and feedback',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariantOf(context))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildToggle(!isMuted, (val) {
            _sound?.toggleMute();
            setState(() {});
          }),
        ],
      ),
    );
  }

  Widget _buildToggle(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.surfaceContainerHighestOf(context),
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerHighestOf(context), width: 1),
      ),
      child: Row(
        children: [
          _iconCircle(icon, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryOf(context))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondaryOf(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerHighestOf(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.psychology_rounded,
                    size: 24, color: AppColors.onPrimary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pair IQ',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryOf(context))),
                  Text('Version 2.0',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondaryOf(context))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '50 stages of progressive memory challenges. '
            'Each stage increases in difficulty with more pairs '
            'and faster reveal times.\n\n'
            'All data is stored locally on your device. '
            'No internet connection required.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryOf(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon, {double size = 44}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(icon, color: AppColors.onPrimary, size: size * 0.5),
    );
  }
}
