import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // --- New design typography scale ---

  static const TextStyle displayHero = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    letterSpacing: 1.0,
    height: 1.17,
  );

  static const TextStyle headlineLg = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.25,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.29,
  );

  static const TextStyle titleMd = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.33,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.56,
  );

  static const TextStyle labelLg = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.2,
  );

  static const TextStyle labelMd = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    letterSpacing: 0.5,
    height: 1.25,
  );

  static const TextStyle statsValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.27,
  );

  // --- Legacy aliases (mapped to new types) ---

  static const TextStyle title = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  static const TextStyle titleGlow = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
    shadows: [
      Shadow(color: AppColors.primary, blurRadius: 20),
    ],
  );

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
    letterSpacing: 1.0,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
  );

  static const TextStyle success = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
    letterSpacing: 1.2,
  );

  static const TextStyle gold = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.tertiary,
    letterSpacing: 1.0,
  );

  static const TextStyle goldLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.tertiary,
    letterSpacing: 1.5,
  );

  static const TextStyle stageLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle scoreLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle highScoreLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.tertiary,
  );

  static const TextStyle toast = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle overlay = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 4.0,
    shadows: [
      Shadow(color: AppColors.primary, blurRadius: 30),
    ],
  );

  static const TextStyle dialogTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle dialogContent = TextStyle(
    fontSize: 15,
    color: AppColors.textSecondary,
    height: 1.5,
  );
}
