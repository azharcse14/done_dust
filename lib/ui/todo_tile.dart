import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../models/todo.dart';
import '../physics/particle_world.dart';
import '../theme.dart';
import 'task_text.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.textKey,
    required this.world,
    required this.onToggle,
    required this.onEdit,
    required this.onSwiped,
  });

  final Todo todo;
  final GlobalKey<TaskTextState> textKey;
  final ParticleWorld world;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  /// [direction] is +1 for a swipe to the right, -1 to the left.
  final void Function(double direction, double velocity) onSwiped;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final now = DateTime.now();
    final checkColor = palette.strataFor(todo.completedAt ?? now);
    final dueIn = todo.completed ? null : todo.daysUntilDue(now);

    final row = SwipeToBlow(
      onSwiped: onSwiped,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onToggle,
          onLongPress: todo.completed ? null : onEdit,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: palette.hairline, width: 0.8)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: _Check(
                      checked: todo.completed,
                      fill: checkColor,
                      mark: palette.glass,
                      outline: palette.ink,
                      label: todo.text,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListenableBuilder(
                          listenable: world.membership,
                          builder: (context, _) => TaskText(
                            key: textKey,
                            text: todo.text,
                            style: taskTextStyle(color: palette.ink, priority: todo.priority),
                            hidden: todo.completed || world.has(todo.id),
                          ),
                        ),
                        if (dueIn != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              dueLabel(dueIn, todo.due!),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: dueIn <= 0 ? FontWeight.w700 : FontWeight.w400,
                                color: dueIn < 0
                                    ? Theme.of(context).colorScheme.error
                                    : palette.inkSoft,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Swiping is the only way to delete; screen readers get it as an action.
    return Semantics(
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Delete'): () => onSwiped(1, 0),
      },
      child: row,
    );
  }
}

/// Fills with the colour the letters will turn into in the jar.
class _Check extends StatelessWidget {
  const _Check({
    required this.checked,
    required this.fill,
    required this.mark,
    required this.outline,
    required this.label,
  });

  final bool checked;
  final Color fill;
  final Color mark;
  final Color outline;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: checked ? fill : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: checked ? fill : outline.withAlpha(150), width: 1.6),
        ),
        child: checked ? Icon(Icons.check_rounded, size: 16, color: mark) : null,
      ),
    );
  }
}

/// Lets a row be dragged sideways. Past a threshold the row reports the
/// swipe (its letters then blow away); otherwise it springs back.
class SwipeToBlow extends StatefulWidget {
  const SwipeToBlow({super.key, required this.child, required this.onSwiped});

  final Widget child;
  final void Function(double direction, double velocity) onSwiped;

  @override
  State<SwipeToBlow> createState() => _SwipeToBlowState();
}

class _SwipeToBlowState extends State<SwipeToBlow> with SingleTickerProviderStateMixin {
  late final AnimationController _back = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..addListener(() => setState(() => _dx = _from * (1 - Curves.easeOut.transform(_back.value))));

  double _dx = 0;
  double _from = 0;

  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  void _end(DragEndDetails details) {
    final width = context.size?.width ?? 1.0;
    final v = details.primaryVelocity ?? 0;
    final farEnough = _dx.abs() > width * 0.28;
    final flung = v.abs() > 900 && v.sign == _dx.sign;
    if (farEnough || flung) {
      widget.onSwiped(_dx >= 0 ? 1.0 : -1.0, v);
      return;
    }
    _from = _dx;
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_) => _back.stop(),
      onHorizontalDragUpdate: (d) => setState(() => _dx += d.delta.dx),
      onHorizontalDragEnd: _end,
      child: Transform.translate(
        offset: Offset(_dx, 0),
        child: widget.child,
      ),
    );
  }
}
