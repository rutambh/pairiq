import 'package:flutter/material.dart';
import '../shared/app_colors.dart';

class StageBanner extends StatelessWidget {
  final int currentStage;
  final int totalStages;
  final int score;
  final int highScore;
  final int moves;
  final int stagePairs;

  const StageBanner({
    super.key,
    required this.currentStage,
    required this.totalStages,
    required this.score,
    required this.highScore,
    required this.moves,
    required this.stagePairs,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStage / totalStages;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              _buildStat(context, Icons.flag_rounded, 'Stage $currentStage/$totalStages'),
              const Spacer(),
              _buildStat(context, Icons.touch_app_rounded, '$moves'),
              const SizedBox(width: 12),
              _buildStat(context, Icons.emoji_events_rounded, '$score'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHighestOf(context),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
      ],
    );
  }
}
