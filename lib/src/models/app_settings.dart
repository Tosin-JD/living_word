import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, sepia, rose, paper, amoled }

enum VerseTextAlignment { left, justify }

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

enum NotificationDayMode { everyDay, weekdays, weekends, custom }

enum MemoryVerseMode { encouragementRandom, encouragementSequential, curated }

enum MemoryVerseCadence {
  defaultFourTimes,
  every30Minutes,
  hourly,
  every2Hours,
  onceDaily,
}

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
  final VerseTextAlignment verseTextAlignment;
  final bool readingMode;
  final bool autoScroll;
  final double autoScrollSpeed;

  // Notification settings
  final NotificationFrequency notificationFrequency;
  final Set<NotificationType> enabledNotifications;
  final NotificationTime notificationTime;
  final NotificationDayMode notificationDayMode;
  final Set<int> customNotificationWeekdays;
  final int customNotificationHour;
  final int customNotificationMinute;
  final int weeklyReminderWeekday;
  final List<int> prayerReminderMinutes;
  final int devotionalReminderHour;
  final int devotionalReminderMinute;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool silentNotifications;
  final bool readingPlanAlarmEnabled;
  final int readingPlanReminderStartHour;
  final int readingPlanReminderEndHour;

  // Memory verse
  final bool memoryVerseEnabled;
  final MemoryVerseCadence memoryVerseCadence;
  final int memoryVerseWindowStartHour;
  final int memoryVerseWindowStartMinute;
  final int memoryVerseWindowEndHour;
  final int memoryVerseWindowEndMinute;
  final MemoryVerseMode memoryVerseMode;
  final List<String> curatedMemoryVerseReferences;

  const AppSettings({
    this.themeMode = AppThemeMode.light,
    this.fontSize = 16.0,
    this.fontFamily = 'System',
    this.lineSpacing = 1.6,
    this.backgroundColor,
    this.textColor,
    this.defaultTranslation = 'HOLMAN CHRISTIAN STANDARD BIBLE.json',
    this.parallelTranslations = false,
    this.showVerseNumbers = true,
    this.verseTextAlignment = VerseTextAlignment.left,
    this.readingMode = false,
    this.autoScroll = false,
    this.autoScrollSpeed = 12.0,
    this.notificationFrequency = NotificationFrequency.off,
    this.enabledNotifications = const {},
    this.notificationTime = NotificationTime.morning,
    this.notificationDayMode = NotificationDayMode.everyDay,
    this.customNotificationWeekdays = const {
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    },
    this.customNotificationHour = 8,
    this.customNotificationMinute = 0,
    this.weeklyReminderWeekday = DateTime.monday,
    this.prayerReminderMinutes = const [360, 720, 1080],
    this.devotionalReminderHour = 8,
    this.devotionalReminderMinute = 0,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.silentNotifications = false,
    this.readingPlanAlarmEnabled = true,
    this.readingPlanReminderStartHour = 8,
    this.readingPlanReminderEndHour = 22,
    this.memoryVerseEnabled = false,
    this.memoryVerseCadence = MemoryVerseCadence.defaultFourTimes,
    this.memoryVerseWindowStartHour = 9,
    this.memoryVerseWindowStartMinute = 0,
    this.memoryVerseWindowEndHour = 18,
    this.memoryVerseWindowEndMinute = 0,
    this.memoryVerseMode = MemoryVerseMode.encouragementRandom,
    this.curatedMemoryVerseReferences = const [],
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
    VerseTextAlignment? verseTextAlignment,
    bool? readingMode,
    bool? autoScroll,
    double? autoScrollSpeed,
    NotificationFrequency? notificationFrequency,
    Set<NotificationType>? enabledNotifications,
    NotificationTime? notificationTime,
    NotificationDayMode? notificationDayMode,
    Set<int>? customNotificationWeekdays,
    int? customNotificationHour,
    int? customNotificationMinute,
    int? weeklyReminderWeekday,
    List<int>? prayerReminderMinutes,
    int? devotionalReminderHour,
    int? devotionalReminderMinute,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? silentNotifications,
    bool? readingPlanAlarmEnabled,
    int? readingPlanReminderStartHour,
    int? readingPlanReminderEndHour,
    bool? memoryVerseEnabled,
    MemoryVerseCadence? memoryVerseCadence,
    int? memoryVerseWindowStartHour,
    int? memoryVerseWindowStartMinute,
    int? memoryVerseWindowEndHour,
    int? memoryVerseWindowEndMinute,
    MemoryVerseMode? memoryVerseMode,
    List<String>? curatedMemoryVerseReferences,
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
      verseTextAlignment: verseTextAlignment ?? this.verseTextAlignment,
      readingMode: readingMode ?? this.readingMode,
      autoScroll: autoScroll ?? this.autoScroll,
      autoScrollSpeed: autoScrollSpeed ?? this.autoScrollSpeed,
      notificationFrequency:
          notificationFrequency ?? this.notificationFrequency,
      enabledNotifications: enabledNotifications ?? this.enabledNotifications,
      notificationTime: notificationTime ?? this.notificationTime,
      notificationDayMode: notificationDayMode ?? this.notificationDayMode,
      customNotificationWeekdays:
          customNotificationWeekdays ?? this.customNotificationWeekdays,
      customNotificationHour:
          customNotificationHour ?? this.customNotificationHour,
      customNotificationMinute:
          customNotificationMinute ?? this.customNotificationMinute,
      weeklyReminderWeekday:
          weeklyReminderWeekday ?? this.weeklyReminderWeekday,
      prayerReminderMinutes:
          prayerReminderMinutes ?? this.prayerReminderMinutes,
      devotionalReminderHour:
          devotionalReminderHour ?? this.devotionalReminderHour,
      devotionalReminderMinute:
          devotionalReminderMinute ?? this.devotionalReminderMinute,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      silentNotifications: silentNotifications ?? this.silentNotifications,
      readingPlanAlarmEnabled:
          readingPlanAlarmEnabled ?? this.readingPlanAlarmEnabled,
      readingPlanReminderStartHour:
          readingPlanReminderStartHour ?? this.readingPlanReminderStartHour,
      readingPlanReminderEndHour:
          readingPlanReminderEndHour ?? this.readingPlanReminderEndHour,
      memoryVerseEnabled: memoryVerseEnabled ?? this.memoryVerseEnabled,
      memoryVerseCadence: memoryVerseCadence ?? this.memoryVerseCadence,
      memoryVerseWindowStartHour:
          memoryVerseWindowStartHour ?? this.memoryVerseWindowStartHour,
      memoryVerseWindowStartMinute:
          memoryVerseWindowStartMinute ?? this.memoryVerseWindowStartMinute,
      memoryVerseWindowEndHour:
          memoryVerseWindowEndHour ?? this.memoryVerseWindowEndHour,
      memoryVerseWindowEndMinute:
          memoryVerseWindowEndMinute ?? this.memoryVerseWindowEndMinute,
      memoryVerseMode: memoryVerseMode ?? this.memoryVerseMode,
      curatedMemoryVerseReferences:
          curatedMemoryVerseReferences ?? this.curatedMemoryVerseReferences,
    );
  }
}
