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
}
