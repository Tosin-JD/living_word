import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsRepository {
  static const _settingsKey = 'app_settings_v1';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return const AppSettings();

    final json = jsonDecode(raw) as Map<String, dynamic>;

    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (item) => item.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      fontFamily: json['fontFamily'] as String? ?? 'System',
      lineSpacing: (json['lineSpacing'] as num?)?.toDouble() ?? 1.6,
      defaultTranslation:
          json['defaultTranslation'] as String? ??
          'HOLMAN CHRISTIAN STANDARD BIBLE.json',
      parallelTranslations: json['parallelTranslations'] as bool? ?? false,
      showVerseNumbers: json['showVerseNumbers'] as bool? ?? true,
      readingMode: json['readingMode'] as bool? ?? false,
      autoScroll: json['autoScroll'] as bool? ?? false,
      autoScrollSpeed: (json['autoScrollSpeed'] as num?)?.toDouble() ?? 12.0,
      notificationFrequency: NotificationFrequency.values.firstWhere(
        (item) => item.name == json['notificationFrequency'],
        orElse: () => NotificationFrequency.off,
      ),
      enabledNotifications:
          ((json['enabledNotifications'] as List<dynamic>? ?? <dynamic>[])
                  .map((item) => item as String)
                  .map(
                    (name) => NotificationType.values.firstWhere(
                      (type) => type.name == name,
                      orElse: () => NotificationType.dailyVerse,
                    ),
                  ))
              .toSet(),
      notificationTime: NotificationTime.values.firstWhere(
        (item) => item.name == json['notificationTime'],
        orElse: () => NotificationTime.morning,
      ),
      customNotificationHour: json['customNotificationHour'] as int? ?? 8,
      customNotificationMinute: json['customNotificationMinute'] as int? ?? 0,
      weeklyReminderWeekday:
          json['weeklyReminderWeekday'] as int? ?? DateTime.monday,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      silentNotifications: json['silentNotifications'] as bool? ?? false,
      readingPlanAlarmEnabled: json['readingPlanAlarmEnabled'] as bool? ?? true,
      readingPlanReminderStartHour:
          json['readingPlanReminderStartHour'] as int? ?? 8,
      readingPlanReminderEndHour:
          json['readingPlanReminderEndHour'] as int? ?? 22,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    final json = <String, dynamic>{
      'themeMode': settings.themeMode.name,
      'fontSize': settings.fontSize,
      'fontFamily': settings.fontFamily,
      'lineSpacing': settings.lineSpacing,
      'defaultTranslation': settings.defaultTranslation,
      'parallelTranslations': settings.parallelTranslations,
      'showVerseNumbers': settings.showVerseNumbers,
      'readingMode': settings.readingMode,
      'autoScroll': settings.autoScroll,
      'autoScrollSpeed': settings.autoScrollSpeed,
      'notificationFrequency': settings.notificationFrequency.name,
      'enabledNotifications': settings.enabledNotifications
          .map((item) => item.name)
          .toList(),
      'notificationTime': settings.notificationTime.name,
      'customNotificationHour': settings.customNotificationHour,
      'customNotificationMinute': settings.customNotificationMinute,
      'weeklyReminderWeekday': settings.weeklyReminderWeekday,
      'soundEnabled': settings.soundEnabled,
      'vibrationEnabled': settings.vibrationEnabled,
      'silentNotifications': settings.silentNotifications,
      'readingPlanAlarmEnabled': settings.readingPlanAlarmEnabled,
      'readingPlanReminderStartHour': settings.readingPlanReminderStartHour,
      'readingPlanReminderEndHour': settings.readingPlanReminderEndHour,
    };

    await prefs.setString(_settingsKey, jsonEncode(json));
  }
}
