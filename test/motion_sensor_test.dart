import 'package:flutter_test/flutter_test.dart';
import 'package:physics_todo/services/motion_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';

final _t0 = DateTime(2026);

AccelerometerEvent _accel(double x, double y) => AccelerometerEvent(x, y, 0, _t0);

void main() {
  group('tilt', () {
    test('first reading primes the filter, later ones are smoothed', () {
      var calls = 0;
      final m = MotionSensor(onTilt: () => calls++);
      m.onAccel(_accel(9.81, 0));
      expect(m.tiltX, closeTo(-1, 1e-9), reason: 'no slow ramp from zero on start');
      expect(m.tiltY, 0);

      m.onAccel(_accel(0, 0));
      expect(m.tiltX, closeTo(-0.92, 1e-9), reason: 'low-pass moves only 8% per reading');
      expect(calls, 2);
    });

    test('tilt is clamped to -1..1', () {
      final m = MotionSensor()..onAccel(_accel(-30, 30));
      expect((m.tiltX, m.tiltY), (1.0, 1.0));
    });
  });

  group('shake', () {
    late int clock;
    late int shakes;
    late MotionSensor m;

    setUp(() {
      clock = 10000;
      shakes = 0;
      m = MotionSensor(onShake: () => shakes++)..now = () => clock;
    });

    void jolt({int after = 200, double strength = 20}) {
      clock += after;
      m.onUser(UserAccelerometerEvent(strength, 0, 0, _t0));
    }

    test('three strong jolts within 0.9 s shake once', () {
      jolt();
      jolt();
      expect(shakes, 0);
      jolt();
      expect(shakes, 1);
    });

    test('weak, too-close or too-slow jolts do not count', () {
      jolt(strength: 14);
      jolt(strength: 14);
      jolt(strength: 14);
      expect(shakes, 0, reason: 'below the 15 m/s² threshold');

      jolt();
      jolt(after: 50);
      jolt(after: 50);
      expect(shakes, 0, reason: 'one bump read twice is not two jolts');

      clock += 2000;
      jolt(after: 500);
      jolt(after: 500);
      expect(shakes, 0, reason: 'spread over more than 0.9 s');
    });

    test('a second shake needs a 1.8 s pause', () {
      for (var i = 0; i < 3; i++) {
        jolt();
      }
      for (var i = 0; i < 3; i++) {
        jolt();
      }
      expect(shakes, 1);

      clock += 2000;
      for (var i = 0; i < 3; i++) {
        jolt();
      }
      expect(shakes, 2);
    });
  });
}
