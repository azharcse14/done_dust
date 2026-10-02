import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../physics/particle.dart';

/// Builds one [CharAnchor] per grapheme cluster (not per UTF-16 unit), so
/// Bangla and emoji break into whole, correctly shaped pieces.
/// [origin] is the painter's top-left in the particle layer's coordinates.
List<CharAnchor> anchorsFromPainter(TextPainter painter, String text, Offset origin) {
  final lines = painter.computeLineMetrics();
  final out = <CharAnchor>[];
  var offset = 0;
  var index = 0;
  var lastRight = 0.0;
  var lastBaseline = lines.isEmpty ? painter.height : lines.first.baseline;

  for (final glyph in text.characters) {
    final end = offset + glyph.length;
    final boxes = painter.getBoxesForSelection(
      TextSelection(baseOffset: offset, extentOffset: end),
    );

    if (boxes.isEmpty) {
      // Collapsed (e.g. trailing space at a line break): keep the slot so
      // indices still line up when letters fly home.
      out.add(CharAnchor(
        glyph: glyph,
        index: index,
        x: origin.dx + lastRight,
        baselineY: origin.dy + lastBaseline,
        width: 0,
        height: 0,
      ));
    } else {
      var l = boxes.first.left, t = boxes.first.top;
      var r = boxes.first.right, b = boxes.first.bottom;
      for (final box in boxes.skip(1)) {
        if (box.left < l) l = box.left;
        if (box.top < t) t = box.top;
        if (box.right > r) r = box.right;
        if (box.bottom > b) b = box.bottom;
      }

      final cy = (t + b) / 2;
      var baseline = b;
      var best = double.infinity;
      for (final line in lines) {
        final top = line.baseline - line.ascent;
        final bottom = line.baseline + line.descent;
        final d = cy < top ? top - cy : (cy > bottom ? cy - bottom : 0.0);
        if (d < best) {
          best = d;
          baseline = line.baseline;
        }
      }

      out.add(CharAnchor(
        glyph: glyph,
        index: index,
        x: origin.dx + l,
        baselineY: origin.dy + baseline,
        width: r - l,
        height: b - t,
      ));
      lastRight = r;
      lastBaseline = baseline;
    }

    offset = end;
    index++;
  }
  return out;
}

/// Draws a task's text with its own [TextPainter], so the layout used for
/// painting is exactly the layout the letters break out of.
class TaskText extends StatefulWidget {
  const TaskText({
    super.key,
    required this.text,
    required this.style,
    required this.hidden,
  });

  final String text;
  final TextStyle style;

  /// Hidden (not removed) while its letters are elsewhere, so the row keeps
  /// its exact size and position.
  final bool hidden;

  @override
  State<TaskText> createState() => TaskTextState();
}

class TaskTextState extends State<TaskText> {
  TextPainter? _painter;

  /// Current anchors of every grapheme, relative to [ancestor].
  List<CharAnchor> anchorsIn(RenderBox ancestor) {
    final painter = _painter;
    final box = context.findRenderObject();
    if (painter == null || box is! RenderBox || !box.attached || !box.hasSize) {
      return const [];
    }
    final origin = box.localToGlobal(Offset.zero, ancestor: ancestor);
    return anchorsFromPainter(painter, widget.text, origin);
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: direction,
          textScaler: scaler,
        )..layout(maxWidth: constraints.maxWidth);
        final previous = _painter;
        _painter = painter;
        // The old painter may still be referenced by the previous frame's
        // CustomPainter until this frame paints, so dispose it afterwards.
        if (previous != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
        }
        return CustomPaint(
          size: painter.size,
          painter: _TextPaint(painter, widget.hidden),
        );
      },
    );
  }

  @override
  void dispose() {
    final painter = _painter;
    _painter = null;
    if (painter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => painter.dispose());
    }
    super.dispose();
  }
}

class _TextPaint extends CustomPainter {
  _TextPaint(this.painter, this.hidden);

  final TextPainter painter;
  final bool hidden;

  /// Faint, slightly soft print left behind once the letters have gone,
  /// like the mark a sticker leaves on a wall.
  static final _ghost = Paint()
    ..color = const Color(0x2E000000)
    ..imageFilter = ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5);

  @override
  void paint(Canvas canvas, Size size) {
    if (!hidden) {
      painter.paint(canvas, Offset.zero);
      return;
    }
    canvas.saveLayer(Offset.zero & size, _ghost);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TextPaint old) =>
      old.painter != painter || old.hidden != hidden;
}
