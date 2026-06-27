import 'package:audioplayers/audioplayers.dart';
import 'settings_service.dart';

class SoundService {
  static SoundService? _instance;
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _muted = false;
  bool _initialized = false;

  SoundService._();

  static Future<SoundService> getInstance() async {
    if (_instance == null) {
      _instance = SoundService._();
      final settings = await SettingsService.getInstance();
      _instance!._muted = settings.isSoundMuted;
      _instance!._initialized = true;
    }
    return _instance!;
  }

  bool get isMuted => _muted;

  void toggleMute() {
    _muted = !_muted;
    if (_muted) {
      _musicPlayer.pause();
    } else {
      _musicPlayer.resume();
    }
  }

  Future<void> tap() async {
    if (!_initialized || _muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/tap.wav'));
    } catch (_) {}
  }

  Future<void> match() async {
    if (!_initialized || _muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/match.wav'));
    } catch (_) {}
  }

  Future<void> wrong() async {
    if (!_initialized || _muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/wrong.wav'));
    } catch (_) {}
  }

  Future<void> stageComplete() async {
    if (!_initialized || _muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/stage_complete.wav'));
    } catch (_) {}
  }

  Future<void> gameComplete() async {
    if (!_initialized || _muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/game_complete.wav'));
    } catch (_) {}
  }

  Future<void> startMusic() async {
    if (!_initialized || _muted) return;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/background_loop.wav'));
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
