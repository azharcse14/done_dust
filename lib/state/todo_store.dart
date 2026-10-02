import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../models/todo.dart';
import '../services/storage.dart';

class TodoStore extends ChangeNotifier {
  TodoStore(this._storage);

  final Storage _storage;
  List<Todo> _todos = [];
  List<Todo> _archived = [];
  bool loaded = false;
  bool soundOn = true;
  bool hapticsOn = true;
  ThemeMode themeMode = ThemeMode.system;

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

  Todo add(String text, Priority priority, {DateTime? due}) {
    final todo = Todo(
      id: _nextId(),
      text: text.trim(),
      priority: priority,
      createdAt: DateTime.now(),
      due: due,
    );
    _todos = [todo, ..._todos];
    _changed();
    return todo;
  }

  void edit(int id, {required String text, required Priority priority, DateTime? due}) {
    _todos = [
      for (final t in _todos)
        if (t.id == id)
          t.copyWith(text: text.trim(), priority: priority, due: due, clearDue: due == null)
        else
          t,
    ];
    _changed();
  }

  void setCompleted(int id, bool done) {
    _todos = [
      for (final t in _todos)
        if (t.id == id)
          (done ? t.copyWith(completedAt: DateTime.now()) : t.copyWith(reopen: true))
        else
          t,
    ];
    _changed();
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

  /// Undo for a shake: tasks come back still finished.
  void unarchive(List<Todo> items) {
    final ids = items.map((t) => t.id).toSet();
    _archived = _archived.where((t) => !ids.contains(t.id)).toList();
    _todos = [..._todos, ...items];
    _changed();
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
      dailyGoal: dailyGoal,
    )));
  }

  Future<void> savePile(Map<String, dynamic> pile) => _save(_storage.savePile(pile));

  void _changed() {
    notifyListeners();
    _persist();
  }

  void _persist() => unawaited(_save(_storage.saveTodos(_todos, _archived)));

  /// The UI can't wait on disk, but a failed write must at least be seen.
  static Future<void> _save(Future<void> write) =>
      write.catchError((Object e) => debugPrint('Save failed: $e'));

  static List<Todo> _starterTasks() {
    final now = DateTime.now();
    var id = now.millisecondsSinceEpoch;
    Todo t(String text, Priority p) => Todo(id: id++, text: text, priority: p, createdAt: now);
    return [
      t('Check me off and watch the letters fall', Priority.normal),
      t('Tilt your phone to slide the pile', Priority.low),
      t('Important tasks are bold and fall like stone', Priority.high),
      t('Drag a fallen letter, or tap the pile', Priority.low),
      t('Swipe a task sideways to blow it away', Priority.normal),
      t('Shake the phone to empty the jar into the archive', Priority.normal),
    ];
  }
}
