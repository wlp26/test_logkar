import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../model/reminder_model.dart';

class ReminderRepository {
  ReminderRepository(this._preferences);

  static const _key = 'reminders';

  final SharedPreferences _preferences;
  final _notifications = FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _android => _notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  List<ReminderModel> getReminders() {
    final reminders = (_preferences.getStringList(_key) ?? [])
        .map((item) => ReminderModel.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
    return reminders..sort((a, b) => a.showTime.compareTo(b.showTime));
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await _android?.requestNotificationsPermission();
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final canScheduleExact = await _android?.canScheduleExactNotifications() ?? false;

    await _notifications.zonedSchedule(
      id: reminder.id,
      title: 'Movie reminder',
      body: '${reminder.movieTitle} at ${reminder.cinemaName} starts soon',
      scheduledDate: tz.TZDateTime.from(reminder.remindAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'movie_reminder',
          'Movie reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
    await _save([...getReminders(), reminder]);
  }

  Future<void> deleteReminder(int id) async {
    await _notifications.cancel(id: id);
    await _save(getReminders().where((reminder) => reminder.id != id).toList());
  }

  Future<void> _save(List<ReminderModel> reminders) {
    return _preferences.setStringList(
      _key,
      reminders.map((reminder) => jsonEncode(reminder.toJson())).toList(),
    );
  }
}
