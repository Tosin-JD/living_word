import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../services/local_notification_service.dart';
import 'settings_providers.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return LocalNotificationService();
});

/// Initializes local notifications and keeps scheduled reminders in sync.
final notificationBootstrapProvider = Provider<void>((ref) {
  final service = ref.watch(localNotificationServiceProvider);
  final initialSettings = ref.read(appSettingsProvider);

  unawaited(service.initialize());
  unawaited(service.syncWithSettings(initialSettings));

  ref.listen<AppSettings>(appSettingsProvider, (_, next) {
    unawaited(service.syncWithSettings(next));
  });
});
