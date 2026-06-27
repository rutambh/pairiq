import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class StorageService {
  static StorageService? _instance;
  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = StorageService._(prefs);
    return _instance!;
  }

  GameState loadGameState() {
    final json = _prefs.getString('game_state');
    if (json == null) return GameState();
    try {
      return GameState.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return GameState();
    }
  }

  Future<void> saveGameState(GameState state) async {
    await _prefs.setString('game_state', jsonEncode(state.toJson()));
  }

  Future<void> resetProgress() async {
    await saveGameState(GameState());
  }
}
