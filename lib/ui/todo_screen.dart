import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' hide Priority;
import 'package:flutter/services.dart';

import '../l10n.dart';
import '../models/todo.dart';
import '../physics/particle.dart';
import '../physics/particle_world.dart';
import '../services/feedback_service.dart';
import '../services/motion_sensor.dart';
import '../state/todo_store.dart';
import '../theme.dart';
import 'archive_sheet.dart';
import 'particle_layer.dart';
import 'settings_sheet.dart';
import 'stats_sheet.dart';
import 'task_editor_sheet.dart';
import 'task_text.dart';
import 'todo_tile.dart';

enum _Show { all, open, overdue, done }

enum _Sort { manual, priority, due }

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

  /// Rows already shown once; anything else gets an entrance animation.
  final Set<int> _seen = {};

  late final MotionSensor _sensor = MotionSensor(onShake: _onShake, onTilt: _onTilt);
  late final Ticker _ticker = createTicker(_onTick);

  Duration? _lastTick;
  bool _restored = false;
  Timer? _saveTimer;
  Size _lastSize = Size.zero;

  // Find bar: only changes what the list shows, never the store or the jar.
  bool _finding = false;
  String _query = '';
  _Show _show = _Show.all;
  _Sort _sort = _Sort.manual;

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

  int _restoresSeen = 0;

  void _onStoreChanged() {
    // A restored backup has a new set of finished tasks: pour them in.
    if (store.restores != _restoresSeen) {
      _restoresSeen = store.restores;
      _restored = false;
      _ensureTicking();
    }
    _feedback
      ..soundOn = store.soundOn
      ..hapticsOn = store.hapticsOn;

    // Drop letters whose task no longer exists (unless they are leaving).
    final stale = [
      for (final g in _world.groups)
        if (store.byId(g.taskId) == null && g.phase != Phase.blowing && g.phase != Phase.ejecting)
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
        action: onUndo == null ? null : SnackBarAction(label: s.undo, onPressed: onUndo),
      ));
  }

  String _jarLabel() {
    final n = store.todos.where((t) => t.completed).length;
    return n == 0 ? s.emptyJar : s.jarWith(n);
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
      if (store.streakMilestoneJustNow() case final days?) {
        _celebrate(s.milestone(days));
      } else if (store.todos.every((t) => t.completed)) {
        _celebrate(s.allDone);
      } else if (store.reachedGoalJustNow()) {
        _celebrate(s.goalReached(store.dailyGoal));
      }
    } else {
      _world.startReturn(todo.id);
      store.setCompleted(todo.id, false);
      _scheduleSave();
    }
  }

  void _celebrate(String message) {
    _world.celebrate(_palette.strata);
    _feedback.heavy();
    _snack(message);
  }

  Future<void> _add() async {
    final draft = await showTaskEditor(context);
    if (draft == null || !mounted) return;
    // Reversed so a pasted list keeps its order at the top.
    for (final text in draft.texts.reversed) {
      store.add(text, draft.priority,
          due: draft.due,
          note: draft.note,
          pinned: draft.pinned,
          repeat: draft.repeat,
          remindAt: draft.remindAt,
          timing: draft.timing);
    }
    if (draft.texts.length > 1) _snack(s.added(draft.texts.length));
    if (_scroll.hasClients) {
      unawaited(
          _scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut));
    }
  }

  Future<void> _edit(Todo todo) async {
    final draft = await showTaskEditor(context, editing: todo);
    if (draft == null || !mounted) return;
    if (draft.duplicate) {
      store.add(draft.texts.single, draft.priority,
          due: draft.due,
          note: draft.note,
          pinned: draft.pinned,
          repeat: draft.repeat,
          remindAt: draft.remindAt,
          timing: draft.timing);
      _snack(s.duplicated(_short(draft.texts.single)));
    } else {
      store.edit(todo.id,
          text: draft.texts.single,
          priority: draft.priority,
          due: draft.due,
          note: draft.note,
          pinned: draft.pinned,
          repeat: draft.repeat,
          remindAt: draft.remindAt,
          timing: draft.timing);
    }
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
    _snack(s.deleted(_short(task.text)), onUndo: () {
      _world.remove(task.id);
      store.undoDelete(task, index);
      if (task.completed) _pour(task);
    });
  }

  void _emptyJar() {
    final done = {
      for (final t in store.todos)
        if (t.completed) t.id
    };
    if (done.isEmpty) {
      _snack(s.nothingToArchive);
      return;
    }
    _world.ejectJar(done);
    _feedback
      ..heavy()
      ..whoosh();
    final moved = store.archive(done);
    _snack(
      s.archived(moved.length),
      onUndo: () {
        for (final t in store.unarchive(moved)) {
          _pour(t);
        }
      },
    );
  }

  /// No undo here: pouring the tasks back would only overflow again.
  void _onOverflow(List<int> ids) {
    final moved = store.archive(ids);
    if (moved.isEmpty || !mounted) return;
    _snack(s.jarFull(moved.length));
  }

  Future<void> _copyList() async {
    final n = store.todos.length;
    if (n == 0) {
      _snack(s.listEmpty);
      return;
    }
    await Clipboard.setData(ClipboardData(text: store.exportText()));
    if (mounted) _snack(s.copied(n));
  }

  void _toggleFind() => setState(() {
        _finding = !_finding;
        // Closing the bar must not leave tasks silently hidden.
        if (!_finding) {
          _query = '';
          _show = _Show.all;
          _sort = _Sort.manual;
        }
      });

  List<Todo> _visible(List<Todo> todos) {
    final q = _query.toLowerCase();
    final now = DateTime.now();
    // Letters flying home need their row on screen to land on, so a task
    // just unchecked under "Done" stays until they arrive.
    final returning = {
      for (final g in _world.groups)
        if (g.phase == Phase.returning) g.taskId,
    };
    final shown = [
      for (final t in todos)
        if ((q.isEmpty || t.text.toLowerCase().contains(q)) &&
            (returning.contains(t.id) ||
                switch (_show) {
                  _Show.all => true,
                  _Show.open => !t.completed,
                  _Show.overdue => !t.completed && (t.daysUntilDue(now) ?? 0) < 0,
                  _Show.done => t.completed,
                }))
          t,
    ];
    // List.sort is not stable; break ties on the original position.
    final pos = {for (var i = 0; i < shown.length; i++) shown[i].id: i};
    int byPin(Todo a, Todo b) => (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0);
    if (_sort == _Sort.manual) {
      return shown
        ..sort((a, b) {
          final c = byPin(a, b);
          return c != 0 ? c : pos[a.id]!.compareTo(pos[b.id]!);
        });
    }
    int byDue(Todo a, Todo b) => switch ((a.due, b.due)) {
          (null, null) => 0,
          (null, _) => 1,
          (_, null) => -1,
          (final x?, final y?) => x.compareTo(y),
        };
    return shown
      ..sort((a, b) {
        var c = byPin(a, b);
        if (c == 0) {
          c = _sort == _Sort.priority ? b.priority.index.compareTo(a.priority.index) : byDue(a, b);
        }
        return c != 0 ? c : pos[a.id]!.compareTo(pos[b.id]!);
      });
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
      // A faint wash of today's layer colour behind everything.
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-1, -1),
            radius: 1.4,
            colors: [_palette.strataFor(DateTime.now()).withAlpha(46), _palette.glass.withAlpha(0)],
          ),
        ),
        child: SafeArea(
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
                      listenable: Listenable.merge([store, _world.membership]),
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
      ),
    );
  }

  Widget _content(double bottomPad) {
    final all = store.todos;
    final todos = _visible(all);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          doneToday: store.doneToday(),
          streak: store.streak(),
          dailyGoal: store.dailyGoal,
          // With a goal the bar tracks today against it, else the whole list.
          progress: store.dailyGoal > 0
              ? math.min(store.doneToday() / store.dailyGoal, 1.0)
              : all.isEmpty
                  ? null
                  : all.where((t) => t.completed).length / all.length,
          archivedCount: store.archived.length,
          overdueCount: store.todos
              .where((t) => !t.completed && (t.daysUntilDue(DateTime.now()) ?? 0) < 0)
              .length,
          onOverdue: () => setState(() {
            _finding = true;
            _show = _Show.overdue;
          }),
          finding: _finding,
          onAdd: _add,
          onFind: _toggleFind,
          onOpenArchive: () => showArchiveSheet(context, store),
          onStats: () => showStatsSheet(context, store),
          onCopy: _copyList,
          onEmptyJar: _emptyJar,
          onSettings: () => showSettingsSheet(context, store),
        ),
        if (_finding)
          _FindBar(
            show: _show,
            sort: _sort,
            onQuery: (q) => setState(() => _query = q.trim()),
            onShow: (v) => setState(() => _show = v),
            onSort: (v) => setState(() => _sort = v),
          ),
        Expanded(
          child: all.isEmpty
              ? _EmptyState(onAdd: _add)
              : todos.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Text(
                            s.noMatch,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: _palette.inkSoft),
                          ),
                          TextButton(onPressed: _toggleFind, child: Text(s.clearSearch)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsets.only(top: 4, bottom: 170 + bottomPad),
                      itemCount: todos.length,
                      itemBuilder: (context, i) {
                        final t = todos[i];
                        // First launch staggers the rows in; later adds just slide in.
                        final fresh = _seen.add(t.id) && !MediaQuery.disableAnimationsOf(context);
                        return TodoTile(
                          enterDelay: fresh ? Duration(milliseconds: 45 * math.min(i, 10)) : null,
                          key: ValueKey(t.id),
                          todo: t,
                          textKey: _keyFor(t.id),
                          world: _world,
                          onToggle: () => _toggle(t),
                          onEdit: () => _edit(t),
                          onPin: () => store.togglePin(t.id),
                          onTimer: () => store.toggleTimer(t.id),
                          onSwiped: (dir, v) => _swiped(t, dir, v),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

enum _MenuAction { archive, stats, copy, emptyJar, settings }

class _Header extends StatelessWidget {
  const _Header({
    required this.doneToday,
    required this.streak,
    required this.dailyGoal,
    required this.progress,
    required this.archivedCount,
    required this.overdueCount,
    required this.onOverdue,
    required this.finding,
    required this.onAdd,
    required this.onFind,
    required this.onOpenArchive,
    required this.onStats,
    required this.onCopy,
    required this.onEmptyJar,
    required this.onSettings,
  });

  final int doneToday;
  final int streak;
  final int dailyGoal;

  /// Share of the list that is finished; null when the list is empty.
  final double? progress;
  final int archivedCount;
  final int overdueCount;
  final VoidCallback onOverdue;
  final bool finding;
  final VoidCallback onAdd;
  final VoidCallback onFind;
  final VoidCallback onOpenArchive;
  final VoidCallback onStats;
  final VoidCallback onCopy;
  final VoidCallback onEmptyJar;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final summary = [
      if (dailyGoal > 0)
        s.doneOfGoal(doneToday, dailyGoal)
      else
        doneToday == 0 ? s.nothingToday : s.doneToday(doneToday),
      if (streak > 1) s.streak(streak),
    ].join(' · ');
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
                  s.myTasks,
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
                    Flexible(child: _RollingText(summary, palette.inkSoft)),
                    const SizedBox(width: 14),
                    _StrataLegend(palette: palette),
                  ],
                ),
                if (overdueCount > 0) ...[
                  const SizedBox(height: 8),
                  _OverduePill(count: overdueCount, onTap: onOverdue),
                ],
                if (progress case final p?) ...[
                  const SizedBox(height: 10),
                  Semantics(
                    label: dailyGoal > 0
                        ? s.goalPercent((p * 100).round())
                        : s.listPercent((p * 100).round()),
                    excludeSemantics: true,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: p),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 4,
                          color: palette.strataFor(DateTime.now()),
                          backgroundColor: palette.hairline.withAlpha(110),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: finding ? s.closeSearch : s.searchAndSort,
            onPressed: onFind,
            icon:
                Icon(finding ? Icons.search_off_rounded : Icons.search_rounded, color: palette.ink),
          ),
          IconButton.filled(
            tooltip: s.addTask,
            onPressed: onAdd,
            style: IconButton.styleFrom(
              backgroundColor: palette.ink,
              foregroundColor: palette.glass,
            ),
            icon: const Icon(Icons.add_rounded),
          ),
          PopupMenuButton<_MenuAction>(
            tooltip: s.more,
            icon: Icon(Icons.more_vert_rounded, color: palette.ink),
            onSelected: (a) => switch (a) {
              _MenuAction.archive => onOpenArchive(),
              _MenuAction.stats => onStats(),
              _MenuAction.copy => onCopy(),
              _MenuAction.emptyJar => onEmptyJar(),
              _MenuAction.settings => onSettings(),
            },
            itemBuilder: (context) => [
              _item(_MenuAction.archive, Icons.inventory_2_outlined, s.archiveCount(archivedCount)),
              _item(_MenuAction.stats, Icons.bar_chart_rounded, s.stats),
              _item(_MenuAction.copy, Icons.copy_rounded, s.copyList),
              _item(_MenuAction.emptyJar, Icons.archive_outlined, s.emptyTheJar),
              const PopupMenuDivider(),
              _item(_MenuAction.settings, Icons.tune_rounded, s.settings),
            ],
          ),
        ],
      ),
    );
  }
}

PopupMenuItem<_MenuAction> _item(_MenuAction value, IconData icon, String label) => PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 20),
        const SizedBox(width: 14),
        Flexible(child: Text(label))
      ]),
    );

class _OverduePill extends StatelessWidget {
  const _OverduePill({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Material(
      color: error.withAlpha(28),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded, size: 15, color: error),
              const SizedBox(width: 5),
              Text(s.overdueCount(count),
                  style: TextStyle(color: error, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Old text slides up and out as the new one slides in.
class _RollingText extends StatelessWidget {
  const _RollingText(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft, children: [...previous, if (current != null) current]),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(
            begin: Offset(0, child.key == ValueKey(text) ? 0.6 : -0.6),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Text(
        text,
        key: ValueKey(text),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13.5, color: color),
      ),
    );
  }
}

/// Which colour each weekday's layer of letters has. Today is ringed.
class _StrataLegend extends StatelessWidget {
  const _StrataLegend({required this.palette});

  final Palette palette;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1;
    return Semantics(
      label: s.legend(s.weekdays[today]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 7; i++)
            Tooltip(
              message: s.weekdays[i],
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
                      s.weekdayInitials[i],
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

class _FindBar extends StatelessWidget {
  const _FindBar({
    required this.show,
    required this.sort,
    required this.onQuery,
    required this.onShow,
    required this.onSort,
  });

  final _Show show;
  final _Sort sort;
  final ValueChanged<String> onQuery;
  final ValueChanged<_Show> onShow;
  final ValueChanged<_Sort> onSort;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            autofocus: true,
            onChanged: onQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: s.searchTasks,
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              filled: true,
              fillColor: palette.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final (value, label) in [
                        (_Show.all, s.showAll),
                        (_Show.open, s.showOpen),
                        (_Show.overdue, s.showOverdue),
                        (_Show.done, s.showDone),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: show == value,
                            onSelected: (_) => onShow(value),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              DropdownButton<_Sort>(
                value: sort,
                underline: const SizedBox.shrink(),
                onChanged: (v) => onSort(v!),
                items: [
                  DropdownMenuItem(value: _Sort.manual, child: Text(s.sortNewest)),
                  DropdownMenuItem(value: _Sort.priority, child: Text(s.sortPriority)),
                  DropdownMenuItem(value: _Sort.due, child: Text(s.sortDue)),
                ],
              ),
            ],
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
              s.nothingOnList,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: palette.ink),
            ),
            const SizedBox(height: 8),
            Text(
              s.emptyHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.4, color: palette.inkSoft),
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onAdd, child: Text(s.addTask)),
            const SizedBox(height: 14),
            Text(
              s.gestureHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, height: 1.4, color: palette.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
