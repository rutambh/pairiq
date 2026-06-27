import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared/app_colors.dart';
import 'services/settings_service.dart';
import 'screens/home_screen.dart';

class PairIQApp extends StatefulWidget {
  const PairIQApp({super.key});

  static void Function(ThemeMode)? onThemeChanged;

  @override
  State<PairIQApp> createState() => PairIQAppState();
}

class PairIQAppState extends State<PairIQApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    PairIQApp.onThemeChanged = (mode) {
      if (mounted) setState(() => _themeMode = mode);
    };
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final settings = await SettingsService.getInstance();
    if (mounted) setState(() => _themeMode = settings.themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(_themeMode),
      title: 'Pair IQ',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          tertiary: AppColors.tertiary,
          onPrimary: AppColors.onPrimary,
          onSecondary: AppColors.onSecondary,
          onSurface: AppColors.onSurface,
          onError: AppColors.onError,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        useMaterial3: true,
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: const Color(0xFFF5F5F5),
          error: AppColors.error,
          tertiary: AppColors.tertiary,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF1A1A2E),
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
