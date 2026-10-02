import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../physics/particle.dart' show clampD;

/// Tilt (same low-pass filter and normalisation as the Kotlin MotionSensor)
/// plus shake detection from the gravity-free accelerometer.
class MotionSensor {
  MotionSensor({this.onShake, this.onTilt});

  final VoidCallback? onShake;
  final VoidCallback? onTilt;

  double tiltX = 0;
  double tiltY = 0;

  double _fx = 0;
  double _fy = 0;
  bool _primed = false;

  StreamSubscription<AccelerometerEvent>? _accel;
  StreamSubscription<UserAccelerometerEvent>? _user;

  int _lastPeak = 0;
  int _firstPeak = 0;
  int _peaks = 0;
  int _lastShake = 0;

  @visibleForTesting
  int Function() now = () => DateTime.now().millisecondsSinceEpoch;

  void start() {
    _accel ??= accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(onAccel, onError: (Object _) {});
    _user ??= userAccelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(onUser, onError: (Object _) {});
  }

  void stop() {
    _accel?.cancel();
    _user?.cancel();
    _accel = null;
    _user = null;
  }

  @visibleForTesting
  void onAccel(AccelerometerEvent e) {
    if (!_primed) {
      _fx = e.x;
      _fy = e.y;
      _primed = true;
    }
    _fx += (e.x - _fx) * 0.08;
    _fy += (e.y - _fy) * 0.08;
    tiltX = clampD(-_fx / 9.81, -1, 1);
    tiltY = clampD(_fy / 9.81, -1, 1);
    onTilt?.call();
  }

  /// Three strong jolts within 0.9 s count as a shake.
  @visibleForTesting
  void onUser(UserAccelerometerEvent e) {
    final magnitude = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    if (magnitude < 15) return;

    final now = this.now();
    if (now - _lastPeak < 110) return;
    if (now - _firstPeak > 900) {
      _firstPeak = now;
      _peaks = 0;
    }
    _lastPeak = now;
    _peaks++;

    if (_peaks >= 3 && now - _lastShake > 1800) {
      _lastShake = now;
      _peaks = 0;
      onShake?.call();
    }
  }
}
