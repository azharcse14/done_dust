import 'dart:math' as math;
import 'dart:ui' show Color;

import '../models/todo.dart';

double clampD(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

/// Lifecycle of one task's letters.
enum Phase {
  /// A short moment right after checking: letters lift off the row.
  floating,

  /// In the jar, simulated with gravity and collisions.
  falling,

  /// In the jar and asleep (nothing moving).
  resting,

  /// Flying back to the row after an undo.
  returning,

  /// Carried off-screen by wind after a swipe-to-delete.
  blowing,

  /// Thrown out of the top of the jar by a shake (archive).
  ejecting,
}

/// Physical behaviour of a task's letters, chosen by its priority.
class ParticleMaterial {
  const ParticleMaterial({
    required this.mass,
    required this.restitution,
    required this.friction,
    required this.floorBounce,
  });

  final double mass;
  final double restitution;
  final double friction;
  final double floorBounce;

  double get invMass => 1 / mass;

  /// Low priority: light and bouncy, like rubber.
  static const feather = ParticleMaterial(
    mass: 0.6,
    restitution: 0.38,
    friction: 0.25,
    floorBounce: 0.40,
  );

  /// Normal priority: the original inelastic sand.
  static const sand = ParticleMaterial(
    mass: 1.0,
    restitution: 0.12,
    friction: 0.35,
    floorBounce: 0.15,
  );

  /// High priority: heavy stone that shoves lighter letters aside.
  static const stone = ParticleMaterial(
    mass: 2.6,
    restitution: 0.04,
    friction: 0.50,
    floorBounce: 0.05,
  );

  static ParticleMaterial of(Priority priority) => switch (priority) {
        Priority.low => feather,
        Priority.normal => sand,
        Priority.high => stone,
      };
}

/// Exact on-screen position of one grapheme of a task's text.
class CharAnchor {
  const CharAnchor({
    required this.glyph,
    required this.index,
    required this.x,
    required this.baselineY,
    required this.width,
    required this.height,
  });

  final String glyph;

  /// Grapheme index inside the task text. Used to fly back to the right slot.
  final int index;
  final double x;
  final double baselineY;
  final double width;
  final double height;
}

class Particle {
  Particle({
    required this.glyph,
    required this.index,
    required this.x,
    required this.y,
    required double width,
    required double height,
    required this.material,
    required this.tint,
  })  : w = math.max(width, 1.0),
        h = height,
        returnX = x,
        returnY = y,
        radius = clampD(math.max(math.max(width, 1.0), height) * 0.45, 3.6, 10.2);

  final String glyph;
  final int index;
  final double w;
  final double h;
  final double radius;
  final ParticleMaterial material;
  final Color tint;

  /// Left edge and text baseline, like the original Compose version.
  double x;
  double y;
  double vx = 0;
  double vy = 0;
  double rot = 0;
  double av = 0;
  double returnX;
  double returnY;

  /// Seconds to wait before wind picks this letter up (blowing phase).
  double delay = 0;

  double get cx => x + w * 0.5;
  double get cy => y - h * 0.35;

  void setCenter(double ncx, double ncy) {
    x = ncx - w * 0.5;
    y = ncy + h * 0.35;
  }
}

/// All letters of one task.
class TaskParticles {
  TaskParticles({
    required this.taskId,
    required this.priority,
    required this.dayColor,
    required this.particles,
    this.phase = Phase.floating,
    this.colorT = 0,
  });

  final int taskId;
  final Priority priority;
  final Color dayColor;
  final List<Particle> particles;
  Phase phase;
  double elapsed = 0;
  double windDir = 1;

  /// 0 = ink colour of an open task, 1 = the weekday sediment colour.
  double colorT;

  bool get inJar => phase == Phase.falling || phase == Phase.resting;
}

class Dust {
  Dust({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.size,
    required this.color,
  }) : maxLife = life;

  double x;
  double y;
  double vx;
  double vy;
  double life;
  final double maxLife;
  final double size;
  final Color color;
}
