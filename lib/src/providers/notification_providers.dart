import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../services/memory_verse_service.dart';
import '../services/local_notification_service.dart';
import 'bible_providers.dart';
import 'reading_plan_providers.dart';
import 'settings_providers.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return LocalNotificationService();
});

final memoryVerseServiceProvider = Provider<MemoryVerseService>((ref) {
  final repository = ref.watch(bibleRepositoryProvider);
  return MemoryVerseService(repository);
});

/// Initializes local notifications and keeps scheduled reminders in sync.
final notificationBootstrapProvider = Provider<void>((ref) {
  final service = ref.watch(localNotificationServiceProvider);

  unawaited(service.initialize());

  ref.listen<AppSettings>(appSettingsProvider, (_, next) {
    unawaited(service.syncWithSettings(next));
  });
});

final readingPlanNotificationSyncProvider = Provider<void>((ref) {
  final service = ref.watch(localNotificationServiceProvider);
  final memoryVerseService = ref.watch(memoryVerseServiceProvider);

  Future<void> sync() async {
    final settings = ref.read(appSettingsProvider);
    final planState = ref.read(readingPlanControllerProvider);

    await service.syncReadingPlanHourlyReminder(
      settings: settings,
      activePlans: planState.activePlans,
      readChapterKeys: planState.readChapterKeys,
    );

    final items = <MemoryVerseScheduleItem>[];
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day);

    for (var dayOffset = 0; dayOffset < 30; dayOffset++) {
      final day = startDay.add(Duration(days: dayOffset));
      final moments = _memoryMomentsForDay(day, settings);
      for (var slot = 0; slot < moments.length; slot++) {
        final scheduledAt = moments[slot];
        if (!scheduledAt.isAfter(now)) continue;

        final verse = await memoryVerseService.getVerseForMoment(
          moment: scheduledAt,
          slotIndex: slot,
          settings: settings,
        );
        if (verse == null) continue;

        items.add(
          MemoryVerseScheduleItem(
            scheduledAt: scheduledAt,
            body: verse.toNotificationBody(),
          ),
        );
      }
    }

    await service.syncMemoryVerseReminders(settings: settings, items: items);
  }

  Future.microtask(() {
    unawaited(sync());
  });

  ref.listen<AppSettings>(appSettingsProvider, (_, __) {
    unawaited(sync());
  });

  ref.listen<ReadingPlanState>(readingPlanControllerProvider, (_, __) {
    unawaited(sync());
  });
});

List<DateTime> _memoryMomentsForDay(DateTime day, AppSettings settings) {
  DateTime at(int hour, int minute) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  switch (settings.memoryVerseCadence) {
    case MemoryVerseCadence.defaultFourTimes:
      return [at(9, 0), at(12, 0), at(15, 0), at(18, 0)];
    case MemoryVerseCadence.onceDaily:
      return [
        at(
          settings.memoryVerseWindowStartHour,
          settings.memoryVerseWindowStartMinute,
        ),
      ];
    case MemoryVerseCadence.every30Minutes:
      return _intervalMomentsForDay(day, settings, 30);
    case MemoryVerseCadence.hourly:
      return _intervalMomentsForDay(day, settings, 60);
    case MemoryVerseCadence.every2Hours:
      return _intervalMomentsForDay(day, settings, 120);
  }
}

List<DateTime> _intervalMomentsForDay(
  DateTime day,
  AppSettings settings,
  int intervalMinutes,
) {
  var start = DateTime(
    day.year,
    day.month,
    day.day,
    settings.memoryVerseWindowStartHour,
    settings.memoryVerseWindowStartMinute,
  );
  final end = DateTime(
    day.year,
    day.month,
    day.day,
    settings.memoryVerseWindowEndHour,
    settings.memoryVerseWindowEndMinute,
  );

  if (!end.isAfter(start)) {
    start = DateTime(day.year, day.month, day.day, 9, 0);
  }
  final safeEnd = end.isAfter(start)
      ? end
      : DateTime(day.year, day.month, day.day, 18, 0);

  final items = <DateTime>[];
  var cursor = start;
  while (!cursor.isAfter(safeEnd)) {
    items.add(cursor);
    cursor = cursor.add(Duration(minutes: intervalMinutes));
  }

  return items;
}
