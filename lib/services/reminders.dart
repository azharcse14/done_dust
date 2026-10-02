import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../l10n.dart';
import '../models/todo.dart';

/// One notification per open task, on the morning of its due day.
class Reminders {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  // ponytail: fixed 9:00 reminder; add a time picker if people ask for one.
  static const _hour = 9;

  // iOS keeps at most 64 pending notifications.
  static const _max = 50;

  static bool get supported =>
      !kIsWeb &&
      const [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
          .contains(defaultTargetPlatform);

  Future<void> _init() async {
    tzdata.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
        macOS: darwin,
      ),
    );
  }

  /// Asks the system once; false if the user said no.
  Future<bool> requestPermission() async {
    if (!supported) return false;
    try {
      await (_ready ??= _init());
      return switch (defaultTargetPlatform) {
            TargetPlatform.android => await _plugin
                .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission(),
            TargetPlatform.iOS => await _plugin
                .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, sound: true),
            _ => await _plugin
                .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, sound: true),
          } ??
          false;
    } catch (e) {
      debugPrint('Reminder permission failed: $e');
      return false;
    }
  }

  /// Replaces every scheduled reminder with one per open task due ahead.
  Future<void> sync(List<Todo> todos, {required bool on}) async {
    if (!supported) return;
    try {
      await (_ready ??= _init());
      await _plugin.cancelAll();
      if (!on) return;
      final now = tz.TZDateTime.now(tz.local);
      final due = [
        for (final t in todos)
          if (!t.completed && t.due != null)
            (t, tz.TZDateTime(tz.local, t.due!.year, t.due!.month, t.due!.day, _hour)),
      ].where((e) => e.$2.isAfter(now)).toList()
        ..sort((a, b) => a.$2.compareTo(b.$2));
      for (final (t, at) in due.take(_max)) {
        await _plugin.zonedSchedule(
          id: t.id % 0x7fffffff,
          scheduledDate: at,
          title: s.dueToday,
          body: t.text,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails('due', s.reminders),
            iOS: const DarwinNotificationDetails(),
            macOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Reminder sync failed: $e');
    }
  }
}
