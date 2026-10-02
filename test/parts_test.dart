import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_todo/models/todo.dart';
import 'package:physics_todo/physics/particle.dart';
import 'package:physics_todo/physics/spatial_grid.dart';
import 'package:physics_todo/services/feedback_service.dart';
import 'package:physics_todo/services/reminders.dart';
import 'package:physics_todo/services/storage.dart';
import 'package:physics_todo/state/todo_store.dart';
import 'package:physics_todo/theme.dart';
import 'package:physics_todo/ui/task_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeReminders implements Reminders {
  _FakeReminders({this.allow = true});

  final bool allow;
  final synced = <(List<int>, bool)>[];

  @override
  Future<bool> requestPermission() async => allow;

  @override
  Future<void> sync(List<Todo> todos, {required bool on}) async =>
      synced.add(([for (final t in todos) t.id], on));

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Particle _p(double x, double y) => Particle(
      glyph: 'a',
      index: 0,
      x: x,
      y: y,
      width: 10,
      height: 10,
      material: ParticleMaterial.sand,
      tint: const Color(0xFF000000),
    );

void main() {
  test('SpatialGrid finds every pair a brute-force scan finds', () {
    final rnd = math.Random(1);
    final ps = [
      for (var i = 0; i < 200; i++)
        _p(rnd.nextDouble() * 400, rnd.nextDouble() * 800)
    ];
    const cell = 20.0;
    final grid = SpatialGrid()..build(ps, 400, 800, cell);
    final got = <(int, int)>{};
    grid.forEachPair(ps.length, (i, j) => got.add((i, j)));

    for (var i = 0; i < ps.length; i++) {
      for (var j = i + 1; j < ps.length; j++) {
        final d = math.sqrt(math.pow(ps[i].cx - ps[j].cx, 2) +
            math.pow(ps[i].cy - ps[j].cy, 2));
        if (d < cell) {
          expect(got, contains((i, j)), reason: 'close pair missed');
        }
      }
    }
    expect(got.every((p) => p.$1 < p.$2), isTrue);
  });

  test('SpatialGrid keeps off-screen letters in a valid cell', () {
    final ps = [_p(-500, -500), _p(-499, -499), _p(9999, 9999)];
    final grid = SpatialGrid()..build(ps, 100, 100, 20);
    final got = <(int, int)>[];
    grid.forEachPair(ps.length, (i, j) => got.add((i, j)));
    expect(got, [(0, 1)]);
  });

  test('ParticleMaterial: higher priority is heavier', () {
    final m = [for (final p in Priority.values) ParticleMaterial.of(p).mass];
    expect(m, [0.6, 1.0, 2.6]);
    expect(
        weightAxisFor(Priority.high), greaterThan(weightAxisFor(Priority.low)));
  });

  test('theme: due labels and weekday strata', () {
    final d = DateTime(2026, 10, 3);
    expect(dueLabel(0, d), 'Due today');
    expect(dueLabel(1, d), 'Due tomorrow');
    expect(dueLabel(-2, d), contains('2'));
    expect(dueLabel(5, d), contains('3'));
    expect(Palette.light.strataFor(DateTime(2026, 10, 5)),
        Palette.light.strata.first); // Mon
    expect(Palette.light.strataFor(DateTime(2026, 10, 4)),
        Palette.light.strata.last); // Sun
    expect(buildTheme(Brightness.dark).scaffoldBackgroundColor,
        Palette.dark.glass);
  });

  test('anchorsFromPainter gives one anchor per grapheme', () {
    const text = 'a👍🏽 কি';
    final painter = TextPainter(
      text: const TextSpan(text: text, style: TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    final anchors = anchorsFromPainter(painter, text, const Offset(10, 20));
    expect(anchors.map((a) => a.glyph).join(), text);
    expect(
        anchors.map((a) => a.index), List.generate(anchors.length, (i) => i));
    expect(anchors.length, text.characters.length);
    expect(anchors.first.x, greaterThanOrEqualTo(10));
    painter.dispose();
  });

  test('FeedbackService stays quiet without audio', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final f = FeedbackService();
    await f.init(); // no audio plugin in tests: must not throw
    f
      ..impact(900)
      ..whoosh()
      ..check()
      ..heavy()
      ..dispose();
  });

  group('Reminders in the store', () {
    testWidgets('turning on asks first, then syncs open tasks', (tester) async {
      SharedPreferences.setMockInitialValues({'todos.v2': '[]'});
      final r = _FakeReminders();
      final store = TodoStore(Storage(), r);
      await store.load();
      store.add('a', Priority.normal, due: DateTime(2030));
      store.add('b', Priority.normal);
      await store.setReminders(true);
      await tester.pump(const Duration(seconds: 2));
      expect(store.remindersOn, isTrue);
      expect(r.synced.length, 1, reason: 'bursts collapse into one sync');
      expect(r.synced.single.$1, [for (final t in store.todos) t.id]);
      expect(r.synced.single.$2, isTrue);
    });

    testWidgets('a refused permission leaves reminders off', (tester) async {
      SharedPreferences.setMockInitialValues({'todos.v2': '[]'});
      final store = TodoStore(Storage(), _FakeReminders(allow: false));
      await store.load();
      await store.setReminders(true);
      await tester.pump(const Duration(seconds: 2));
      expect(store.remindersOn, isFalse);
      expect(store.remindersBlocked, isTrue);
    });

    test('Reminders.sync survives a missing plugin', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final r = Reminders();
      await r.sync([
        Todo(id: 1, text: 'a', createdAt: DateTime(2026), due: DateTime(2030))
      ], on: true);
      expect(await r.requestPermission(), isFalse);
    });
  });
}
