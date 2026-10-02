import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/todo.dart';
import '../physics/particle.dart';
import '../physics/particle_world.dart';
import '../theme.dart';

class _Glyph {
  _Glyph(this.painter)
      : baseline = painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  final TextPainter painter;
  final double baseline;
}

/// Laid-out single glyphs, reused every frame. Colour fades are quantised
/// into a few steps so the cache stays small.
class GlyphCache {
  final Map<(String, Priority, Color), _Glyph> _map = {};
  TextScaler _scaler = TextScaler.noScaling;
  TextDirection _direction = TextDirection.ltr;

  void configure(TextScaler scaler, TextDirection direction) {
    if (scaler != _scaler || direction != _direction) {
      clear();
      _scaler = scaler;
      _direction = direction;
    }
  }

  _Glyph get(String glyph, Priority priority, Color color) {
    final key = (glyph, priority, color);
    final hit = _map[key];
    if (hit != null) return hit;
    if (_map.length > 1500) clear();
    final painter = TextPainter(
      text: TextSpan(text: glyph, style: taskTextStyle(color: color, priority: priority)),
      textDirection: _direction,
      textScaler: _scaler,
    )..layout();
    return _map[key] = _Glyph(painter);
  }

  void clear() {
    for (final g in _map.values) {
      g.painter.dispose();
    }
    _map.clear();
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter({
    required this.world,
    required this.glyphs,
    required this.ink,
  }) : super(repaint: world);

  final ParticleWorld world;
  final GlyphCache glyphs;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    for (final g in world.groups) {
      final t = (g.colorT * 6).round() / 6;
      final color = Color.lerp(ink, g.dayColor, t) ?? ink;
      for (final p in g.particles) {
        final glyph = glyphs.get(p.glyph, g.priority, color);
        canvas
          ..save()
          ..translate(p.cx, p.cy)
          ..rotate(p.rot);
        glyph.painter.paint(canvas, Offset(-p.w * 0.5, p.h * 0.35 - glyph.baseline));
        canvas.restore();
      }
    }

    if (world.dust.isEmpty) return;
    final paint = Paint();
    for (final d in world.dust) {
      final a = (clampD(d.life / d.maxLife, 0, 1) * 150).round();
      paint.color = d.color.withAlpha(a);
      canvas.drawCircle(Offset(d.x, d.y), d.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter old) =>
      old.world != world || old.glyphs != glyphs || old.ink != ink;
}

/// The glass jar outline the letters settle in.
class JarPainter extends CustomPainter {
  JarPainter({required this.floorY, required this.color, required this.inset});

  final double floorY;
  final Color color;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final bottom = floorY + 7;
    final top = bottom - size.height * 0.34;
    const r = 18.0;
    final path = Path()
      ..moveTo(inset, top)
      ..lineTo(inset, bottom - r)
      ..quadraticBezierTo(inset, bottom, inset + r, bottom)
      ..lineTo(size.width - inset - r, bottom)
      ..quadraticBezierTo(size.width - inset, bottom, size.width - inset, bottom - r)
      ..lineTo(size.width - inset, top);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [color, color.withAlpha(0)],
      ).createShader(Rect.fromLTRB(0, top, size.width, bottom));
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(JarPainter old) =>
      old.floorY != floorY || old.color != color || old.inset != inset;
}

/// Sits above the list. It only claims a touch when a letter in the jar is
/// under the finger; every other touch falls through to the list.
class ParticleLayer extends StatelessWidget {
  const ParticleLayer({
    super.key,
    required this.world,
    required this.glyphs,
    required this.ink,
    required this.onPoke,
  });

  final ParticleWorld world;
  final GlyphCache glyphs;
  final Color ink;
  final VoidCallback onPoke;

  @override
  Widget build(BuildContext context) {
    return _HitGate(
      world: world,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (d) => world.grab(d.localPosition),
        onPanUpdate: (d) => world.dragTo(d.localPosition),
        onPanEnd: (d) => world.release(d.velocity.pixelsPerSecond),
        onPanCancel: world.release,
        onTapUp: (d) {
          world.poke(d.localPosition);
          onPoke();
        },
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: ParticlePainter(world: world, glyphs: glyphs, ink: ink),
          ),
        ),
      ),
    );
  }
}

class _HitGate extends SingleChildRenderObjectWidget {
  const _HitGate({required this.world, super.child});

  final ParticleWorld world;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderHitGate(world);

  @override
  void updateRenderObject(BuildContext context, _RenderHitGate renderObject) {
    renderObject.world = world;
  }
}

class _RenderHitGate extends RenderProxyBox {
  _RenderHitGate(this.world);

  ParticleWorld world;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position) || !world.hitTest(position)) return false;
    return super.hitTest(result, position: position);
  }
}
