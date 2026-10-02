import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:physics_todo/main.dart';
import 'package:physics_todo/services/storage.dart';
import 'package:physics_todo/state/todo_store.dart';
import 'package:physics_todo/ui/todo_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'add a task, finish it, archive it, and it all survives a restart',
      (tester) async {
    SharedPreferences.setMockInitialValues({'todos.v2': '[]'});
    final store = TodoStore(Storage());
    await store.load();
    await tester.pumpWidget(PhysicsTodoApp(store: store));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'buy milk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(seconds: 1));
    expect(store.todos.single.text, 'buy milk');

    await tester.tap(find.byType(TodoTile).first);
    await tester.pump(const Duration(seconds: 2));
    expect(store.todos.single.completed, isTrue);

    store.archive([store.todos.single.id]);
    await tester.pump(const Duration(seconds: 1));

    final again = TodoStore(Storage());
    await again.load();
    expect(again.todos, isEmpty);
    expect(again.archived.single.text, 'buy milk');
    expect(again.archived.single.completed, isTrue);
  });
}
