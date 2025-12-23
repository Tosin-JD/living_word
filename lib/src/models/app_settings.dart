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
  final bool redLetterText;

  // Reading experience
  final String defaultTranslation;
  final bool parallelTranslations;
  final bool showVerseNumbers;
  final bool showChapterHeadings;
  final bool showCrossReferences;
  final bool showFootnotes;
  final bool readingMode;
  final bool autoScroll;

  // Notification settings
  final NotificationFrequency notificationFrequency;
  final Set<NotificationType> enabledNotifications;
  final NotificationTime notificationTime;
  final NotificationTime? customTime;
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
    this.redLetterText = false,
    this.defaultTranslation = 'HOLMAN CHRISTIAN STANDARD BIBLE.json',
    this.parallelTranslations = false,
    this.showVerseNumbers = true,
    this.showChapterHeadings = true,
    this.showCrossReferences = false,
    this.showFootnotes = false,
    this.readingMode = false,
    this.autoScroll = false,
    this.notificationFrequency = NotificationFrequency.off,
    this.enabledNotifications = const {},
    this.notificationTime = NotificationTime.morning,
    this.customTime,
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
    bool? redLetterText,
    String? defaultTranslation,
    bool? parallelTranslations,
    bool? showVerseNumbers,
    bool? showChapterHeadings,
    bool? showCrossReferences,
    bool? showFootnotes,
    bool? readingMode,
    bool? autoScroll,
    NotificationFrequency? notificationFrequency,
    Set<NotificationType>? enabledNotifications,
    NotificationTime? notificationTime,
    NotificationTime? customTime,
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
      redLetterText: redLetterText ?? this.redLetterText,
      defaultTranslation: defaultTranslation ?? this.defaultTranslation,
      parallelTranslations: parallelTranslations ?? this.parallelTranslations,
      showVerseNumbers: showVerseNumbers ?? this.showVerseNumbers,
      showChapterHeadings: showChapterHeadings ?? this.showChapterHeadings,
      showCrossReferences: showCrossReferences ?? this.showCrossReferences,
      showFootnotes: showFootnotes ?? this.showFootnotes,
      readingMode: readingMode ?? this.readingMode,
      autoScroll: autoScroll ?? this.autoScroll,
      notificationFrequency:
          notificationFrequency ?? this.notificationFrequency,
      enabledNotifications: enabledNotifications ?? this.enabledNotifications,
      notificationTime: notificationTime ?? this.notificationTime,
      customTime: customTime ?? this.customTime,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      silentNotifications: silentNotifications ?? this.silentNotifications,
    );
  }
}
