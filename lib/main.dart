import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n.dart';
import 'services/reminders.dart';
import 'services/storage.dart';
import 'state/todo_store.dart';
import 'theme.dart';
import 'ui/todo_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tilt is read in the device's own axes, so the screen must not rotate
  // under it.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final store = TodoStore(Storage(), Reminders());
  await store.load();

  runApp(PhysicsTodoApp(store: store));
}

class PhysicsTodoApp extends StatelessWidget {
  const PhysicsTodoApp({super.key, required this.store});

  final TodoStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, child) => MaterialApp(
        title: 'Done Dust',
        debugShowCheckedModeBanner: false,
        locale: s.locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: store.themeMode,
        home: child,
      ),
      child: TodoScreen(store: store),
    );
  }
}
