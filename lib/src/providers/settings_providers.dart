import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/app_settings.dart';

// Settings state provider
final appSettingsProvider = StateProvider<AppSettings>((ref) {
  return const AppSettings();
});

// Theme mode provider derived from settings
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(appSettingsProvider);

  switch (settings.themeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

// Individual setting providers for easier access
final showVerseNumbersProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).showVerseNumbers;
});

final showChapterHeadingsProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).showChapterHeadings;
});

final readingModeProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).readingMode;
});
