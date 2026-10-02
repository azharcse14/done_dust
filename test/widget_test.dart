import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_todo/main.dart';
import 'package:physics_todo/services/storage.dart';
import 'package:physics_todo/state/todo_store.dart';
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

  testWidgets('search filters rows, a pasted list adds many tasks', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = TodoStore(Storage());
    await store.load();
    await tester.pumpWidget(PhysicsTodoApp(store: store));

    await tester.tap(find.byTooltip('Search and sort'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'tilt');
    await tester.pump();
    expect(find.bySemanticsLabel('Tilt your phone to slide the pile'), findsOneWidget);
    expect(find.bySemanticsLabel('Check me off and watch the letters fall'), findsNothing);
    await tester.tap(find.byTooltip('Close search'));
    await tester.pump();

    final before = store.todos.length;
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'milk\n\neggs\n bread ');
    await tester.pump();
    await tester.tap(find.text('Add 3 tasks'));
    await tester.pumpAndSettle();
    expect(store.todos.length, before + 3);
    expect(store.todos.take(3).map((t) => t.text), ['milk', 'eggs', 'bread']);
  });
}
