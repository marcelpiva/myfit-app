import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../utils/haptic_utils.dart';

/// Service for playing timer sounds
class TimerSoundService {
  static final TimerSoundService _instance = TimerSoundService._internal();
  factory TimerSoundService() => _instance;
  TimerSoundService._internal();

  AudioPlayer? _player;
  bool _soundEnabled = true;

  /// Initialize the audio player
  Future<void> init() async {
    try {
      _player = AudioPlayer();
      await _player?.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('TimerSoundService: Failed to initialize audio player: $e');
    }
  }

  /// Enable or disable sounds
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Check if sound is enabled
  bool get isSoundEnabled => _soundEnabled;

  /// Play the timer completion sound (when rest time is over)
  Future<void> playTimerComplete() async {
    if (!_soundEnabled) {
      // Always provide haptic feedback as fallback
      HapticUtils.heavyImpact();
      return;
    }

    try {
      // Use a simple beep tone via URL (free sound)
      // In production, use a local asset: AssetSource('sounds/timer_complete.mp3')
      await _player?.play(
        UrlSource(
          'https://actions.google.com/sounds/v1/alarms/beep_short.ogg',
        ),
      );
    } catch (e) {
      debugPrint('TimerSoundService: Failed to play completion sound: $e');
      // Fallback to haptic
      HapticUtils.heavyImpact();
    }
  }

  /// Play a countdown tick (for last 3 seconds)
  Future<void> playCountdownTick() async {
    if (!_soundEnabled) {
      HapticUtils.lightImpact();
      return;
    }

    try {
      await _player?.play(
        UrlSource(
          'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg',
        ),
      );
    } catch (e) {
      debugPrint('TimerSoundService: Failed to play tick sound: $e');
      HapticUtils.lightImpact();
    }
  }

  /// Play a warning sound (e.g., when 10 seconds remaining)
  Future<void> playWarning() async {
    if (!_soundEnabled) {
      HapticUtils.mediumImpact();
      return;
    }

    try {
      await _player?.play(
        UrlSource(
          'https://actions.google.com/sounds/v1/alarms/dosimeter_alarm.ogg',
        ),
      );
    } catch (e) {
      debugPrint('TimerSoundService: Failed to play warning sound: $e');
      HapticUtils.mediumImpact();
    }
  }

  /// Stop any currently playing sound
  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (e) {
      debugPrint('TimerSoundService: Failed to stop sound: $e');
    }
  }

  /// Dispose the audio player
  Future<void> dispose() async {
    try {
      await _player?.dispose();
      _player = null;
    } catch (e) {
      debugPrint('TimerSoundService: Failed to dispose: $e');
    }
  }
}
