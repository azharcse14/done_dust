import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' hide Priority;

import '../models/todo.dart';
import '../physics/particle.dart';
import '../physics/particle_world.dart';
import '../services/feedback_service.dart';
import '../services/motion_sensor.dart';
import '../state/todo_store.dart';
import '../theme.dart';
import 'archive_sheet.dart';
import 'particle_layer.dart';
import 'task_editor_sheet.dart';
import 'task_text.dart';
import 'todo_tile.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key, required this.store});

  final TodoStore store;

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ParticleWorld _world = ParticleWorld();
  final FeedbackService _feedback = FeedbackService();
  final GlyphCache _glyphs = GlyphCache();
  final GlobalKey _stackKey = GlobalKey();
  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey<TaskTextState>> _textKeys = {};

  late final MotionSensor _sensor = MotionSensor(onShake: _onShake, onTilt: _onTilt);
  late final Ticker _ticker = createTicker(_onTick);

  Duration? _lastTick;
  bool _restored = false;
  Timer? _saveTimer;
  Size _lastSize = Size.zero;

  // Captured during build so non-build code (the ticker) can use them.
  Palette _palette = Palette.light;
  TextScaler _scaler = TextScaler.noScaling;
  TextDirection _direction = TextDirection.ltr;

  TodoStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _world
      ..onActivity = _ensureTicking
      ..onSettled = _scheduleSave
      ..onOverflow = _onOverflow
      ..onGroupGone = (_, phase) {
        if (phase != Phase.returning) _scheduleSave();
      };
    store.addListener(_onStoreChanged);
    _onStoreChanged();
    _sensor.start();
    unawaited(_feedback.init());
    _ensureTicking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    store.removeListener(_onStoreChanged);
    _saveTimer?.cancel();
    _saveNow();
    _ticker.dispose();
    _sensor.stop();
    _feedback.dispose();
    _glyphs.clear();
    _scroll.dispose();
    _world.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sensor.start();
      _ensureTicking();
    } else {
      _saveNow();
      _sensor.stop();
    }
  }

  // ---------------------------------------------------------------------------
  // Frame loop
  // ---------------------------------------------------------------------------

  void _ensureTicking() {
    if (!mounted || _ticker.isActive) return;
    _lastTick = null;
    _ticker.start();
  }

  void _onTilt() {
    if (_world.tiltWouldWake(_sensor.tiltX, _sensor.tiltY)) _ensureTicking();
  }

  RenderBox? get _stackBox {
    final box = _stackKey.currentContext?.findRenderObject();
    return box is RenderBox && box.hasSize ? box : null;
  }

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    final dt = last == null ? 1 / 60 : (elapsed - last).inMicroseconds / 1e6;

    if (!_restored && !_world.size.isEmpty) _restorePile();

    _world
      ..tiltX = _sensor.tiltX
      ..tiltY = _sensor.tiltY;

    // Letters flying home follow their row, even while the list scrolls.
    final stack = _stackBox;
    if (stack != null) {
      for (final g in _world.groups) {
        if (g.phase != Phase.returning) continue;
        final anchors = _textKeys[g.taskId]?.currentState?.anchorsIn(stack);
        if (anchors != null && anchors.isNotEmpty) {
          _world.updateReturnTargets(g.taskId, anchors);
        }
      }
    }

    // Same dt clamp as the original: no explosions after a pause.
    _world.step(clampD(dt, 0.001, 0.032));

    if (_world.peakImpact > 0) {
      _feedback.impact(_world.peakImpact);
      _world.peakImpact = 0;
    }

    // Nothing moving: stop asking for frames (battery).
    if (_world.isIdle) {
      _ticker.stop();
      _lastTick = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Store sync and persistence
  // ---------------------------------------------------------------------------

  void _onStoreChanged() {
    _feedback
      ..soundOn = store.soundOn
      ..hapticsOn = store.hapticsOn;

    // Drop letters whose task no longer exists (unless they are leaving).
    final stale = [
      for (final g in _world.groups)
        if (store.byId(g.taskId) == null &&
            g.phase != Phase.blowing &&
            g.phase != Phase.ejecting)
          g.taskId,
    ];
    for (final id in stale) {
      _world.remove(id);
    }

    final ids = {for (final t in store.todos) t.id};
    _textKeys.removeWhere((id, _) => !ids.contains(id));
  }

  void _restorePile() {
    _restored = true;
    final tasks = <int, ({Priority priority, Color color})>{
      for (final t in store.todos)
        if (t.completed && !_world.has(t.id))
          t.id: (priority: t.priority, color: _palette.strataFor(t.completedAt!)),
    };
    final saved = store.savedPile;
    store.savedPile = null;
    if (tasks.isEmpty) return;

    final missing = saved == null ? tasks.keys.toSet() : _world.restore(saved, tasks);
    for (final id in missing) {
      final t = store.byId(id);
      if (t != null) _pour(t);
    }
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _saveNow);
  }

  void _saveNow() {
    if (_world.size.isEmpty) return;
    unawaited(store.savePile(_world.snapshot()));
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  GlobalKey<TaskTextState> _keyFor(int id) =>
      _textKeys.putIfAbsent(id, () => GlobalKey<TaskTextState>());

  List<CharAnchor> _anchorsFor(int id) {
    final stack = _stackBox;
    if (stack == null) return const [];
    return _textKeys[id]?.currentState?.anchorsIn(stack) ?? const [];
  }

  /// Glyph sizes for a task that has no row on screen.
  List<CharAnchor> _measure(Todo t) {
    final painter = TextPainter(
      text: TextSpan(
        text: t.text,
        style: taskTextStyle(color: _palette.ink, priority: t.priority),
      ),
      textDirection: _direction,
      textScaler: _scaler,
    )..layout(maxWidth: math.max(_world.size.width - 80, 100.0));
    final anchors = anchorsFromPainter(painter, t.text, Offset.zero);
    painter.dispose();
    return anchors;
  }

  void _pour(Todo t) {
    final done = t.completedAt;
    if (done == null) return;
    _world.pourIn(
      taskId: t.id,
      glyphs: _measure(t),
      priority: t.priority,
      dayColor: _palette.strataFor(done),
    );
  }

  void _snack(String message, {VoidCallback? onUndo}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        action: onUndo == null ? null : SnackBarAction(label: 'Undo', onPressed: onUndo),
      ));
  }

  String _jarLabel() {
    final n = store.todos.where((t) => t.completed).length;
    return n == 0 ? 'Empty jar' : 'Jar with letters of $n finished ${n == 1 ? 'task' : 'tasks'}';
  }

  static String _short(String text) =>
      text.characters.length <= 24 ? text : '${text.characters.take(22)}…';

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _toggle(Todo todo) {
    _feedback.check();
    if (!todo.completed) {
      final anchors = _anchorsFor(todo.id);
      if (anchors.isNotEmpty) {
        _world.complete(
          taskId: todo.id,
          anchors: anchors,
          priority: todo.priority,
          dayColor: _palette.strataFor(DateTime.now()),
        );
      }
      store.setCompleted(todo.id, true);
    } else {
      _world.startReturn(todo.id);
      store.setCompleted(todo.id, false);
      _scheduleSave();
    }
  }

  Future<void> _add() async {
    final draft = await showTaskEditor(context);
    if (draft == null || !mounted) return;
    store.add(draft.text, draft.priority);
    if (_scroll.hasClients) {
      unawaited(_scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut));
    }
  }

  Future<void> _edit(Todo todo) async {
    final draft = await showTaskEditor(context, editing: todo);
    if (draft == null || !mounted) return;
    store.edit(todo.id, text: draft.text, priority: draft.priority);
  }

  void _swiped(Todo todo, double direction, double velocity) {
    if (_world.has(todo.id)) {
      _world.blowAway(taskId: todo.id, direction: direction, velocity: velocity);
    } else if (!todo.completed) {
      _world.blowAway(
        taskId: todo.id,
        direction: direction,
        velocity: velocity,
        anchors: _anchorsFor(todo.id),
        priority: todo.priority,
        color: _palette.ink,
      );
    }
    _feedback.whoosh();

    final removed = store.delete(todo.id);
    if (removed == null) return;
    final (task, index) = removed;
    _snack('Deleted “${_short(task.text)}”', onUndo: () {
      _world.remove(task.id);
      store.undoDelete(task, index);
      if (task.completed) _pour(task);
    });
  }

  void _emptyJar() {
    final done = {for (final t in store.todos) if (t.completed) t.id};
    if (done.isEmpty) {
      _snack('Nothing to archive yet. Finish a task first.');
      return;
    }
    _world.ejectJar(done);
    _feedback
      ..heavy()
      ..whoosh();
    final moved = store.archive(done);
    _snack(
      'Archived ${moved.length} ${moved.length == 1 ? 'task' : 'tasks'}',
      onUndo: () {
        store.unarchive(moved);
        for (final t in moved) {
          _pour(t);
        }
      },
    );
  }

  /// No undo here: pouring the tasks back would only overflow again.
  void _onOverflow(List<int> ids) {
    final moved = store.archive(ids);
    if (moved.isEmpty || !mounted) return;
    _snack('Jar is full. Moved ${moved.length} oldest '
        '${moved.length == 1 ? 'task' : 'tasks'} to the archive.');
  }

  void _onShake() {
    if (!mounted) return;
    // Ignore shakes while a sheet or dialog is open on top of the list.
    if (ModalRoute.of(context)?.isCurrent == false) return;
    if (!store.todos.any((t) => t.completed)) return;
    _emptyJar();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _palette = Palette.of(context);
    _scaler = MediaQuery.textScalerOf(context);
    _direction = Directionality.of(context);
    _glyphs.configure(_scaler, _direction);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      // The keyboard must not squash the jar and launch the pile upward.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            _world
              ..size = size
              ..floorInset = bottomPad + 18;
            if (size != _lastSize) {
              _lastSize = size;
              _world.wake(0.5);
            }
            return Stack(
              key: _stackKey,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: JarPainter(
                      floorY: _world.floorY,
                      color: _palette.inkSoft.withAlpha(110),
                      inset: _world.left,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ListenableBuilder(
                    listenable: store,
                    builder: (context, _) => _content(bottomPad),
                  ),
                ),
                Positioned.fill(
                  // The pile is only paint; tell screen readers what is in it.
                  child: ListenableBuilder(
                    listenable: store,
                    builder: (context, child) => Semantics(
                      container: true,
                      label: _jarLabel(),
                      child: child,
                    ),
                    child: ParticleLayer(
                      world: _world,
                      glyphs: _glyphs,
                      ink: _palette.ink,
                      onPoke: () => _feedback.impact(420),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _content(double bottomPad) {
    final todos = store.todos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          doneToday: store.doneToday(),
          archivedCount: store.archived.length,
          soundOn: store.soundOn,
          hapticsOn: store.hapticsOn,
          onAdd: _add,
          onOpenArchive: () => showArchiveSheet(context, store),
          onEmptyJar: _emptyJar,
          onSound: store.setSound,
          onHaptics: store.setHaptics,
        ),
        Expanded(
          child: todos.isEmpty
              ? _EmptyState(onAdd: _add)
              : ListView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.only(top: 4, bottom: 170 + bottomPad),
                  itemCount: todos.length,
                  itemBuilder: (context, i) {
                    final t = todos[i];
                    return TodoTile(
                      key: ValueKey(t.id),
                      todo: t,
                      textKey: _keyFor(t.id),
                      world: _world,
                      onToggle: () => _toggle(t),
                      onEdit: () => _edit(t),
                      onSwiped: (dir, v) => _swiped(t, dir, v),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

enum _MenuAction { archive, emptyJar, sound, haptics }

class _Header extends StatelessWidget {
  const _Header({
    required this.doneToday,
    required this.archivedCount,
    required this.soundOn,
    required this.hapticsOn,
    required this.onAdd,
    required this.onOpenArchive,
    required this.onEmptyJar,
    required this.onSound,
    required this.onHaptics,
  });

  final int doneToday;
  final int archivedCount;
  final bool soundOn;
  final bool hapticsOn;
  final VoidCallback onAdd;
  final VoidCallback onOpenArchive;
  final VoidCallback onEmptyJar;
  final ValueChanged<bool> onSound;
  final ValueChanged<bool> onHaptics;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My tasks',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.05,
                    letterSpacing: -0.6,
                    fontWeight: FontWeight.w800,
                    fontVariations: const [FontVariation('wght', 780), FontVariation('wdth', 92)],
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      doneToday == 0 ? 'Nothing done today yet' : '$doneToday done today',
                      style: TextStyle(fontSize: 13.5, color: palette.inkSoft),
                    ),
                    const SizedBox(width: 14),
                    _StrataLegend(palette: palette),
                  ],
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'Add task',
            onPressed: onAdd,
            style: IconButton.styleFrom(
              backgroundColor: palette.ink,
              foregroundColor: palette.glass,
            ),
            icon: const Icon(Icons.add_rounded),
          ),
          PopupMenuButton<_MenuAction>(
            tooltip: 'More',
            icon: Icon(Icons.more_vert_rounded, color: palette.ink),
            onSelected: (a) {
              switch (a) {
                case _MenuAction.archive:
                  onOpenArchive();
                case _MenuAction.emptyJar:
                  onEmptyJar();
                case _MenuAction.sound:
                  onSound(!soundOn);
                case _MenuAction.haptics:
                  onHaptics(!hapticsOn);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _MenuAction.archive,
                child: Text(archivedCount == 0 ? 'Archive' : 'Archive ($archivedCount)'),
              ),
              const PopupMenuItem(
                value: _MenuAction.emptyJar,
                child: Text('Empty the jar'),
              ),
              const PopupMenuDivider(),
              CheckedPopupMenuItem(
                value: _MenuAction.sound,
                checked: soundOn,
                child: const Text('Sound'),
              ),
              CheckedPopupMenuItem(
                value: _MenuAction.haptics,
                checked: hapticsOn,
                child: const Text('Vibration'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Which colour each weekday's layer of letters has. Today is ringed.
class _StrataLegend extends StatelessWidget {
  const _StrataLegend({required this.palette});

  final Palette palette;

  static const _initials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1;
    return Semantics(
      label: 'Letters finished on ${_names[today]} settle in this colour',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 7; i++)
            Tooltip(
              message: _names[i],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: palette.strata[i],
                        shape: BoxShape.circle,
                        border: i == today ? Border.all(color: palette.ink, width: 1.6) : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _initials[i],
                      style: TextStyle(
                        fontSize: 9,
                        height: 1,
                        color: i == today ? palette.ink : palette.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Align(
      alignment: const Alignment(0, -0.35),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nothing on the list',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: palette.ink),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a task, then check it off to drop its letters into the jar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.4, color: palette.inkSoft),
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onAdd, child: const Text('Add task')),
          ],
        ),
      ),
    );
  }
}
