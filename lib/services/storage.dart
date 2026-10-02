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
    required this.firstRun,
  });

  final List<Todo> todos;
  final List<Todo> archived;
  final Map<String, dynamic>? pile;
  final bool soundOn;
  final bool hapticsOn;
  final bool firstRun;
}

/// Small JSON store on top of shared_preferences.
class Storage {
  static const _kTodos = 'todos.v2';
  static const _kArchive = 'archive.v2';
  static const _kPile = 'pile.v2';
  static const _kSound = 'sound';
  static const _kHaptics = 'haptics';

  SharedPreferences? _prefs;

  Future<StoredState> load() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final rawTodos = prefs.getString(_kTodos);
    return StoredState(
      todos: await _decodeTodos(prefs, _kTodos),
      archived: await _decodeTodos(prefs, _kArchive),
      pile: _decodeMap(prefs.getString(_kPile)),
      soundOn: prefs.getBool(_kSound) ?? true,
      hapticsOn: prefs.getBool(_kHaptics) ?? true,
      firstRun: rawTodos == null,
    );
  }

  Future<void> saveTodos(List<Todo> todos, List<Todo> archived) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(_kTodos, jsonEncode([for (final t in todos) t.toJson()]));
    await prefs.setString(_kArchive, jsonEncode([for (final t in archived) t.toJson()]));
  }

  Future<void> savePile(Map<String, dynamic> pile) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(_kPile, jsonEncode(pile));
  }

  Future<void> saveSettings({required bool soundOn, required bool hapticsOn}) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setBool(_kSound, soundOn);
    await prefs.setBool(_kHaptics, hapticsOn);
  }

  /// A bad entry is skipped, not allowed to wipe the whole list. If the
  /// list itself is unreadable, the raw text is kept under `<key>.bak`
  /// before the next save overwrites it.
  static Future<List<Todo>> _decodeTodos(SharedPreferences prefs, String key) async {
    final raw = prefs.getString(key);
    if (raw == null) return [];
    Object? list;
    try {
      list = jsonDecode(raw);
    } catch (_) {}
    if (list is! List) {
      await prefs.setString('$key.bak', raw);
      return [];
    }
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
