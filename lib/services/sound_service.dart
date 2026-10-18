import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  bool soundEnabled = true;
  AudioPlayer? _slidePlayer;
  AudioPlayer? _winPlayer;
  bool _initialized = false;

  void _init() {
    if (_initialized) return;
    try {
      _slidePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _winPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _initialized = true;
    } catch (_) {
      // AudioPlayer may not be supported on all desktop setups without audio devices
    }
  }

  Future<void> playSlide() async {
    // Tactile feedback
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    if (!soundEnabled) return;

    _init();
    try {
      if (_slidePlayer != null) {
        await _slidePlayer!.stop();
        await _slidePlayer!.play(AssetSource('sounds/slide.wav'), mode: PlayerMode.lowLatency);
        return;
      }
    } catch (_) {
      // Fallback
    }

    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> playWin() async {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    if (!soundEnabled) return;

    _init();
    try {
      if (_winPlayer != null) {
        await _winPlayer!.stop();
        await _winPlayer!.play(AssetSource('sounds/success.wav'), mode: PlayerMode.lowLatency);
        return;
      }
    } catch (_) {
      // Fallback
    }

    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  void toggleSound() {
    soundEnabled = !soundEnabled;
  }
}
