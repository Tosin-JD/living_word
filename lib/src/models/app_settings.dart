import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

enum NotificationFrequency { daily, weekly, custom, off }

enum NotificationType {
  dailyVerse,
  readingPlanReminder,
  prayerReminder,
  devotionalReminder,
  specialEvents,
  appUpdates,
}

enum NotificationTime { morning, afternoon, evening, custom }

class AppSettings {
  // Theme settings
  final AppThemeMode themeMode;
  final double fontSize;
  final String fontFamily;
  final double lineSpacing;
  final Color? backgroundColor;
  final Color? textColor;

  // Reading experience
  final String defaultTranslation;
  final bool parallelTranslations;
  final bool showVerseNumbers;
  final bool readingMode;
  final bool autoScroll;
  final double autoScrollSpeed;

  // Notification settings
  final NotificationFrequency notificationFrequency;
  final Set<NotificationType> enabledNotifications;
  final NotificationTime notificationTime;
  final int customNotificationHour;
  final int customNotificationMinute;
  final int weeklyReminderWeekday;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool silentNotifications;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.fontSize = 16.0,
    this.fontFamily = 'System',
    this.lineSpacing = 1.6,
    this.backgroundColor,
    this.textColor,
    this.defaultTranslation = 'HOLMAN CHRISTIAN STANDARD BIBLE.json',
    this.parallelTranslations = false,
    this.showVerseNumbers = true,
    this.readingMode = false,
    this.autoScroll = false,
    this.autoScrollSpeed = 12.0,
    this.notificationFrequency = NotificationFrequency.off,
    this.enabledNotifications = const {},
    this.notificationTime = NotificationTime.morning,
    this.customNotificationHour = 8,
    this.customNotificationMinute = 0,
    this.weeklyReminderWeekday = DateTime.monday,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.silentNotifications = false,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    double? fontSize,
    String? fontFamily,
    double? lineSpacing,
    Color? backgroundColor,
    Color? textColor,
    String? defaultTranslation,
    bool? parallelTranslations,
    bool? showVerseNumbers,
    bool? readingMode,
    bool? autoScroll,
    double? autoScrollSpeed,
    NotificationFrequency? notificationFrequency,
    Set<NotificationType>? enabledNotifications,
    NotificationTime? notificationTime,
    int? customNotificationHour,
    int? customNotificationMinute,
    int? weeklyReminderWeekday,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? silentNotifications,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      defaultTranslation: defaultTranslation ?? this.defaultTranslation,
      parallelTranslations: parallelTranslations ?? this.parallelTranslations,
      showVerseNumbers: showVerseNumbers ?? this.showVerseNumbers,
      readingMode: readingMode ?? this.readingMode,
      autoScroll: autoScroll ?? this.autoScroll,
      autoScrollSpeed: autoScrollSpeed ?? this.autoScrollSpeed,
      notificationFrequency:
          notificationFrequency ?? this.notificationFrequency,
      enabledNotifications: enabledNotifications ?? this.enabledNotifications,
      notificationTime: notificationTime ?? this.notificationTime,
      customNotificationHour:
          customNotificationHour ?? this.customNotificationHour,
      customNotificationMinute:
          customNotificationMinute ?? this.customNotificationMinute,
      weeklyReminderWeekday:
          weeklyReminderWeekday ?? this.weeklyReminderWeekday,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      silentNotifications: silentNotifications ?? this.silentNotifications,
    );
  }
}
