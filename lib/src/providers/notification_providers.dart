import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../services/local_notification_service.dart';
import 'reading_plan_providers.dart';
import 'settings_providers.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return LocalNotificationService();
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

  Future<void> sync() async {
    final settings = ref.read(appSettingsProvider);
    final planState = ref.read(readingPlanControllerProvider);

    await service.syncReadingPlanHourlyReminder(
      settings: settings,
      activePlans: planState.activePlans,
      readChapterKeys: planState.readChapterKeys,
    );
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
