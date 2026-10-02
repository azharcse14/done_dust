import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n.dart';
import '../state/todo_store.dart';
import '../theme.dart';

/// Totals and a bar per weekday, in the same colours as the jar's layers.
Future<void> showStatsSheet(BuildContext context, TodoStore store) {
  final palette = Palette.of(context);
  final byDay = store.doneByWeekday();
  final top = byDay.reduce(math.max);
  final streak = store.streak();
  final (thisWeek, lastWeek) = store.weekCounts();
  final best = store.bestStreak;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: palette.surface,
    builder: (context) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.stats,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontVariations: const [FontVariation('wght', 700)],
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.statsLine(store.doneTotal, store.todos.where((t) => !t.completed).length, streak),
            style: TextStyle(color: palette.inkSoft, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            s.weekCompare(thisWeek, lastWeek),
            style: TextStyle(color: palette.inkSoft, fontSize: 14),
          ),
          if (best > 0) ...[
            const SizedBox(height: 4),
            Text(s.bestStreak(best), style: TextStyle(color: palette.inkSoft, fontSize: 14)),
          ],
          if (top > 0) ...[
            const SizedBox(height: 4),
            Text(
              s.bestDay(s.weekdays[byDay.indexOf(top)]),
              style: TextStyle(color: palette.inkSoft, fontSize: 14),
            ),
          ],
          const SizedBox(height: 18),
          Text(s.last12Weeks, style: TextStyle(color: palette.ink, fontSize: 14)),
          const SizedBox(height: 8),
          _Heatmap(counts: store.doneByDate(), palette: palette),
          const SizedBox(height: 18),
          for (var i = 0; i < 7; i++)
            Semantics(
              label: s.finishedOn(s.weekdays[i], byDay[i]),
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(s.weekdaysShort[i],
                          style: TextStyle(color: palette.inkSoft, fontSize: 13)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: top == 0 ? 0 : byDay[i] / top,
                          minHeight: 10,
                          color: palette.strata[i],
                          backgroundColor: palette.hairline.withAlpha(90),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(s.n(byDay[i]),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: palette.ink, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// One square per day for the last 12 weeks, Monday at the top; darker
/// means more tasks finished.
class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.counts, required this.palette});

  final Map<DateTime, int> counts;
  final Palette palette;

  static const _weeks = 12;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final firstMonday = today.subtract(Duration(days: now.weekday - 1 + 7 * (_weeks - 1)));
    final top = counts.values.fold(0, math.max);
    final color = palette.strataFor(now);
    return LayoutBuilder(builder: (context, c) {
      final cell = math.min(18.0, (c.maxWidth - 3 * (_weeks - 1)) / _weeks);
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var w = 0; w < _weeks; w++)
            Column(
              children: [
                for (var d = 0; d < 7; d++)
                  () {
                    final day = firstMonday.add(Duration(days: w * 7 + d));
                    final n = counts[day] ?? 0;
                    final future = day.isAfter(today);
                    return Tooltip(
                      message: s.heatCell(formatDay(day), n),
                      child: Container(
                        width: cell,
                        height: cell,
                        margin: const EdgeInsets.only(bottom: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: future
                              ? Colors.transparent
                              : n == 0
                                  ? palette.hairline.withAlpha(90)
                                  : color.withAlpha(70 + (185 * n / top).round()),
                        ),
                      ),
                    );
                  }(),
              ],
            ),
        ],
      );
    });
  }
}
