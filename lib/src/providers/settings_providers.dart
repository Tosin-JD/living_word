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

final appThemeDataProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(appSettingsProvider);
  const neutralAccent = Color(0xFF6B7280);

  ThemeData themed({
    required Brightness brightness,
    required Color seed,
    Color? scaffoldBackground,
    Color? surface,
  }) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: neutralAccent,
        secondary: neutralAccent,
        surface: surface ?? base.colorScheme.surface,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: surface ?? base.colorScheme.surface,
      ),
    );
  }

  switch (settings.themeMode) {
    case AppThemeMode.light:
      return themed(brightness: Brightness.light, seed: neutralAccent);
    case AppThemeMode.dark:
      return themed(brightness: Brightness.dark, seed: neutralAccent);
    case AppThemeMode.sepia:
      return themed(
        brightness: Brightness.light,
        seed: const Color(0xFF8B6A3E),
        scaffoldBackground: const Color(0xFFF6E9C9),
        surface: const Color(0xFFFBF2DF),
      );
    case AppThemeMode.rose:
      return themed(
        brightness: Brightness.light,
        seed: const Color(0xFFB1497A),
        scaffoldBackground: const Color(0xFFFDF0F5),
        surface: const Color(0xFFFFFFFF),
      );
    case AppThemeMode.paper:
      return themed(
        brightness: Brightness.light,
        seed: const Color(0xFF5A6B7A),
        scaffoldBackground: const Color(0xFFF7F7F2),
        surface: const Color(0xFFFFFFFF),
      );
    case AppThemeMode.amoled:
      return themed(
        brightness: Brightness.dark,
        seed: neutralAccent,
        scaffoldBackground: Colors.black,
        surface: Colors.black,
      );
  }
});

// Individual setting providers for easier access
final showVerseNumbersProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).showVerseNumbers;
});

final readingModeProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).readingMode;
});
