import 'dart:math' as math;
import 'dart:ui' show Color, Offset, Size;

import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import 'particle.dart';
import 'spatial_grid.dart';

/// All constants are in Flutter logical pixels. The original Kotlin engine
/// worked in physical pixels, so its values were divided by ~2.75
/// (a typical xxhdpi density) to keep the same feel.
class _K {
  static const gravity = 800.0;
  static const tiltForceX = 510.0;
  static const tiltForceY = 180.0;
  static const subSteps = 8;
  static const floatDuration = 0.12;
  static const wallInset = 10.0;
  static const angularCoupling = 0.011;
  static const sleepSpeedSq = 36.0; // below 6 px/s counts as calm
  static const sleepAfter = 0.6; // seconds of calm before sleeping
  static const tiltWake = 0.06;
}

class ParticleWorld extends ChangeNotifier {
  ParticleWorld({int seed = 7}) : _rand = math.Random(seed);

  final math.Random _rand;
  final Map<int, TaskParticles> _groups = {};
  final List<Particle> _jar = [];
  final List<Dust> dust = [];
  final SpatialGrid _grid = SpatialGrid();

  /// Bumped whenever a task gains or loses its letters, so rows know
  /// whether to hide their text. Cheaper than listening to every frame.
  final ValueNotifier<int> membership = ValueNotifier(0);

  /// Called when a group leaves the world (returned home, blown away, ejected).
  void Function(int taskId, Phase lastPhase)? onGroupGone;

  /// Called when the jar goes to sleep; a good moment to save positions.
  VoidCallback? onSettled;

  /// Called whenever something needs the frame ticker running again.
  VoidCallback? onActivity;

  Size size = Size.zero;
  double floorInset = 24;
  double tiltX = 0;
  double tiltY = 0;

  /// Strongest impact speed since the screen last read it (px/s).
  double peakImpact = 0;

  bool _asleep = false;
  double _calm = 0;
  double _forcedAwake = 0;
  double _sleepTiltX = 0;
  double _sleepTiltY = 0;

  Particle? _grabbed;
  Offset _grabTarget = Offset.zero;
  Offset _grabOffset = Offset.zero;

  double get floorY => size.height - floorInset;
  double get left => _K.wallInset;
  double get right => size.width - _K.wallInset;

  Iterable<TaskParticles> get groups => _groups.values;
  bool has(int taskId) => _groups.containsKey(taskId);
  TaskParticles? groupOf(int taskId) => _groups[taskId];

  /// True when nothing would change on screen: the ticker can stop.
  bool get isIdle {
    if (dust.isNotEmpty || _grabbed != null || _forcedAwake > 0) return false;
    for (final g in _groups.values) {
      if (!g.inJar || g.colorT < 1) return false;
    }
    return _asleep || _groups.isEmpty;
  }

  /// Whether a tilt change should wake a sleeping jar.
  bool tiltWouldWake(double tx, double ty) =>
      _asleep &&
      ((tx - _sleepTiltX).abs() > _K.tiltWake ||
          (ty - _sleepTiltY).abs() > _K.tiltWake);

  void wake([double seconds = 0]) {
    _asleep = false;
    _calm = 0;
    if (seconds > _forcedAwake) _forcedAwake = seconds;
    onActivity?.call();
  }

  void _changedMembership() {
    membership.value++;
    wake();
  }

  // ---------------------------------------------------------------------------
  // Creating and steering groups
  // ---------------------------------------------------------------------------

  /// Task checked: its letters break apart and drop into the jar.
  void complete({
    required int taskId,
    required List<CharAnchor> anchors,
    required Priority priority,
    required Color dayColor,
  }) {
    final existing = _groups[taskId];
    if (existing != null) {
      // Re-checked while letters were still flying home.
      existing.phase = Phase.floating;
      existing.elapsed = 0;
      for (final p in existing.particles) {
        p.vx *= 0.25;
        p.vy = -7;
        p.av *= 0.4;
      }
      wake();
      return;
    }

    final random = math.Random(taskId);
    final material = ParticleMaterial.of(priority);
    final particles = <Particle>[];
    for (final a in anchors) {
      if (a.glyph.trim().isEmpty) continue;
      final p = Particle(
        glyph: a.glyph,
        index: a.index,
        x: a.x,
        y: a.baselineY,
        width: a.width,
        height: math.max(a.height, 12.0),
        material: material,
        tint: dayColor,
      );
      p.vx = (random.nextDouble() - 0.5) * 36;
      p.vy = -7 - random.nextDouble() * 22;
      p.av = (random.nextDouble() - 0.5) * 3;
      p.rot = (random.nextDouble() - 0.5) * 0.08;
      particles.add(p);
    }
    if (particles.isEmpty) return;

    _groups[taskId] = TaskParticles(
      taskId: taskId,
      priority: priority,
      dayColor: dayColor,
      particles: particles,
    );
    _changedMembership();
  }

  /// Task unchecked: letters fly back. Targets are refreshed every frame
  /// via [updateReturnTargets] so they follow the row while scrolling.
  void startReturn(int taskId) {
    final g = _groups[taskId];
    if (g == null) return;
    if (_grabbed != null && g.particles.contains(_grabbed)) _grabbed = null;
    g.phase = Phase.returning;
    g.elapsed = 0;
    wake();
  }

  void updateReturnTargets(int taskId, List<CharAnchor> anchors) {
    final g = _groups[taskId];
    if (g == null || g.phase != Phase.returning) return;
    for (final p in g.particles) {
      if (p.index < anchors.length) {
        final a = anchors[p.index];
        p.returnX = a.x;
        p.returnY = a.baselineY;
      }
    }
  }

  /// Swipe-to-delete. If the task's letters are already in the jar they are
  /// blown out of it; otherwise new letters are created from [anchors].
  void blowAway({
    required int taskId,
    required double direction,
    double velocity = 0,
    List<CharAnchor>? anchors,
    Priority priority = Priority.normal,
    Color? color,
  }) {
    var g = _groups[taskId];
    if (g == null) {
      if (anchors == null || anchors.isEmpty) return;
      final material = ParticleMaterial.of(priority);
      final particles = <Particle>[
        for (final a in anchors)
          if (a.glyph.trim().isNotEmpty)
            Particle(
              glyph: a.glyph,
              index: a.index,
              x: a.x,
              y: a.baselineY,
              width: a.width,
              height: math.max(a.height, 12.0),
              material: material,
              tint: color ?? const Color(0xFF888888),
            ),
      ];
      if (particles.isEmpty) return;
      g = TaskParticles(
        taskId: taskId,
        priority: priority,
        dayColor: color ?? const Color(0xFF888888),
        particles: particles,
      );
      _groups[taskId] = g;
    }
    if (_grabbed != null && g.particles.contains(_grabbed)) _grabbed = null;

    final dir = direction >= 0 ? 1.0 : -1.0;
    g.phase = Phase.blowing;
    g.elapsed = 0;
    g.windDir = dir;

    // The letters nearest the wind's exit leave first.
    final ordered = [...g.particles]
      ..sort((a, b) => dir > 0 ? b.x.compareTo(a.x) : a.x.compareTo(b.x));
    for (var i = 0; i < ordered.length; i++) {
      ordered[i].delay = i * 0.018;
      // Carry the swipe's own speed into the letters.
      if (velocity.abs() > ordered[i].vx.abs()) ordered[i].vx = clampD(velocity, -1500, 1500) * 0.5;
    }
    _changedMembership();
  }

  /// Shake: the letters of the given (finished) tasks are thrown out of the
  /// top of the jar, including ones still on their way down.
  List<int> ejectJar(Set<int> taskIds) {
    final ids = <int>[];
    for (final g in _groups.values) {
      final leaving = g.inJar || g.phase == Phase.floating;
      if (!leaving || !taskIds.contains(g.taskId)) continue;
      ids.add(g.taskId);
      g.phase = Phase.ejecting;
      g.elapsed = 0;
      for (final p in g.particles) {
        p.vx = (_rand.nextDouble() - 0.5) * 700;
        p.vy = -500 - _rand.nextDouble() * 700;
        p.av = (_rand.nextDouble() - 0.5) * 12;
      }
    }
    _grabbed = null;
    if (ids.isNotEmpty) _changedMembership();
    return ids;
  }

  /// Pour letters in from above the screen (archive undo, or restoring a
  /// pile that could not be saved). Only width and height of [glyphs] are used.
  void pourIn({
    required int taskId,
    required List<CharAnchor> glyphs,
    required Priority priority,
    required Color dayColor,
  }) {
    if (size.isEmpty) return;
    final existing = _groups[taskId];
    if (existing != null) {
      // Still on its way out (undo right after a shake or delete): replace.
      if (existing.phase != Phase.ejecting && existing.phase != Phase.blowing) return;
      _groups.remove(taskId);
    }
    final material = ParticleMaterial.of(priority);
    final particles = <Particle>[];
    for (final a in glyphs) {
      if (a.glyph.trim().isEmpty) continue;
      final x = left + _rand.nextDouble() * math.max(right - left - a.width, 1.0);
      final p = Particle(
        glyph: a.glyph,
        index: a.index,
        x: x,
        y: -20 - _rand.nextDouble() * size.height * 0.4,
        width: a.width,
        height: math.max(a.height, 12.0),
        material: material,
        tint: dayColor,
      );
      p.av = (_rand.nextDouble() - 0.5) * 4;
      particles.add(p);
    }
    if (particles.isEmpty) return;
    _groups[taskId] = TaskParticles(
      taskId: taskId,
      priority: priority,
      dayColor: dayColor,
      particles: particles,
      phase: Phase.falling,
      colorT: 1,
    );
    _changedMembership();
  }

  /// Instantly remove a task's letters (e.g. the task no longer exists).
  void remove(int taskId) {
    final g = _groups.remove(taskId);
    if (g == null) return;
    if (_grabbed != null && g.particles.contains(_grabbed)) _grabbed = null;
    _changedMembership();
  }

  // ---------------------------------------------------------------------------
  // Touch
  // ---------------------------------------------------------------------------

  Particle? _nearestInJar(Offset pos) {
    Particle? best;
    var bestD = double.infinity;
    for (final g in _groups.values) {
      if (!g.inJar) continue;
      for (final p in g.particles) {
        final dx = p.cx - pos.dx;
        final dy = p.cy - pos.dy;
        final d = dx * dx + dy * dy;
        final reach = math.max(p.radius * 1.6, 16.0);
        if (d < reach * reach && d < bestD) {
          bestD = d;
          best = p;
        }
      }
    }
    return best;
  }

  bool hitTest(Offset pos) => _nearestInJar(pos) != null;

  bool grab(Offset pos) {
    final p = _nearestInJar(pos);
    if (p == null) return false;
    _grabbed = p;
    _grabOffset = Offset(p.cx, p.cy) - pos;
    _grabTarget = Offset(p.cx, p.cy);
    wake();
    return true;
  }

  void dragTo(Offset pos) {
    if (_grabbed == null) return;
    _grabTarget = pos + _grabOffset;
    wake();
  }

  void release([Offset velocity = Offset.zero]) {
    final p = _grabbed;
    if (p == null) return;
    p.vx = clampD(velocity.dx, -1800, 1800) * 0.8;
    p.vy = clampD(velocity.dy, -1800, 1800) * 0.8;
    p.av += (_rand.nextDouble() - 0.5) * 4;
    _grabbed = null;
    wake(0.3);
  }

  /// Tap on the pile: a small explosion that knocks nearby letters around.
  void poke(Offset pos) {
    const reach = 80.0;
    var touched = false;
    for (final p in _jar) {
      final dx = p.cx - pos.dx;
      final dy = p.cy - pos.dy;
      final d = math.sqrt(dx * dx + dy * dy);
      if (d > reach) continue;
      touched = true;
      final s = 1 - d / reach;
      final nx = d < 0.01 ? 0.0 : dx / d;
      final ny = d < 0.01 ? -1.0 : dy / d;
      p.vx += nx * 420 * s;
      p.vy += ny * 420 * s - 260 * s;
      p.av += (_rand.nextDouble() - 0.5) * 6 * s;
    }
    if (touched) {
      _spawnDust(pos.dx, pos.dy, const Color(0xFF9AA5AD), 6, 160);
      wake(0.3);
    }
  }

  // ---------------------------------------------------------------------------
  // Saving and restoring the pile
  // ---------------------------------------------------------------------------

  /// Positions are stored relative to the jar (x as a fraction of width,
  /// y as distance above the floor) so the pile survives a different
  /// screen size or orientation.
  Map<String, dynamic> snapshot() {
    final groups = <String, dynamic>{};
    for (final g in _groups.values) {
      if (!g.inJar || size.isEmpty) continue;
      groups['${g.taskId}'] = [
        for (final p in g.particles)
          [
            p.index,
            p.glyph,
            _round(p.w),
            _round(p.h),
            _round(p.cx / size.width, 4),
            _round(floorY - p.y),
            _round(p.rot, 3),
          ],
      ];
    }
    return {'groups': groups};
  }

  /// Returns the ids that could not be restored (caller should pour them).
  Set<int> restore(
    Map<String, dynamic> data,
    Map<int, ({Priority priority, Color color})> tasks,
  ) {
    final missing = tasks.keys.toSet();
    final groups = data['groups'];
    if (groups is! Map || size.isEmpty) return missing;

    for (final entry in groups.entries) {
      final id = int.tryParse('${entry.key}');
      final task = id == null ? null : tasks[id];
      if (id == null || task == null || _groups.containsKey(id)) continue;
      final rows = entry.value;
      if (rows is! List) continue;

      final material = ParticleMaterial.of(task.priority);
      final particles = <Particle>[];
      for (final row in rows) {
        if (row is! List || row.length < 7) continue;
        final w = (row[2] as num).toDouble();
        final p = Particle(
          glyph: row[1] as String,
          index: row[0] as int,
          x: 0,
          y: floorY - (row[5] as num).toDouble(),
          width: w,
          height: (row[3] as num).toDouble(),
          material: material,
          tint: task.color,
        );
        p.x = clampD((row[4] as num).toDouble() * size.width - w / 2, left, right - w);
        p.rot = (row[6] as num).toDouble();
        particles.add(p);
      }
      if (particles.isEmpty) continue;
      _groups[id] = TaskParticles(
        taskId: id,
        priority: task.priority,
        dayColor: task.color,
        particles: particles,
        phase: Phase.falling,
        colorT: 1,
      );
      missing.remove(id);
    }
    _changedMembership();
    wake(1.0); // let any overlaps from a size change resolve
    return missing;
  }

  static double _round(double v, [int digits = 1]) {
    final f = math.pow(10, digits).toDouble();
    return (v * f).roundToDouble() / f;
  }

  // ---------------------------------------------------------------------------
  // Simulation
  // ---------------------------------------------------------------------------

  void step(double dt) {
    if (size.isEmpty) return;
    var moved = false;
    final gone = <TaskParticles>[];

    for (final g in _groups.values) {
      g.elapsed += dt;
      switch (g.phase) {
        case Phase.floating:
          _updateFloating(g, dt);
          if (g.elapsed >= _K.floatDuration) g.phase = Phase.falling;
          g.colorT = math.min(1.0, g.colorT + dt * 2.2);
          moved = true;
        case Phase.falling || Phase.resting:
          if (g.colorT < 1) {
            g.colorT = math.min(1.0, g.colorT + dt * 2.2);
            moved = true;
          }
        case Phase.returning:
          _updateReturning(g, dt);
          g.colorT = math.max(0.0, g.colorT - dt * 3);
          moved = true;
          if (_returnFinished(g)) gone.add(g);
        case Phase.blowing:
          _updateBlowing(g, dt);
          moved = true;
          if (_offScreen(g) || g.elapsed > 4) gone.add(g);
        case Phase.ejecting:
          _updateEjecting(g, dt);
          moved = true;
          if (_offScreen(g) || g.elapsed > 3.5) gone.add(g);
      }
    }

    for (final g in gone) {
      _groups.remove(g.taskId);
      onGroupGone?.call(g.taskId, g.phase);
    }
    if (gone.isNotEmpty) membership.value++;

    _jar.clear();
    for (final g in _groups.values) {
      if (g.inJar) _jar.addAll(g.particles);
    }
    if (_jar.isNotEmpty && _simulateJar(dt)) moved = true;

    if (dust.isNotEmpty) {
      _updateDust(dt);
      moved = true;
    }
    if (_forcedAwake > 0) _forcedAwake -= dt;

    if (moved || gone.isNotEmpty) notifyListeners();
  }

  void _updateFloating(TaskParticles g, double dt) {
    final decay = math.exp(-2.0 * dt);
    for (final p in g.particles) {
      p.vx += tiltX * _K.tiltForceX * dt;
      p.vy += tiltY * _K.tiltForceY * dt;
      p.vx *= decay;
      p.vy *= decay;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.rot += p.av * dt;
    }
  }

  void _updateReturning(TaskParticles g, double dt) {
    final factor = clampD(1 - math.exp(-8.0 * dt), 0, 1);
    for (final p in g.particles) {
      final dx = p.returnX - p.x;
      final dy = p.returnY - p.y;
      final dist = math.sqrt(dx * dx + dy * dy);
      p.x += dx * factor;
      p.y += dy * factor;
      // Keep the tumble while rising, straighten up near home.
      if (dist < 44) {
        final align = clampD(1 - dist / 44, 0, 1);
        p.rot += (0 - p.rot) * clampD(factor * (1 + align * 3), 0, 1);
      } else {
        p.rot *= (1 - 3 * dt);
      }
      p.vx = 0;
      p.vy = 0;
      p.av = 0;
    }
  }

  bool _returnFinished(TaskParticles g) {
    for (final p in g.particles) {
      final dx = p.returnX - p.x;
      final dy = p.returnY - p.y;
      if (dx * dx + dy * dy >= 0.3) return false;
    }
    return true;
  }

  void _updateBlowing(TaskParticles g, double dt) {
    for (final p in g.particles) {
      if (g.elapsed < p.delay) continue;
      final gust = math.sin(g.elapsed * 9 + p.index * 0.7);
      p.vx += g.windDir * 1700 * dt;
      p.vy += (-260 + gust * 520) * dt;
      p.av += g.windDir * 5 * dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.rot += p.av * dt;
    }
  }

  void _updateEjecting(TaskParticles g, double dt) {
    final drag = math.exp(-0.4 * dt);
    for (final p in g.particles) {
      p.vy -= 700 * dt; // sucked upward, out of the jar
      p.vx *= drag;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.rot += p.av * dt;
    }
  }

  bool _offScreen(TaskParticles g) {
    for (final p in g.particles) {
      final inside = p.x > -60 &&
          p.x < size.width + 60 &&
          p.y > -60 &&
          p.y < size.height + 80;
      if (inside) return false;
    }
    return true;
  }

  double _invMass(Particle p) =>
      identical(p, _grabbed) ? 0.15 : p.material.invMass;

  /// Returns true if anything moved this frame.
  bool _simulateJar(double dt) {
    if (_asleep) {
      final tiltChanged = tiltWouldWake(tiltX, tiltY);
      if (!tiltChanged && _grabbed == null && _forcedAwake <= 0) return false;
      _asleep = false;
      _calm = 0;
    }

    final gx = tiltX * _K.tiltForceX;
    final gy = _K.gravity + tiltY * _K.tiltForceY;
    final sub = dt / _K.subSteps;
    final floor = math.max(floorY, 40.0);
    final wallL = left;
    final wallR = right;
    final n = _jar.length;

    var maxR = 4.0;
    for (final p in _jar) {
      if (p.radius > maxR) maxR = p.radius;
    }

    var maxSpeedSq = 0.0;

    for (var s = 0; s < _K.subSteps; s++) {
      // 1. Forces and integration.
      for (final p in _jar) {
        if (identical(p, _grabbed)) {
          p.vx = clampD((_grabTarget.dx - p.cx) * 22, -2200, 2200);
          p.vy = clampD((_grabTarget.dy - p.cy) * 22, -2200, 2200);
        } else {
          p.vx += gx * sub;
          p.vy += gy * sub;
        }
        p.vx *= (1 - 1.2 * sub);
        p.vy *= (1 - 1.2 * sub);
        p.x += p.vx * sub;
        p.y += p.vy * sub;
        p.rot += p.av * sub;
        p.av *= (1 - 12.0 * sub);
      }

      // 2. Letter-letter collisions through the spatial grid.
      _grid.build(_jar, size.width, size.height, maxR * 2);
      _grid.forEachPair(n, _collide);

      // 3. Floor, walls and settling.
      for (final p in _jar) {
        if (p.y > floor) {
          p.y = floor;
          if (p.vy > 0) {
            if (p.vy > 9) {
              if (p.vy > peakImpact) peakImpact = p.vy;
              if (p.vy > 320) _spawnDust(p.cx, floor, p.tint, 3, p.vy * 0.25);
              p.vy = -p.vy * p.material.floorBounce;
            } else {
              p.vy = 0;
            }
          }
          p.vx *= (1 - 25 * sub);
          p.av *= (1 - 25 * sub);
        }

        if (p.x < wallL) {
          p.x = wallL;
          if (p.vx < 0) p.vx = -p.vx * 0.2;
        }
        final maxX = math.max(wallR - p.w, wallL);
        if (p.x > maxX) {
          p.x = maxX;
          if (p.vx > 0) p.vx = -p.vx * 0.2;
        }

        final speedSq = p.vx * p.vx + p.vy * p.vy;
        final ang = p.av.abs();
        if (speedSq < 40 && ang < 1.0) {
          p.vx *= (1 - 20 * sub);
          p.vy *= (1 - 20 * sub);
          p.av *= (1 - 20 * sub);
          p.rot *= (1 - 10 * sub);
          if (speedSq < 0.033 && ang < 0.05) {
            p.vx = 0;
            p.vy = 0;
            p.av = 0;
          }
        }
        if (s == _K.subSteps - 1 && speedSq > maxSpeedSq) maxSpeedSq = speedSq;
      }
    }

    // 4. Sleep once the whole pile has been calm for a moment.
    if (_grabbed == null && _forcedAwake <= 0 && maxSpeedSq < _K.sleepSpeedSq) {
      _calm += dt;
      if (_calm >= _K.sleepAfter) {
        for (final p in _jar) {
          p.vx = 0;
          p.vy = 0;
          p.av = 0;
        }
        for (final g in _groups.values) {
          if (g.phase == Phase.falling) g.phase = Phase.resting;
        }
        _asleep = true;
        _sleepTiltX = tiltX;
        _sleepTiltY = tiltY;
        onSettled?.call();
      }
    } else {
      _calm = 0;
      for (final g in _groups.values) {
        if (g.phase == Phase.resting) g.phase = Phase.falling;
      }
    }
    return true;
  }

  void _collide(int i, int j) {
    final p1 = _jar[i];
    final p2 = _jar[j];
    final c1x = p1.cx, c1y = p1.cy, c2x = p2.cx, c2y = p2.cy;
    var dx = c2x - c1x;
    var dy = c2y - c1y;
    final minDist = p1.radius + p2.radius;
    final distSq = dx * dx + dy * dy;
    if (distSq >= minDist * minDist) return;

    var dist = math.sqrt(distSq);
    if (dist < 0.001) {
      dx = (p1.index + p2.index).isEven ? 0.1 : -0.1;
      dy = -0.1;
      dist = math.sqrt(dx * dx + dy * dy);
    }
    final overlap = minDist - dist;
    var nx = dx / dist;
    var ny = dy / dist;

    // Slide off shoulders so letters form a heap instead of a tower.
    if (nx.abs() < 0.3 && (p1.vy.abs() > 3.6 || p2.vy.abs() > 3.6)) {
      final slip = p1.index.isEven ? 1.0 : -1.0;
      nx += slip * 0.2;
      final len = math.sqrt(nx * nx + ny * ny);
      nx /= len;
      ny /= len;
    }

    final im1 = _invMass(p1);
    final im2 = _invMass(p2);
    final imSum = im1 + im2;

    // Mass-weighted positional correction (0.45 each for equal masses).
    final corr = overlap * 0.9 / imSum;
    p1.setCenter(c1x - nx * corr * im1, c1y - ny * corr * im1);
    p2.setCenter(c2x + nx * corr * im2, c2y + ny * corr * im2);

    final rvx = p2.vx - p1.vx;
    final rvy = p2.vy - p1.vy;
    final van = rvx * nx + rvy * ny;
    if (van >= 0) return;

    if (-van > peakImpact) peakImpact = -van;
    if (-van > 360 && _rand.nextDouble() < 0.3) {
      _spawnDust((c1x + c2x) / 2, (c1y + c2y) / 2, p1.tint, 2, -van * 0.2);
    }

    final e = (p1.material.restitution + p2.material.restitution) * 0.5;
    final jn = -(1 + e) * van / imSum;
    p1.vx -= jn * nx * im1;
    p1.vy -= jn * ny * im1;
    p2.vx += jn * nx * im2;
    p2.vy += jn * ny * im2;

    final tx = -ny;
    final ty = nx;
    final vt = rvx * tx + rvy * ty;
    final mu = (p1.material.friction + p2.material.friction) * 0.5;
    final jt = -vt * mu * 2 / imSum;
    p1.vx -= jt * tx * im1;
    p1.vy -= jt * ty * im1;
    p2.vx += jt * tx * im2;
    p2.vy += jt * ty * im2;
    p1.av = clampD(p1.av - jt * _K.angularCoupling * im1, -3, 3);
    p2.av = clampD(p2.av + jt * _K.angularCoupling * im2, -3, 3);
  }

  void _spawnDust(double x, double y, Color color, int count, double speed) {
    if (dust.length > 180) return;
    for (var k = 0; k < count; k++) {
      final a = -math.pi * (0.1 + _rand.nextDouble() * 0.8);
      final v = speed * (0.4 + _rand.nextDouble() * 0.8);
      dust.add(Dust(
        x: x,
        y: y,
        vx: math.cos(a) * v,
        vy: math.sin(a) * v,
        life: 0.35 + _rand.nextDouble() * 0.35,
        size: 0.8 + _rand.nextDouble() * 1.6,
        color: color,
      ));
    }
  }

  void _updateDust(double dt) {
    final drag = math.exp(-3 * dt);
    for (final d in dust) {
      d.vy += 300 * dt;
      d.vx *= drag;
      d.vy *= drag;
      d.x += d.vx * dt;
      d.y += d.vy * dt;
      d.life -= dt;
    }
    dust.removeWhere((d) => d.life <= 0);
  }

  @override
  void dispose() {
    membership.dispose();
    super.dispose();
  }
}
