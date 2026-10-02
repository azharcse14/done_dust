import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../physics/particle.dart' show clampD;

/// Turns physics impacts into sound and touch. Everything is throttled so a
/// collapsing pile sounds like a handful of pebbles, not a buzz.
class FeedbackService {
  bool soundOn = true;
  bool hapticsOn = true;

  AudioPool? _tick;
  AudioPool? _whoosh;
  int _lastSound = 0;
  int _lastHaptic = 0;

  Future<void> init() async {
    try {
      // Mix with the user's music instead of pausing it.
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
      );
      _tick = await AudioPool.create(
        source: AssetSource('sounds/tick.wav'),
        maxPlayers: 6,
      );
      _whoosh = await AudioPool.create(
        source: AssetSource('sounds/whoosh.wav'),
        maxPlayers: 2,
      );
    } catch (_) {
      // No audio on this device or platform: stay silent.
    }
  }

  /// [speed] is the impact speed in logical px/s.
  void impact(double speed) {
    final now = DateTime.now().millisecondsSinceEpoch;

    final tick = _tick;
    if (soundOn && tick != null && speed > 120 && now - _lastSound > 45) {
      _lastSound = now;
      final volume = clampD((speed - 120) / 700, 0.05, 0.7);
      unawaited(_quietly(() => tick.start(volume: volume)));
    }

    if (hapticsOn && speed > 320 && now - _lastHaptic > 90) {
      _lastHaptic = now;
      unawaited(speed > 750
          ? HapticFeedback.mediumImpact()
          : HapticFeedback.lightImpact());
    }
  }

  void whoosh() {
    final w = _whoosh;
    if (soundOn && w != null) unawaited(_quietly(() => w.start(volume: 0.6)));
  }

  void check() {
    if (hapticsOn) unawaited(HapticFeedback.selectionClick());
  }

  void heavy() {
    if (hapticsOn) unawaited(HapticFeedback.heavyImpact());
  }

  Future<void> _quietly(Future<Object?> Function() play) async {
    try {
      await play();
    } catch (_) {}
  }

  void dispose() {
    unawaited(_tick?.dispose());
    unawaited(_whoosh?.dispose());
  }
}
