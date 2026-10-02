import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class StoredState {
  const StoredState({
    required this.todos,
    required this.archived,
    required this.pile,
    required this.soundOn,
    required this.hapticsOn,
    required this.theme,
    required this.language,
    required this.remindersOn,
    required this.bestStreak,
    required this.jarStyle,
    required this.dailyGoal,
    required this.firstRun,
  });

  final List<Todo> todos;
  final List<Todo> archived;
  final Map<String, dynamic>? pile;
  final bool soundOn;
  final bool hapticsOn;
  final String? theme;
  final String? language;
  final bool remindersOn;
  final int bestStreak;
  final String? jarStyle;

  /// Tasks to finish per day; 0 = no goal.
  final int dailyGoal;
  final bool firstRun;
}

/// Small JSON store on top of shared_preferences.
class Storage {
  /// List and archive live under one key so moving tasks between them is a
  /// single write: a crash can't leave a task in neither list.
  static const _kTasks = 'tasks.v3';

  // Older builds kept the two lists apart; read only until the first save.
  static const _kTodos = 'todos.v2';
  static const _kArchive = 'archive.v2';
  static const _kPile = 'pile.v2';
  static const _kSound = 'sound';
  static const _kHaptics = 'haptics';
  static const _kTheme = 'theme';
  static const _kGoal = 'dailyGoal';
  static const _kLanguage = 'language';
  static const _kReminders = 'reminders';
  static const _kBestStreak = 'bestStreak';
  static const _kJarStyle = 'jarStyle';

  SharedPreferences? _prefs;

  Future<StoredState> load() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final rawTasks = prefs.getString(_kTasks);
    final List<Todo> todos;
    final List<Todo> archived;
    if (rawTasks != null) {
      final map = await _decode(prefs, _kTasks);
      todos = _todosFrom(map is Map ? map['todos'] : null);
      archived = _todosFrom(map is Map ? map['archive'] : null);
    } else {
      todos = _todosFrom(await _decode(prefs, _kTodos));
      archived = _todosFrom(await _decode(prefs, _kArchive));
    }
    return StoredState(
      todos: todos,
      archived: archived,
      pile: _decodeMap(prefs.getString(_kPile)),
      soundOn: prefs.getBool(_kSound) ?? true,
      hapticsOn: prefs.getBool(_kHaptics) ?? true,
      theme: prefs.getString(_kTheme),
      language: prefs.getString(_kLanguage),
      remindersOn: prefs.getBool(_kReminders) ?? false,
      bestStreak: prefs.getInt(_kBestStreak) ?? 0,
      jarStyle: prefs.getString(_kJarStyle),
      dailyGoal: prefs.getInt(_kGoal) ?? 0,
      firstRun: rawTasks == null && prefs.getString(_kTodos) == null,
    );
  }

  Future<void> saveTodos(List<Todo> todos, List<Todo> archived) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(
      _kTasks,
      jsonEncode({
        'todos': [for (final t in todos) t.toJson()],
        'archive': [for (final t in archived) t.toJson()],
      }),
    );
  }

  Future<void> savePile(Map<String, dynamic> pile) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(_kPile, jsonEncode(pile));
  }

  Future<void> saveBestStreak(int days) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setInt(_kBestStreak, days);
  }

  Future<void> saveSettings({
    required bool soundOn,
    required bool hapticsOn,
    required String theme,
    required String language,
    required bool remindersOn,
    required String jarStyle,
    required int dailyGoal,
  }) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setBool(_kSound, soundOn);
    await prefs.setBool(_kHaptics, hapticsOn);
    await prefs.setString(_kTheme, theme);
    await prefs.setString(_kLanguage, language);
    await prefs.setBool(_kReminders, remindersOn);
    await prefs.setString(_kJarStyle, jarStyle);
    await prefs.setInt(_kGoal, dailyGoal);
  }

  /// Parsed JSON under [key], or null. Unreadable text is kept under
  /// `<key>.bak` before the next save overwrites it.
  static Future<Object?> _decode(SharedPreferences prefs, String key) async {
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      await prefs.setString('$key.bak', raw);
      return null;
    }
  }

  /// A bad entry is skipped, not allowed to wipe the whole list.
  static List<Todo> _todosFrom(Object? list) {
    if (list is! List) return [];
    final todos = <Todo>[];
    for (final item in list) {
      try {
        todos.add(Todo.fromJson(item as Map<String, dynamic>));
      } catch (_) {}
    }
    return todos;
  }

  static Map<String, dynamic>? _decodeMap(String? raw) {
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
