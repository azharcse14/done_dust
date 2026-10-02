import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_todo/main.dart';
import 'package:physics_todo/models/todo.dart';
import 'package:physics_todo/services/storage.dart';
import 'package:physics_todo/state/todo_store.dart';
import 'package:physics_todo/ui/archive_sheet.dart';
import 'package:physics_todo/ui/stats_sheet.dart';
import 'package:physics_todo/ui/task_editor_sheet.dart';
import 'package:physics_todo/ui/todo_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app boots', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = TodoStore(Storage());
    await store.load();
    await tester.pumpWidget(PhysicsTodoApp(store: store));
    expect(find.byType(PhysicsTodoApp), findsOneWidget);
    expect(find.bySemanticsLabel('Empty jar'), findsOneWidget);
  });

  testWidgets('search filters rows, a pasted list adds many tasks',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = TodoStore(Storage());
    await store.load();
    await tester.pumpWidget(PhysicsTodoApp(store: store));

    await tester.tap(find.byTooltip('Search and sort'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'tilt');
    await tester.pump();
    expect(find.bySemanticsLabel('Tilt your phone to slide the pile'),
        findsOneWidget);
    expect(find.bySemanticsLabel('Check me off and watch the letters fall'),
        findsNothing);
    await tester.tap(find.byTooltip('Close search'));
    await tester.pump();

    final before = store.todos.length;
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextField).first, 'milk\n\neggs\n bread ');
    await tester.pump();
    await tester.ensureVisible(find.text('Add 3 tasks'));
    await tester.tap(find.text('Add 3 tasks'));
    await tester.pumpAndSettle();
    expect(store.todos.length, before + 3);
    expect(store.todos.take(3).map((t) => t.text), ['milk', 'eggs', 'bread']);
  });

  testWidgets('date picker opens for a task overdue by years', (tester) async {
    final old = Todo(
        id: 1,
        text: 'ancient',
        createdAt: DateTime(2020),
        due: DateTime(2020, 3, 4));
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showTaskEditor(context, editing: old),
          child: const Text('edit'),
        ),
      ),
    ));
    await tester.tap(find.text('edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Due '));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('settings sheet switches the app to Bangla and saves it',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = TodoStore(Storage());
    await store.load();
    addTearDown(() => store.setLanguage('en'));
    await tester.pumpWidget(PhysicsTodoApp(store: store));

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('বাংলা'));
    await tester.pumpAndSettle();

    expect(find.text('সেটিংস'), findsOneWidget);
    expect(find.text('আমার কাজ'), findsOneWidget);
    expect((await Storage().load()).language, 'bn');
  });

  testWidgets(
      'archive: swipe deletes with undo, reopen moves back, clear asks first',
      (tester) async {
    final store = await _storeWith(['one', 'two', 'three']);
    await _open(tester, (c) => showArchiveSheet(c, store));

    await tester.drag(find.text('one'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(store.archived.map((t) => t.text), isNot(contains('one')));
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(store.archived.map((t) => t.text), contains('one'));

    await tester.tap(find.byTooltip('Reopen task').first);
    await tester.pumpAndSettle();
    expect(store.archived.length, 2);
    expect(store.todos.single.completed, isFalse);

    await tester.tap(find.text('Clear archive').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear archive'));
    await tester.pumpAndSettle();
    expect(store.archived, isEmpty);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('archive search filters past five items', (tester) async {
    final store = await _storeWith(['a1', 'a2', 'a3', 'a4', 'a5', 'milk']);
    await _open(tester, (c) => showArchiveSheet(c, store));
    await tester.enterText(find.byType(TextField), 'mil');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('milk'), findsOneWidget);
  });

  testWidgets('stats sheet shows a bar per weekday', (tester) async {
    final store = await _storeWith(['x']);
    await _open(tester, (c) => showStatsSheet(c, store));
    expect(find.text('Stats'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(7));
    expect(find.textContaining('Best day'), findsOneWidget);
  });

  testWidgets('tapping a task row checks it off', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = TodoStore(Storage());
    await store.load();
    await tester.pumpWidget(PhysicsTodoApp(store: store));
    await tester.pump(const Duration(seconds: 1));
    final tile = find.byType(TodoTile).first;
    final task = tester.widget<TodoTile>(tile).todo;
    expect(task.completed, isFalse);
    await tester.tap(tile);
    await tester.pump(const Duration(seconds: 1));
    expect(store.byId(task.id)!.completed, isTrue);
  });
}

Future<TodoStore> _storeWith(List<String> archivedTexts) async {
  SharedPreferences.setMockInitialValues({'todos.v2': '[]'});
  final store = TodoStore(Storage());
  await store.load();
  final ids = [for (final t in archivedTexts) store.add(t, Priority.normal).id];
  for (final id in ids) {
    store.setCompleted(id, true);
  }
  store.archive(ids);
  return store;
}

Future<void> _open(
    WidgetTester tester, void Function(BuildContext) show) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(
        builder: (context) => TextButton(
            onPressed: () => show(context), child: const Text('open'))),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
