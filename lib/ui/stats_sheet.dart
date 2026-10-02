import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../state/todo_store.dart';
import '../theme.dart';

const _names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

/// Totals and a bar per weekday, in the same colours as the jar's layers.
Future<void> showStatsSheet(BuildContext context, TodoStore store) {
  final palette = Palette.of(context);
  final byDay = store.doneByWeekday();
  final top = byDay.reduce(math.max);
  final streak = store.streak();

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: palette.surface,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stats',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontVariations: const [FontVariation('wght', 700)],
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${store.doneTotal} finished in total · '
            '${store.todos.where((t) => !t.completed).length} open · '
            '${streak == 1 ? '1-day' : '$streak-day'} streak',
            style: TextStyle(color: palette.inkSoft, fontSize: 14),
          ),
          if (top > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Best day: ${_names[byDay.indexOf(top)]}',
              style: TextStyle(color: palette.inkSoft, fontSize: 14),
            ),
          ],
          const SizedBox(height: 18),
          for (var i = 0; i < 7; i++)
            Semantics(
              label: '${_names[i]}: ${byDay[i]} finished',
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(_names[i].substring(0, 3),
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
                      child: Text('${byDay[i]}',
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
