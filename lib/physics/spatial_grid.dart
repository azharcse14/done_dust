import 'dart:typed_data';

import 'particle.dart';

/// Uniform grid for broad-phase collision detection.
///
/// The original engine compared every letter with every other letter
/// (O(n²) per substep). With a cell size of at least two radii, a letter can
/// only touch letters in its own cell or the 8 around it, so each substep is
/// roughly O(n). This keeps hundreds of letters smooth.
class SpatialGrid {
  double _cell = 20;
  int _cols = 1;
  int _rows = 1;

  Int32List _cellStart = Int32List(2);
  Int32List _cursor = Int32List(1);
  Int32List _cellOf = Int32List(0);
  Int32List _sorted = Int32List(0);

  /// One cell of margin on every side so letters slightly outside the
  /// screen still land in a valid cell.
  int _cellIndex(double x, double y) {
    var col = (x / _cell).floor() + 1;
    var row = (y / _cell).floor() + 1;
    if (col < 0) col = 0;
    if (col >= _cols) col = _cols - 1;
    if (row < 0) row = 0;
    if (row >= _rows) row = _rows - 1;
    return row * _cols + col;
  }

  void build(List<Particle> ps, double width, double height, double cellSize) {
    _cell = cellSize < 4 ? 4 : cellSize;
    _cols = (width / _cell).ceil() + 2;
    _rows = (height / _cell).ceil() + 2;
    if (_cols < 1) _cols = 1;
    if (_rows < 1) _rows = 1;

    final cells = _cols * _rows;
    if (_cellStart.length < cells + 1) {
      _cellStart = Int32List(cells + 1);
      _cursor = Int32List(cells);
    } else {
      _cellStart.fillRange(0, cells + 1, 0);
    }

    final n = ps.length;
    if (_cellOf.length < n) {
      _cellOf = Int32List(n * 2);
      _sorted = Int32List(n * 2);
    }

    // Counting sort of particle indices by cell.
    for (var i = 0; i < n; i++) {
      final c = _cellIndex(ps[i].cx, ps[i].cy);
      _cellOf[i] = c;
      _cellStart[c + 1]++;
    }
    for (var c = 0; c < cells; c++) {
      _cellStart[c + 1] += _cellStart[c];
    }
    for (var c = 0; c < cells; c++) {
      _cursor[c] = _cellStart[c];
    }
    for (var i = 0; i < n; i++) {
      final c = _cellOf[i];
      _sorted[_cursor[c]++] = i;
    }
  }

  /// Calls [visit] once for every nearby pair (i < j).
  void forEachPair(int count, void Function(int i, int j) visit) {
    for (var i = 0; i < count; i++) {
      final c = _cellOf[i];
      final row = c ~/ _cols;
      final col = c - row * _cols;
      for (var dr = -1; dr <= 1; dr++) {
        final r = row + dr;
        if (r < 0 || r >= _rows) continue;
        for (var dc = -1; dc <= 1; dc++) {
          final cc = col + dc;
          if (cc < 0 || cc >= _cols) continue;
          final cell = r * _cols + cc;
          final end = _cellStart[cell + 1];
          for (var k = _cellStart[cell]; k < end; k++) {
            final j = _sorted[k];
            if (j > i) visit(i, j);
          }
        }
      }
    }
  }
}
