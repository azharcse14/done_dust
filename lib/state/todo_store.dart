import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../l10n.dart';
import '../models/todo.dart';
import '../services/reminders.dart';
import '../services/storage.dart';

class TodoStore extends ChangeNotifier {
  TodoStore(this._storage, [this._reminders]);

  final Storage _storage;
  final Reminders? _reminders;
  List<Todo> _todos = [];
  List<Todo> _archived = [];
  bool loaded = false;
  bool soundOn = true;
  bool hapticsOn = true;
  ThemeMode themeMode = ThemeMode.system;

  /// 'system', 'en' or 'bn'.
  String language = 'system';

  bool remindersOn = false;

  /// The system refused notifications the last time they were switched on.
  bool remindersBlocked = false;

  /// Tasks to finish per day; 0 = no goal.
  int dailyGoal = 0;

  /// Pile snapshot from the last session, consumed once by the screen.
  Map<String, dynamic>? savedPile;

  List<Todo> get todos => List.unmodifiable(_todos);
  List<Todo> get archived => List.unmodifiable(_archived);

  Todo? byId(int id) {
    for (final t in _todos) {
      if (t.id == id) return t;
    }
    return null;
  }

  int doneToday() {
    final now = DateTime.now();
    bool sameDay(DateTime d) => d.year == now.year && d.month == now.month && d.day == now.day;
    var count = 0;
    for (final t in [..._todos, ..._archived]) {
      final c = t.completedAt;
      if (c != null && sameDay(c)) count++;
    }
    return count;
  }

  Iterable<DateTime> get _completions =>
      [..._todos, ..._archived].map((t) => t.completedAt).whereType<DateTime>();

  /// Days in a row with at least one finished task, ending today. A streak
  /// that ended yesterday still counts until today is over.
  int streak([DateTime? now]) {
    final days = {for (final c in _completions) DateTime.utc(c.year, c.month, c.day)};
    final n = now ?? DateTime.now();
    var day = DateTime.utc(n.year, n.month, n.day);
    if (!days.contains(day)) day = day.subtract(const Duration(days: 1));
    var count = 0;
    while (days.contains(day)) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// Finished tasks per weekday, Monday first, across list and archive.
  List<int> doneByWeekday() {
    final counts = List.filled(7, 0);
    for (final c in _completions) {
      counts[c.weekday - 1]++;
    }
    return counts;
  }

  int get doneTotal => _completions.length;

  /// Finished tasks per calendar day (UTC midnight keys), for the heatmap.
  Map<DateTime, int> doneByDate() {
    final counts = <DateTime, int>{};
    for (final c in _completions) {
      final d = DateTime.utc(c.year, c.month, c.day);
      counts[d] = (counts[d] ?? 0) + 1;
    }
    return counts;
  }

  /// Finished this week and last week, weeks starting Monday.
  (int, int) weekCounts([DateTime? now]) {
    final n = now ?? DateTime.now();
    final monday = DateTime.utc(n.year, n.month, n.day - (n.weekday - 1));
    final lastMonday = monday.subtract(const Duration(days: 7));
    var (thisWeek, lastWeek) = (0, 0);
    for (final c in _completions) {
      final d = DateTime.utc(c.year, c.month, c.day);
      if (!d.isBefore(monday)) {
        thisWeek++;
      } else if (!d.isBefore(lastMonday)) {
        lastWeek++;
      }
    }
    return (thisWeek, lastWeek);
  }

  /// Longest run of days in a row seen in the history still on hand.
  int _longestRun() {
    final days = doneByDate().keys.toList()..sort();
    var (best, run) = (0, 0);
    for (var i = 0; i < days.length; i++) {
      run = i > 0 && days[i].difference(days[i - 1]).inDays == 1 ? run + 1 : 1;
      best = math.max(best, run);
    }
    return best;
  }

  int _savedBestStreak = 0;

  /// Kept on disk, so clearing the archive can't shrink the record.
  int get bestStreak => math.max(_savedBestStreak, _longestRun());

  static const streakMilestones = [7, 30, 100, 365];
  DateTime? _milestoneCelebrated;

  /// The streak length when today's finish just reached a milestone, once
  /// per day; otherwise null.
  int? streakMilestoneJustNow() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final run = streak();
    if (!streakMilestones.contains(run) || doneToday() == 0 || _milestoneCelebrated == today) {
      return null;
    }
    _milestoneCelebrated = today;
    return run;
  }

  /// Plain-text checklist of the current list, for the clipboard.
  String exportText() => [
        for (final t in _todos) '- [${t.completed ? 'x' : ' '}] ${t.text}',
      ].join('\n');

  Future<void> load() async {
    final s = await _storage.load();
    _todos = s.firstRun ? _starterTasks() : s.todos;
    _archived = s.archived;
    savedPile = s.pile;
    soundOn = s.soundOn;
    hapticsOn = s.hapticsOn;
    themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == s.theme,
      orElse: () => ThemeMode.system,
    );
    dailyGoal = s.dailyGoal;
    setLanguage(s.language ?? 'system', save: false);
    remindersOn = s.remindersOn;
    _savedBestStreak = s.bestStreak;
    _syncReminders();
    loaded = true;
    notifyListeners();
    if (s.firstRun) _persist();
  }

  int _nextId() {
    var maxId = DateTime.now().millisecondsSinceEpoch;
    for (final t in [..._todos, ..._archived]) {
      maxId = math.max(maxId, t.id + 1);
    }
    return maxId;
  }

  Todo add(
    String text,
    Priority priority, {
    DateTime? due,
    String note = '',
    bool pinned = false,
    Repeat repeat = Repeat.none,
  }) {
    if (due == null) (text, due) = parseDue(text, DateTime.now());
    final todo = Todo(
      id: _nextId(),
      text: text.trim(),
      priority: priority,
      createdAt: DateTime.now(),
      due: due,
      note: note.trim(),
      pinned: pinned,
      repeat: repeat,
    );
    _todos = [todo, ..._todos];
    _changed();
    return todo;
  }

  void edit(
    int id, {
    required String text,
    required Priority priority,
    DateTime? due,
    String note = '',
    bool pinned = false,
    Repeat repeat = Repeat.none,
  }) {
    if (due == null) (text, due) = parseDue(text, DateTime.now());
    _todos = [
      for (final t in _todos)
        if (t.id == id)
          t.copyWith(
            text: text.trim(),
            priority: priority,
            due: due,
            clearDue: due == null,
            note: note.trim(),
            pinned: pinned,
            repeat: repeat,
          )
        else
          t,
    ];
    _changed();
  }

  void togglePin(int id) {
    _todos = [for (final t in _todos) t.id == id ? t.copyWith(pinned: !t.pinned) : t];
    _changed();
  }

  /// Finishing a repeating task also adds its next occurrence just above it;
  /// unchecking it takes that copy away again (if it is still untouched).
  void setCompleted(int id, bool done) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index < 0) return;
    final t = _todos[index];
    final list = [..._todos];
    if (done) {
      final now = DateTime.now();
      list[index] = t.copyWith(completedAt: now);
      if (t.repeat != Repeat.none) {
        list.insert(
          index,
          Todo(
            id: _nextId(),
            text: t.text,
            priority: t.priority,
            createdAt: now,
            due: nextDue(t.repeat, t.due, now),
            note: t.note,
            pinned: t.pinned,
            repeat: t.repeat,
          ),
        );
      }
    } else {
      list[index] = t.copyWith(reopen: true);
      if (t.repeat != Repeat.none) {
        list.removeWhere((c) => !c.completed && c.text == t.text && c.createdAt == t.completedAt);
      }
    }
    _todos = list;
    _changed();
    if (done && bestStreak > _savedBestStreak) {
      _savedBestStreak = bestStreak;
      unawaited(_save(_storage.saveBestStreak(_savedBestStreak)));
    }
  }

  /// Returns the removed task and its position, for undo.
  (Todo, int)? delete(int id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index < 0) return null;
    final removed = _todos[index];
    _todos = [..._todos]..removeAt(index);
    _changed();
    return (removed, index);
  }

  void undoDelete(Todo todo, int index) {
    final list = [..._todos];
    list.insert(math.min(index, list.length), todo);
    _todos = list;
    _changed();
  }

  /// Moves finished tasks into the archive. Returns what was moved.
  List<Todo> archive(Iterable<int> ids) {
    final set = ids.toSet();
    final moved = _todos.where((t) => set.contains(t.id)).toList();
    if (moved.isEmpty) return moved;
    _todos = _todos.where((t) => !set.contains(t.id)).toList();
    _archived = [...moved, ..._archived];
    _changed();
    return moved;
  }

  /// Undo for a shake: tasks come back still finished. Only those still in
  /// the archive return (one may have been reopened or deleted meanwhile).
  List<Todo> unarchive(List<Todo> items) {
    final ids = items.map((t) => t.id).toSet();
    final back = _archived.where((t) => ids.contains(t.id)).toList();
    if (back.isEmpty) return back;
    _archived = _archived.where((t) => !ids.contains(t.id)).toList();
    _todos = [..._todos, ...back];
    _changed();
    return back;
  }

  /// From the archive sheet: put a task back on the list as an open task.
  void reopenFromArchive(int id) {
    final index = _archived.indexWhere((t) => t.id == id);
    if (index < 0) return;
    final todo = _archived[index].copyWith(reopen: true);
    _archived = [..._archived]..removeAt(index);
    _todos = [todo, ..._todos];
    _changed();
  }

  (Todo, int)? deleteArchived(int id) {
    final index = _archived.indexWhere((t) => t.id == id);
    if (index < 0) return null;
    final removed = _archived[index];
    _archived = [..._archived]..removeAt(index);
    _changed();
    return (removed, index);
  }

  void undoDeleteArchived(Todo todo, int index) {
    final list = [..._archived];
    list.insert(math.min(index, list.length), todo);
    _archived = list;
    _changed();
  }

  void clearArchive() {
    _archived = [];
    _changed();
  }

  DateTime? _goalCelebrated;

  /// True only the first time today's count reaches the goal, so
  /// unchecking and rechecking a task doesn't celebrate again.
  bool reachedGoalJustNow() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (dailyGoal == 0 || doneToday() < dailyGoal || _goalCelebrated == today) return false;
    _goalCelebrated = today;
    return true;
  }

  void setSound(bool on) {
    soundOn = on;
    _settingsChanged();
  }

  void setHaptics(bool on) {
    hapticsOn = on;
    _settingsChanged();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _settingsChanged();
  }

  void setLanguage(String code, {bool save = true}) {
    language = code;
    s = S.forLanguage(code);
    if (save) _settingsChanged();
  }

  Future<void> setReminders(bool on) async {
    if (on && !(await _reminders?.requestPermission() ?? false)) {
      remindersBlocked = true;
      notifyListeners();
      return;
    }
    remindersBlocked = false;
    remindersOn = on;
    _settingsChanged();
    _syncReminders();
  }

  Timer? _reminderTimer;

  /// Coalesces bursts of edits into one reschedule.
  void _syncReminders() {
    if (_reminders == null) return;
    _reminderTimer?.cancel();
    _reminderTimer = Timer(const Duration(seconds: 1), () {
      unawaited(_reminders.sync(_todos, on: remindersOn));
    });
  }

  void setDailyGoal(int goal) {
    dailyGoal = goal;
    _settingsChanged();
  }

  void _settingsChanged() {
    notifyListeners();
    unawaited(_save(_storage.saveSettings(
      soundOn: soundOn,
      hapticsOn: hapticsOn,
      theme: themeMode.name,
      language: language,
      remindersOn: remindersOn,
      dailyGoal: dailyGoal,
    )));
  }

  Future<void> savePile(Map<String, dynamic> pile) => _save(_storage.savePile(pile));

  void _changed() {
    notifyListeners();
    _persist();
    _syncReminders();
  }

  void _persist() => unawaited(_save(_storage.saveTodos(_todos, _archived)));

  /// The UI can't wait on disk, but a failed write must at least be seen.
  static Future<void> _save(Future<void> write) =>
      write.catchError((Object e) => debugPrint('Save failed: $e'));

  static List<Todo> _starterTasks() {
    final now = DateTime.now();
    var id = now.millisecondsSinceEpoch;
    const priorities = [
      Priority.normal,
      Priority.low,
      Priority.high,
      Priority.low,
      Priority.normal,
      Priority.normal
    ];
    return [
      for (final (i, text) in s.starterTasks.indexed)
        Todo(id: id++, text: text, priority: priorities[i], createdAt: now),
    ];
  }
}
