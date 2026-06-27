import 'package:flutter/material.dart';
import 'app_colors.dart';

class GameShell extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onMuteToggle;
  final bool isMuted;
  final List<Widget>? actions;
  final bool hideTitle;

  const GameShell({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.onMuteToggle,
    this.isMuted = false,
    this.actions,
    this.hideTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ]
                : const [
                    Color(0xFFF0F4FF),
                    Color(0xFFE8F0FE),
                    Color(0xFFDCE8F5),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
      child: Row(
        children: [
          if (onBack != null)
            _IconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
            ),
          if (onBack != null) const SizedBox(width: 8),
          if (!hideTitle)
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryOf(context),
                  letterSpacing: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (hideTitle) const Spacer(),
          ...?actions,
          if (onMuteToggle != null)
            _IconButton(
              icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              onTap: onMuteToggle,
            ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: AppColors.textPrimaryOf(context), size: 24),
      ),
    );
  }
}
