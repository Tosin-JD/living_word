import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';

// Settings state provider
final appSettingsProvider = StateProvider<AppSettings>((ref) {
  return const AppSettings();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsBootstrapProvider = Provider<void>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  var loaded = false;

  Future.microtask(() async {
    final loadedSettings = await repository.load();
    ref.read(appSettingsProvider.notifier).state = loadedSettings;
    loaded = true;
  });

  ref.listen<AppSettings>(appSettingsProvider, (_, next) {
    if (!loaded) return;
    repository.save(next);
  });
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

final readingModeProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).readingMode;
});
