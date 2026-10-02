import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart' show ThemeMode;

import 'package:flutter_test/flutter_test.dart';
import 'package:physics_todo/l10n.dart';
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

    test('due date round-trips and counts whole days', () {
      final t = Todo(id: 1, text: 'a', createdAt: DateTime(2026), due: DateTime(2026, 10, 3));
      expect(Todo.fromJson(t.toJson()).due, DateTime(2026, 10, 3));
      expect(t.daysUntilDue(DateTime(2026, 10, 2, 23, 59)), 1);
      expect(t.daysUntilDue(DateTime(2026, 10, 5)), -2);
      expect(t.copyWith(clearDue: true).due, isNull);
      expect(Todo.fromJson(t.copyWith(clearDue: true).toJson()).due, isNull);
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

    test('old split lists load, then save as one key', () async {
      SharedPreferences.setMockInitialValues({
        'todos.v2': '[{"id":1,"text":"open","createdAt":0}]',
        'archive.v2': '[{"id":2,"text":"old","createdAt":0,"completedAt":0}]',
      });
      final storage = Storage();
      final s = await storage.load();
      expect(s.firstRun, isFalse);
      expect(s.todos.single.text, 'open');
      expect(s.archived.single.text, 'old');

      await storage.saveTodos(s.todos, s.archived);
      final prefs = await SharedPreferences.getInstance();
      final saved = jsonDecode(prefs.getString('tasks.v3')!) as Map;
      expect((saved['todos'] as List).single['text'], 'open');
      expect((saved['archive'] as List).single['text'], 'old');
      final again = await Storage().load();
      expect(again.archived.single.id, 2);
    });

    test('an unreadable task store is backed up', () async {
      SharedPreferences.setMockInitialValues({'tasks.v3': '{oops'});
      final s = await Storage().load();
      expect(s.todos, isEmpty);
      expect(s.firstRun, isFalse, reason: 'a broken store must not be replaced by starter tasks');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('tasks.v3.bak'), '{oops');
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

    test('shake undo skips tasks reopened or deleted meanwhile', () async {
      final store = await _emptyStore();
      final a = store.add('a', Priority.normal);
      final b = store.add('b', Priority.normal);
      final c = store.add('c', Priority.normal);
      for (final t in [a, b, c]) {
        store.setCompleted(t.id, true);
      }
      final moved = store.archive([a.id, b.id, c.id]);
      store.reopenFromArchive(a.id);
      store.deleteArchived(b.id);

      final back = store.unarchive(moved);
      expect(back.map((t) => t.id), [c.id]);
      expect(store.todos.map((t) => t.id), [a.id, c.id], reason: 'no duplicate, b stays deleted');
      expect(store.byId(a.id)!.completed, isFalse);
      expect(store.archived, isEmpty);
    });

    test('daily goal celebrates once per day', () async {
      final store = await _emptyStore();
      final a = store.add('a', Priority.normal);
      store.setDailyGoal(1);
      expect(store.reachedGoalJustNow(), isFalse);
      store.setCompleted(a.id, true);
      expect(store.reachedGoalJustNow(), isTrue);
      store.setCompleted(a.id, false);
      store.setCompleted(a.id, true);
      expect(store.reachedGoalJustNow(), isFalse);
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

    test('streak, weekday counts and export', () async {
      Map<String, Object?> done(int id, DateTime d) =>
          {'id': id, 'text': 't$id', 'createdAt': 0, 'completedAt': d.millisecondsSinceEpoch};
      SharedPreferences.setMockInitialValues({
        'todos.v2': jsonEncode([
          done(1, DateTime(2026, 10, 1, 9)), // Thu
          {'id': 2, 'text': 'open', 'createdAt': 0},
        ]),
        'archive.v2': jsonEncode([
          done(3, DateTime(2026, 9, 30, 22)), // Wed
          done(4, DateTime(2026, 9, 28)), // gap on the 29th
        ]),
      });
      final store = TodoStore(Storage());
      await store.load();
      expect(store.streak(DateTime(2026, 10, 1, 12)), 2);
      expect(store.streak(DateTime(2026, 10, 2)), 2, reason: 'alive until today ends');
      expect(store.streak(DateTime(2026, 10, 3)), 0);
      expect(store.doneByWeekday(), [1, 0, 1, 1, 0, 0, 0]);
      expect(store.doneTotal, 3);
      expect(store.exportText(), '- [x] t1\n- [ ] open');
    });

    test('daily goal persists', () async {
      SharedPreferences.setMockInitialValues({});
      final s = TodoStore(Storage());
      await s.load();
      expect(s.dailyGoal, 0);
      s.setDailyGoal(5);
      await Future<void>.delayed(Duration.zero);
      final again = TodoStore(Storage());
      await again.load();
      expect(again.dailyGoal, 5);
    });

    test('delete one archived task, theme persists', () async {
      final store = await _emptyStore();
      final a = store.add('a', Priority.normal);
      final b = store.add('b', Priority.normal, due: DateTime(2026, 1, 2));
      store.edit(b.id, text: 'b', priority: Priority.low);
      expect(store.byId(b.id)!.due, isNull, reason: 'edit without a due date clears it');
      store.setCompleted(a.id, true);
      store.archive([a.id]);
      store.deleteArchived(a.id);
      expect(store.archived, isEmpty);

      store.setThemeMode(ThemeMode.dark);
      await Future<void>.delayed(Duration.zero);
      final again = TodoStore(Storage());
      await again.load();
      expect(again.themeMode, ThemeMode.dark);
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

    test('a damaged saved group is poured fresh, not half restored', () {
      final b = world();
      final missing = b.restore({
        'groups': {
          '1': [
            [0, 'a', 9, 14, 0.5, 10, 0],
            [1, 'b', 'bad', 14, 0.5, 10, 0],
          ],
        },
      }, {
        1: (priority: Priority.normal, color: const Color(0xFF000000)),
      });
      expect(missing, {1});
      expect(b.has(1), isFalse);
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

    test('letters fly home one by one, first letter first', () {
      final w = world();
      pour(w, 1, 8);
      for (var i = 0; i < 300; i++) {
        w.step(1 / 60);
      }
      final ps = w.groupOf(1)!.particles..sort((a, b) => a.index.compareTo(b.index));
      final before = [for (final p in ps) (p.x, p.y)];
      w.startReturn(1);
      w.updateReturnTargets(1, _glyphs('x' * 8));
      w.step(1 / 60);
      expect((ps.first.x, ps.first.y), isNot(before.first), reason: 'first letter leaves at once');
      expect((ps.last.x, ps.last.y), before.last, reason: 'last letter is still waiting');
    });

    test('celebrate keeps the world awake until the confetti fades', () {
      final w = world()..celebrate(const [Color(0xFFFF0000)]);
      expect(w.dust, isNotEmpty);
      expect(w.isIdle, isFalse);
      for (var i = 0; i < 180; i++) {
        w.step(1 / 60);
      }
      expect(w.dust, isEmpty);
      expect(w.isIdle, isTrue);
    });
  });

  group('Notes, pins, repeats', () {
    test('new fields round-trip and default when missing', () {
      final t = Todo(
          id: 1,
          text: 'a',
          createdAt: DateTime(2026),
          note: 'n',
          pinned: true,
          repeat: Repeat.weekly);
      final back = Todo.fromJson(t.toJson());
      expect((back.note, back.pinned, back.repeat), ('n', true, Repeat.weekly));
      final old = Todo.fromJson({'id': 1, 'text': 'a', 'createdAt': 0});
      expect((old.note, old.pinned, old.repeat), ('', false, Repeat.none));
    });

    test('nextDue steps from the due date, or from today when overdue', () {
      final now = DateTime(2026, 10, 2, 15);
      expect(nextDue(Repeat.daily, null, now), DateTime(2026, 10, 3));
      expect(nextDue(Repeat.weekly, DateTime(2026, 10, 5), now), DateTime(2026, 10, 12));
      expect(nextDue(Repeat.daily, DateTime(2026, 9, 1), now), DateTime(2026, 10, 3));
    });

    test('finishing a repeating task adds the next one; unchecking takes it back', () async {
      final store = await _emptyStore();
      final t = store.add('water plants', Priority.normal, repeat: Repeat.daily);
      store.setCompleted(t.id, true);
      expect(store.todos.length, 2);
      final next = store.todos.firstWhere((x) => !x.completed);
      expect((next.text, next.repeat), ('water plants', Repeat.daily));
      expect(next.due, isNotNull);

      store.setCompleted(t.id, false);
      expect(store.todos.map((x) => x.id), [t.id]);
      expect(store.todos.single.completed, isFalse);
    });

    test('togglePin flips the flag', () async {
      final store = await _emptyStore();
      final t = store.add('a', Priority.normal);
      store.togglePin(t.id);
      expect(store.byId(t.id)!.pinned, isTrue);
    });
  });

  group('Smart dates', () {
    final fri = DateTime(2026, 10, 2, 10); // a Friday

    test('a trailing date word sets the due date and is removed', () {
      expect(parseDue('call mom tomorrow', fri), ('call mom', DateTime(2026, 10, 3)));
      expect(parseDue('pay rent by Monday', fri), ('pay rent', DateTime(2026, 10, 5)));
      expect(parseDue('review fri', fri), ('review', DateTime(2026, 10, 9)));
      expect(parseDue('বাজার করা আগামীকাল', fri), ('বাজার করা', DateTime(2026, 10, 3)));
      expect(parseDue('মিটিং সোমবার', fri), ('মিটিং', DateTime(2026, 10, 5)));
    });

    test('words elsewhere, or alone, are left as typed', () {
      expect(parseDue("Today's report", fri), ("Today's report", null));
      expect(parseDue('tomorrow', fri), ('tomorrow', null));
      expect(parseDue('read sunday times article', fri).$2, isNull);
    });

    test('store.add applies it only when no date was picked', () async {
      final store = await _emptyStore();
      final a = store.add('gym today', Priority.normal);
      expect(a.text, 'gym');
      expect(a.due, isNotNull);
      final b = store.add('gym today', Priority.normal, due: DateTime(2030));
      expect((b.text, b.due), ('gym today', DateTime(2030)));
    });
  });

  group('Stats', () {
    Future<TodoStore> storeDoneOn(List<DateTime> days, {int savedBest = 0}) async {
      SharedPreferences.setMockInitialValues({
        'tasks.v3': jsonEncode({
          'todos': [],
          'archive': [
            for (final (i, d) in days.indexed)
              {'id': i, 'text': 't$i', 'createdAt': 0, 'completedAt': d.millisecondsSinceEpoch},
          ],
        }),
        'bestStreak': savedBest,
      });
      final store = TodoStore(Storage());
      await store.load();
      return store;
    }

    test('week counts start on Monday', () async {
      final fri = DateTime(2026, 10, 2, 12);
      final store = await storeDoneOn([
        DateTime(2026, 9, 28, 9), // Mon this week
        DateTime(2026, 10, 2, 8),
        DateTime(2026, 9, 27, 9), // Sun last week
        DateTime(2026, 9, 21, 9), // Mon last week
        DateTime(2026, 9, 20, 9), // two weeks ago
      ]);
      expect(store.weekCounts(fri), (2, 2));
    });

    test('best streak is the longest run, and never below the saved record', () async {
      final store = await storeDoneOn([
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 3),
        DateTime(2026, 1, 3, 18),
        DateTime(2026, 2, 1),
      ]);
      expect(store.bestStreak, 3);
      expect((await storeDoneOn([DateTime(2026, 1, 1)], savedBest: 9)).bestStreak, 9);
      expect(store.doneByDate()[DateTime.utc(2026, 1, 3)], 2);
    });

    test('a streak milestone celebrates once a day', () async {
      final now = DateTime.now();
      final store = await storeDoneOn([
        for (var i = 0; i < 7; i++) DateTime(now.year, now.month, now.day - i, 9),
      ]);
      expect(store.streakMilestoneJustNow(), 7);
      expect(store.streakMilestoneJustNow(), isNull);
    });
  });

  test('weekCompare shows the change against last week', () {
    expect(const S(false).weekCompare(6, 4), 'This week 6 · last week 4 (+50%)');
    expect(const S(true).weekCompare(2, 4), 'এই সপ্তাহে ২ · গত সপ্তাহে ৪ (−৫০%)');
  });
}
