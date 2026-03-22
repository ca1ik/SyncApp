import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Procedural game audio service — generates tonal loops per game theme.
/// Uses AudioPlayer with URL sources for royalty-free background tones.
/// Falls back gracefully if audio is unavailable.
class GameAudioService {
  GameAudioService._();
  static final GameAudioService instance = GameAudioService._();

  AudioPlayer? _bgPlayer;
  AudioPlayer? _sfxPlayer;
  bool _muted = false;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _bgPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
      await _bgPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer!.setVolume(0.3);
      await _sfxPlayer!.setVolume(0.5);
      _initialized = true;
    } catch (e) {
      debugPrint('GameAudioService init failed: $e');
    }
  }

  /// Play a short SFX tone at given frequency for duration ms
  Future<void> playSfx(GameSfx sfx) async {
    if (_muted || !_initialized) return;
    try {
      await _sfxPlayer?.stop();
      await _sfxPlayer?.setVolume(sfx.volume);
      await _sfxPlayer?.play(AssetSource(_sfxAsset(sfx)));
    } catch (e) {
      debugPrint('SFX play failed: $e');
    }
  }

  /// Start ambient background music for a game type
  Future<void> startBgMusic(GameMusicTheme theme) async {
    if (_muted || !_initialized) return;
    try {
      await _bgPlayer?.stop();
      await _bgPlayer?.setVolume(theme.volume);
      await _bgPlayer?.setPlaybackRate(theme.tempo);
      // Use bundled asset tones
      await _bgPlayer?.play(AssetSource(theme.assetPath));
    } catch (e) {
      debugPrint('BG music failed: $e');
    }
  }

  Future<void> stopBgMusic() async {
    try {
      await _bgPlayer?.stop();
    } catch (e) {
      debugPrint('Stop BG music failed: $e');
    }
  }

  Future<void> fadeOutBgMusic() async {
    if (!_initialized || _bgPlayer == null) return;
    try {
      for (double v = 0.3; v > 0; v -= 0.05) {
        await _bgPlayer!.setVolume(v.clamp(0.0, 1.0));
        await Future.delayed(const Duration(milliseconds: 80));
      }
      await _bgPlayer!.stop();
    } catch (e) {
      debugPrint('Fade out failed: $e');
    }
  }

  void toggleMute() {
    _muted = !_muted;
    if (_muted) {
      _bgPlayer?.setVolume(0);
      _sfxPlayer?.setVolume(0);
    } else {
      _bgPlayer?.setVolume(0.3);
      _sfxPlayer?.setVolume(0.5);
    }
  }

  bool get isMuted => _muted;

  Future<void> dispose() async {
    await _bgPlayer?.dispose();
    await _sfxPlayer?.dispose();
    _initialized = false;
  }

  String _sfxAsset(GameSfx sfx) {
    switch (sfx) {
      case GameSfx.hit:
        return 'audio/sfx_hit.wav';
      case GameSfx.score:
        return 'audio/sfx_score.wav';
      case GameSfx.explosion:
        return 'audio/sfx_explosion.wav';
      case GameSfx.countdown:
        return 'audio/sfx_countdown.wav';
      case GameSfx.victory:
        return 'audio/sfx_victory.wav';
      case GameSfx.defeat:
        return 'audio/sfx_defeat.wav';
      case GameSfx.pop:
        return 'audio/sfx_pop.wav';
      case GameSfx.whoosh:
        return 'audio/sfx_whoosh.wav';
      case GameSfx.powerUp:
        return 'audio/sfx_powerup.wav';
      case GameSfx.tap:
        return 'audio/sfx_tap.wav';
    }
  }
}

enum GameSfx {
  hit(frequency: 200, durationMs: 150, volume: 0.6),
  score(frequency: 800, durationMs: 200, volume: 0.5),
  explosion(frequency: 80, durationMs: 400, volume: 0.7),
  countdown(frequency: 440, durationMs: 300, volume: 0.4),
  victory(frequency: 1000, durationMs: 500, volume: 0.6),
  defeat(frequency: 150, durationMs: 600, volume: 0.5),
  pop(frequency: 600, durationMs: 100, volume: 0.4),
  whoosh(frequency: 300, durationMs: 200, volume: 0.3),
  powerUp(frequency: 1200, durationMs: 250, volume: 0.5),
  tap(frequency: 500, durationMs: 80, volume: 0.3);

  const GameSfx({
    required this.frequency,
    required this.durationMs,
    required this.volume,
  });
  final int frequency;
  final int durationMs;
  final double volume;
}

enum GameMusicTheme {
  // Each theme has a mood, tempo, and asset
  epicBattle(assetPath: 'audio/bgm_epic.wav', volume: 0.25, tempo: 1.0),
  tension(assetPath: 'audio/bgm_tension.wav', volume: 0.20, tempo: 1.1),
  funPlayful(assetPath: 'audio/bgm_fun.wav', volume: 0.25, tempo: 1.0),
  mysteryDeep(assetPath: 'audio/bgm_mystery.wav', volume: 0.20, tempo: 0.9),
  speedRush(assetPath: 'audio/bgm_speed.wav', volume: 0.25, tempo: 1.2),
  rhythm(assetPath: 'audio/bgm_rhythm.wav', volume: 0.30, tempo: 1.0),
  space(assetPath: 'audio/bgm_space.wav', volume: 0.20, tempo: 0.8),
  nature(assetPath: 'audio/bgm_nature.wav', volume: 0.20, tempo: 0.9),
  horror(assetPath: 'audio/bgm_horror.wav', volume: 0.15, tempo: 0.85),
  celebration(assetPath: 'audio/bgm_celebration.wav', volume: 0.30, tempo: 1.0);

  const GameMusicTheme({
    required this.assetPath,
    required this.volume,
    required this.tempo,
  });
  final String assetPath;
  final double volume;
  final double tempo;
}
