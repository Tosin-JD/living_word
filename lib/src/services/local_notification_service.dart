import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings.dart';

class LocalNotificationService {
  LocalNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'living_word_reminders';
  static const String _channelName = 'Living Word Reminders';
  static const String _channelDescription =
      'Offline daily and weekly reminders for reading and devotion.';

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  Future<void> syncWithSettings(AppSettings settings) async {
    await initialize();

    if (settings.notificationFrequency == NotificationFrequency.off ||
        settings.enabledNotifications.isEmpty) {
      await cancelAllScheduled();
      return;
    }

    await cancelAllScheduled();

    final time = _resolveNotificationTime(settings);
    final types = settings.enabledNotifications.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    for (var index = 0; index < types.length; index++) {
      final type = types[index];

      final minuteWithOffset = (time.minute + index) % 60;
      final hourOffset = (time.minute + index) ~/ 60;
      final hourWithOffset = (time.hour + hourOffset) % 24;

      if (settings.notificationFrequency == NotificationFrequency.weekly) {
        await _scheduleWeeklyNotification(
          id: _notificationId(type),
          title: _titleForType(type),
          body: _bodyForType(type),
          weekday: settings.weeklyReminderWeekday,
          hour: hourWithOffset,
          minute: minuteWithOffset,
          settings: settings,
        );
      } else {
        await _scheduleDailyNotification(
          id: _notificationId(type),
          title: _titleForType(type),
          body: _bodyForType(type),
          hour: hourWithOffset,
          minute: minuteWithOffset,
          settings: settings,
        );
      }
    }
  }

  Future<void> showTestNotification(AppSettings settings) async {
    await initialize();
    await requestPermissions();

    await _plugin.show(
      999,
      'Living Word Test',
      'Notifications are active on this device.',
      _buildDetails(settings),
    );
  }

  Future<void> cancelAllScheduled() async {
    await initialize();
    await _plugin.cancelAll();
  }

  Future<void> requestPermissions() async {
    await initialize();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required AppSettings settings,
  }) async {
    final scheduledDate = _nextDailyDate(hour: hour, minute: minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _buildDetails(settings),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    required AppSettings settings,
  }) async {
    final scheduledDate = _nextWeeklyDate(
      weekday: weekday,
      hour: hour,
      minute: minute,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _buildDetails(settings),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  NotificationDetails _buildDetails(AppSettings settings) {
    final playSound = !settings.silentNotifications && settings.soundEnabled;
    final enableVibration =
        !settings.silentNotifications && settings.vibrationEnabled;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: settings.silentNotifications
            ? Importance.low
            : Importance.high,
        priority: settings.silentNotifications ? Priority.low : Priority.high,
        playSound: playSound,
        enableVibration: enableVibration,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
      ),
    );
  }

  TimeOfDay _resolveNotificationTime(AppSettings settings) {
    if (settings.notificationTime == NotificationTime.custom) {
      return TimeOfDay(
        hour: settings.customNotificationHour,
        minute: settings.customNotificationMinute,
      );
    }

    switch (settings.notificationTime) {
      case NotificationTime.morning:
        return const TimeOfDay(hour: 8, minute: 0);
      case NotificationTime.afternoon:
        return const TimeOfDay(hour: 13, minute: 0);
      case NotificationTime.evening:
        return const TimeOfDay(hour: 19, minute: 0);
      case NotificationTime.custom:
        return TimeOfDay(
          hour: settings.customNotificationHour,
          minute: settings.customNotificationMinute,
        );
    }
  }

  tz.TZDateTime _nextDailyDate({required int hour, required int minute}) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    return next;
  }

  tz.TZDateTime _nextWeeklyDate({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (next.weekday != weekday || !next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    return next;
  }

  int _notificationId(NotificationType type) {
    switch (type) {
      case NotificationType.dailyVerse:
        return 100;
      case NotificationType.readingPlanReminder:
        return 101;
      case NotificationType.prayerReminder:
        return 102;
      case NotificationType.devotionalReminder:
        return 103;
      case NotificationType.specialEvents:
        return 104;
      case NotificationType.appUpdates:
        return 105;
    }
  }

  String _titleForType(NotificationType type) {
    switch (type) {
      case NotificationType.dailyVerse:
        return 'Daily Verse';
      case NotificationType.readingPlanReminder:
        return 'Reading Plan Reminder';
      case NotificationType.prayerReminder:
        return 'Prayer Reminder';
      case NotificationType.devotionalReminder:
        return 'Devotional Reminder';
      case NotificationType.specialEvents:
        return 'Special Reminder';
      case NotificationType.appUpdates:
        return 'Living Word Update';
    }
  }

  String _bodyForType(NotificationType type) {
    switch (type) {
      case NotificationType.dailyVerse:
        return 'Take a moment to read and reflect on today\'s verse.';
      case NotificationType.readingPlanReminder:
        return 'Continue your reading plan and keep your streak alive.';
      case NotificationType.prayerReminder:
        return 'Set aside time now for prayer.';
      case NotificationType.devotionalReminder:
        return 'Your devotional moment is ready.';
      case NotificationType.specialEvents:
        return 'Check in for a special reading and reflection.';
      case NotificationType.appUpdates:
        return 'Open Living Word for your latest Bible reading tools.';
    }
  }
}
