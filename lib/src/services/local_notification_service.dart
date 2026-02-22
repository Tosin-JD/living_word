import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings.dart';
import '../models/reading_plan.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  final service = LocalNotificationService();
  service.handleNotificationResponse(response);
}

class LocalNotificationService {
  LocalNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'living_word_reminders';
  static const String _channelName = 'Living Word Reminders';
  static const String _channelDescription =
      'Offline daily and weekly reminders for reading and devotion.';

  static const String _readingCategoryId = 'reading_plan_reminder_actions';

  static const String _actionPause2h = 'reading_pause_2h';
  static const String _actionPause3h = 'reading_pause_3h';
  static const String _actionPause4h = 'reading_pause_4h';
  static const String _actionPause6h = 'reading_pause_6h';
  static const String _actionPauseToday = 'reading_pause_today';

  static const int _readingReminderIdStart = 5000;
  static const int _readingReminderIdEnd = 5060;
  static const int _memoryVerseIdStart = 7000;
  static const int _memoryVerseIdEnd = 7999;

  static const String _prefPauseUntil = 'reading_plan_pause_until_v1';
  static const String _prefPauseDate = 'reading_plan_pause_date_v1';
  static const String _prefStartHour = 'reading_plan_start_hour_v1';
  static const String _prefEndHour = 'reading_plan_end_hour_v1';
  static const String _prefSoundEnabled = 'reading_plan_sound_enabled_v1';
  static const String _prefVibrationEnabled =
      'reading_plan_vibration_enabled_v1';
  static const String _prefSilent = 'reading_plan_silent_v1';
  static const String _prefBody = 'reading_plan_body_v1';

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          _readingCategoryId,
          actions: [
            DarwinNotificationAction.plain(_actionPause2h, 'Pause 2h'),
            DarwinNotificationAction.plain(_actionPause3h, 'Pause 3h'),
            DarwinNotificationAction.plain(_actionPause4h, 'Pause 4h'),
            DarwinNotificationAction.plain(_actionPause6h, 'Pause 6h'),
            DarwinNotificationAction.plain(_actionPauseToday, 'Pause today'),
          ],
        ),
      ],
    );

    await _plugin.initialize(
      InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _initialized = true;
  }

  Future<void> handleNotificationResponse(NotificationResponse response) async {
    await initialize();

    switch (response.actionId) {
      case _actionPause2h:
        await _pauseReadingPlanReminders(hours: 2);
        break;
      case _actionPause3h:
        await _pauseReadingPlanReminders(hours: 3);
        break;
      case _actionPause4h:
        await _pauseReadingPlanReminders(hours: 4);
        break;
      case _actionPause6h:
        await _pauseReadingPlanReminders(hours: 6);
        break;
      case _actionPauseToday:
        await _pauseReadingPlanForToday();
        break;
      default:
        break;
    }
  }

  Future<void> syncWithSettings(AppSettings settings) async {
    await initialize();

    if (settings.notificationFrequency == NotificationFrequency.off ||
        settings.enabledNotifications.isEmpty) {
      await cancelAllScheduled();
      return;
    }

    final nonReadingTypes =
        settings.enabledNotifications
            .where((item) => item != NotificationType.readingPlanReminder)
            .toList()
          ..sort((a, b) => a.index.compareTo(b.index));

    for (final type in nonReadingTypes) {
      await _plugin.cancel(_notificationId(type));
    }

    final time = _resolveNotificationTime(settings);

    for (var index = 0; index < nonReadingTypes.length; index++) {
      final type = nonReadingTypes[index];

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

  Future<void> syncReadingPlanHourlyReminder({
    required AppSettings settings,
    required List<ReadingPlan> activePlans,
    required Set<String> readChapterKeys,
  }) async {
    await initialize();
    await _cancelReadingPlanReminderIds();

    final enabled =
        settings.notificationFrequency != NotificationFrequency.off &&
        settings.enabledNotifications.contains(
          NotificationType.readingPlanReminder,
        ) &&
        settings.readingPlanAlarmEnabled;

    if (!enabled || activePlans.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final pauseToday = await _isPausedForToday(now);
    if (pauseToday) {
      return;
    }

    final pauseUntil = await _getPauseUntil();

    final plan = activePlans.first;
    final todayReading = _resolveTodaysReading(plan, readChapterKeys);
    if (todayReading == null || todayReading.isCompleted) {
      await _clearReadingPauseState();
      return;
    }

    final reminderBody = _buildReadingReminderBody(
      todayReading.day.chapterRefs,
    );

    await _persistReadingPlanContext(settings: settings, body: reminderBody);

    final startOfWindow = DateTime(
      now.year,
      now.month,
      now.day,
      settings.readingPlanReminderStartHour,
    );
    final endOfWindow = DateTime(
      now.year,
      now.month,
      now.day,
      settings.readingPlanReminderEndHour,
    );

    final baseline = _nextHour(now.add(const Duration(minutes: 1)));
    var nextRun = baseline.isAfter(startOfWindow) ? baseline : startOfWindow;

    if (pauseUntil != null && pauseUntil.isAfter(nextRun)) {
      nextRun = _nextHour(pauseUntil);
    }

    await _scheduleReadingPlanSlots(
      startAt: nextRun,
      endAt: endOfWindow,
      body: reminderBody,
      settings: settings,
    );
  }

  Future<void> syncMemoryVerseReminders({
    required AppSettings settings,
    required List<MemoryVerseScheduleItem> items,
  }) async {
    await initialize();
    await _cancelMemoryVerseReminderIds();

    if (!settings.memoryVerseEnabled || items.isEmpty) {
      return;
    }

    final now = DateTime.now();
    var id = _memoryVerseIdStart;

    for (final item in items) {
      if (id > _memoryVerseIdEnd) break;
      if (!item.scheduledAt.isAfter(now)) continue;

      await _plugin.zonedSchedule(
        id,
        'Memory verse',
        item.body,
        tz.TZDateTime.from(item.scheduledAt, tz.local),
        _buildDetails(settings),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      id++;
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

  Future<void> _pauseReadingPlanReminders({required int hours}) async {
    final pauseUntil = DateTime.now().add(Duration(hours: hours));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefPauseUntil, pauseUntil.toIso8601String());
    await prefs.remove(_prefPauseDate);

    await _cancelReadingPlanReminderIds();

    final context = await _readStoredReadingPlanContext();
    if (context == null) return;

    await _scheduleReadingPlanSlots(
      startAt: _nextHour(pauseUntil),
      endAt: DateTime(
        pauseUntil.year,
        pauseUntil.month,
        pauseUntil.day,
        context.endHour,
      ),
      body: context.body,
      settings: context.settings,
    );
  }

  Future<void> _pauseReadingPlanForToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefPauseDate, today);
    await prefs.remove(_prefPauseUntil);
    await _cancelReadingPlanReminderIds();
  }

  Future<bool> _isPausedForToday(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefPauseDate);
    if (raw == null) return false;

    final pausedDate = DateTime.tryParse(raw);
    if (pausedDate == null) return false;

    final today = DateTime(now.year, now.month, now.day);
    return pausedDate == today;
  }

  Future<DateTime?> _getPauseUntil() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefPauseUntil);
    if (raw == null || raw.isEmpty) return null;

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    if (parsed.isBefore(DateTime.now())) {
      await prefs.remove(_prefPauseUntil);
      return null;
    }

    return parsed;
  }

  Future<void> _clearReadingPauseState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefPauseDate);
    await prefs.remove(_prefPauseUntil);
  }

  Future<void> _persistReadingPlanContext({
    required AppSettings settings,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefStartHour, settings.readingPlanReminderStartHour);
    await prefs.setInt(_prefEndHour, settings.readingPlanReminderEndHour);
    await prefs.setBool(_prefSoundEnabled, settings.soundEnabled);
    await prefs.setBool(_prefVibrationEnabled, settings.vibrationEnabled);
    await prefs.setBool(_prefSilent, settings.silentNotifications);
    await prefs.setString(_prefBody, body);
  }

  Future<_StoredReadingContext?> _readStoredReadingPlanContext() async {
    final prefs = await SharedPreferences.getInstance();
    final endHour = prefs.getInt(_prefEndHour);
    if (endHour == null) return null;

    final body =
        prefs.getString(_prefBody) ?? 'Continue your reading plan for today.';

    final settings = AppSettings(
      soundEnabled: prefs.getBool(_prefSoundEnabled) ?? true,
      vibrationEnabled: prefs.getBool(_prefVibrationEnabled) ?? true,
      silentNotifications: prefs.getBool(_prefSilent) ?? false,
      readingPlanReminderStartHour: prefs.getInt(_prefStartHour) ?? 8,
      readingPlanReminderEndHour: endHour,
    );

    return _StoredReadingContext(
      endHour: endHour,
      body: body,
      settings: settings,
    );
  }

  Future<void> _scheduleReadingPlanSlots({
    required DateTime startAt,
    required DateTime endAt,
    required String body,
    required AppSettings settings,
  }) async {
    if (!startAt.isBefore(endAt) && !startAt.isAtSameMomentAs(endAt)) {
      return;
    }

    var id = _readingReminderIdStart;
    var current = startAt;

    while (!current.isAfter(endAt) && id <= _readingReminderIdEnd) {
      await _plugin.zonedSchedule(
        id,
        'Reading plan reminder',
        body,
        tz.TZDateTime.from(current, tz.local),
        _buildReadingReminderDetails(settings),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      id++;
      current = current.add(const Duration(hours: 1));
    }
  }

  Future<void> _cancelReadingPlanReminderIds() async {
    for (var id = _readingReminderIdStart; id <= _readingReminderIdEnd; id++) {
      await _plugin.cancel(id);
    }
  }

  Future<void> _cancelMemoryVerseReminderIds() async {
    for (var id = _memoryVerseIdStart; id <= _memoryVerseIdEnd; id++) {
      await _plugin.cancel(id);
    }
  }

  _TodayReading? _resolveTodaysReading(
    ReadingPlan plan,
    Set<String> readChapterKeys,
  ) {
    if (plan.days.isEmpty) return null;

    final created = DateTime(
      plan.createdAt.year,
      plan.createdAt.month,
      plan.createdAt.day,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var dayNumber = today.difference(created).inDays + 1;
    if (dayNumber < 1) dayNumber = 1;
    if (dayNumber > plan.durationDays) dayNumber = plan.durationDays;

    ReadingPlanDay? todayDay;
    for (final day in plan.days) {
      if (day.dayNumber == dayNumber) {
        todayDay = day;
        break;
      }
    }

    todayDay ??= plan.days.first;

    final completed =
        todayDay.chapterRefs.isNotEmpty &&
        todayDay.chapterRefs.every((ref) => readChapterKeys.contains(ref.key));

    return _TodayReading(day: todayDay, isCompleted: completed);
  }

  String _buildReadingReminderBody(List<ChapterRef> refs) {
    if (refs.isEmpty) {
      return 'Continue your reading plan for today.';
    }

    final chapterList = refs
        .take(2)
        .map((ref) => '${ref.bookName} ${ref.chapter}')
        .join(', ');

    if (refs.length <= 2) {
      return 'Today\'s chapter: $chapterList';
    }

    return 'Today\'s chapters: $chapterList +${refs.length - 2} more';
  }

  DateTime _nextHour(DateTime value) {
    final floored = DateTime(value.year, value.month, value.day, value.hour);
    if (value.isAtSameMomentAs(floored)) return value;
    return floored.add(const Duration(hours: 1));
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

  NotificationDetails _buildReadingReminderDetails(AppSettings settings) {
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
            : Importance.max,
        priority: settings.silentNotifications ? Priority.low : Priority.max,
        playSound: playSound,
        enableVibration: enableVibration,
        actions: const [
          AndroidNotificationAction(_actionPause2h, 'Pause 2h'),
          AndroidNotificationAction(_actionPause3h, 'Pause 3h'),
          AndroidNotificationAction(_actionPause4h, 'Pause 4h'),
          AndroidNotificationAction(_actionPause6h, 'Pause 6h'),
          AndroidNotificationAction(_actionPauseToday, 'Pause today'),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
        categoryIdentifier: _readingCategoryId,
      ),
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

class _TodayReading {
  final ReadingPlanDay day;
  final bool isCompleted;

  const _TodayReading({required this.day, required this.isCompleted});
}

class _StoredReadingContext {
  final int endHour;
  final String body;
  final AppSettings settings;

  const _StoredReadingContext({
    required this.endHour,
    required this.body,
    required this.settings,
  });
}

class MemoryVerseScheduleItem {
  final DateTime scheduledAt;
  final String body;

  const MemoryVerseScheduleItem({
    required this.scheduledAt,
    required this.body,
  });
}
