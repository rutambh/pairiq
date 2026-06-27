import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _soundMutedKey = 'sound_muted';
  static const _themeKey = 'theme_mode';

  static SettingsService? _instance;
  final SharedPreferences _prefs;

  SettingsService._(this._prefs);

  static Future<SettingsService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = SettingsService._(prefs);
    return _instance!;
  }

  bool get isSoundMuted => _prefs.getBool(_soundMutedKey) ?? false;

  Future<void> setSoundMuted(bool muted) async {
    await _prefs.setBool(_soundMutedKey, muted);
  }

  ThemeMode get themeMode {
    final value = _prefs.getString(_themeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
      case ThemeMode.dark:
        value = 'dark';
      case ThemeMode.system:
        value = 'system';
    }
    await _prefs.setString(_themeKey, value);
  }
}
