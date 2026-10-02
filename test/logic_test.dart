import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:physics_todo/models/todo.dart';
import 'package:physics_todo/physics/particle.dart';
import 'package:physics_todo/physics/particle_world.dart';
import 'package:physics_todo/services/storage.dart';
import 'package:physics_todo/state/todo_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<TodoStore> _emptyStore() async {
  // An existing (empty) list skips the starter tasks.
  SharedPreferences.setMockInitialValues({'todos.v2': '[]'});
  final store = TodoStore(Storage());
  await store.load();
  return store;
}

List<CharAnchor> _glyphs(String text) => [
      for (var i = 0; i < text.length; i++)
        CharAnchor(glyph: text[i], index: i, x: 20.0 + i * 10, baselineY: 0, width: 9, height: 14),
    ];

void main() {
  group('Todo json', () {
    test('round-trips', () {
      final t = Todo(
        id: 1,
        text: 'a',
        priority: Priority.high,
        createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        completedAt: DateTime.fromMillisecondsSinceEpoch(2000),
      );
      final back = Todo.fromJson(t.toJson());
      expect(back.priority, Priority.high);
      expect(back.completedAt, t.completedAt);
    });

    test('unknown priority falls back to normal', () {
      final back = Todo.fromJson({'id': 1, 'text': 'a', 'priority': '??', 'createdAt': 0});
      expect(back.priority, Priority.normal);
    });
  });

  group('Storage', () {
    test('a bad entry is skipped, not the whole list', () async {
      SharedPreferences.setMockInitialValues({
        'todos.v2': '[{"id":1,"text":"ok","createdAt":0},{"id":"broken"}]',
      });
      final s = await Storage().load();
      expect(s.todos.map((t) => t.text), ['ok']);
    });

    test('an unreadable list is backed up before it can be overwritten', () async {
      SharedPreferences.setMockInitialValues({'todos.v2': '{not json'});
      final s = await Storage().load();
      expect(s.todos, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('todos.v2.bak'), '{not json');
    });
  });

  group('TodoStore', () {
    test('first run gets starter tasks', () async {
      SharedPreferences.setMockInitialValues({});
      final store = TodoStore(Storage());
      await store.load();
      expect(store.todos, isNotEmpty);
    });

    test('add, complete, archive, unarchive', () async {
      final store = await _emptyStore();
      final a = store.add('  a  ', Priority.normal);
      final b = store.add('b', Priority.low);
      expect(a.text, 'a');
      expect(b.id, greaterThan(a.id));

      store.setCompleted(a.id, true);
      expect(store.doneToday(), 1);

      final moved = store.archive([a.id]);
      expect(store.todos.map((t) => t.id), [b.id]);
      expect(store.archived.single.id, a.id);
      expect(store.doneToday(), 1, reason: 'archived tasks still count');

      store.unarchive(moved);
      expect(store.archived, isEmpty);
      expect(store.byId(a.id)!.completed, isTrue);
    });

    test('delete and undo restore position', () async {
      final store = await _emptyStore();
      final a = store.add('a', Priority.normal);
      store.add('b', Priority.normal);
      final (removed, index) = store.delete(a.id)!;
      store.undoDelete(removed, index);
      expect(store.todos[index].id, a.id);
      expect(store.delete(-1), isNull);
    });

    test('reopen from archive', () async {
      final store = await _emptyStore();
      final a = store.add('a', Priority.normal);
      store.setCompleted(a.id, true);
      store.archive([a.id]);
      store.reopenFromArchive(a.id);
      expect(store.byId(a.id)!.completed, isFalse);
      expect(store.archived, isEmpty);
    });

    test('changes survive a reload', () async {
      final store = await _emptyStore();
      store.add('kept', Priority.high);
      await Future<void>.delayed(Duration.zero);
      final again = TodoStore(Storage());
      await again.load();
      expect(again.todos.single.text, 'kept');
    });
  });

  group('ParticleWorld', () {
    ParticleWorld world() => ParticleWorld()..size = const Size(400, 800);

    void pour(ParticleWorld w, int id, int letters) => w.pourIn(
          taskId: id,
          glyphs: _glyphs('x' * letters),
          priority: Priority.normal,
          dayColor: const Color(0xFF000000),
        );

    test('snapshot and restore round-trip', () {
      final a = world();
      pour(a, 1, 5);
      for (var i = 0; i < 300; i++) {
        a.step(1 / 60);
      }
      final b = world();
      final missing = b.restore(a.snapshot(), {
        1: (priority: Priority.normal, color: const Color(0xFF000000)),
        2: (priority: Priority.low, color: const Color(0xFF000000)),
      });
      expect(b.groupOf(1)!.particles.length, 5);
      expect(missing, {2});
    });

    test('overflow throws out the oldest tasks first', () {
      final w = world()..maxJarLetters = 10;
      final thrown = <int>[];
      w.onOverflow = thrown.addAll;
      pour(w, 1, 6);
      pour(w, 2, 6);
      w.step(1 / 60);
      expect(thrown, [1]);
      expect(w.groupOf(1)!.phase, Phase.ejecting);
      expect(w.groupOf(2)!.inJar, isTrue);
    });
  });
}
