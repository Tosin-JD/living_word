import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/screens/bible_home_screen.dart';
import 'src/providers/notification_providers.dart';
import 'src/providers/settings_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LivingWordApp()));
}

class LivingWordApp extends ConsumerWidget {
  const LivingWordApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsBootstrapProvider);
    ref.watch(notificationBootstrapProvider);
    ref.watch(readingPlanNotificationSyncProvider);
    final appTheme = ref.watch(appThemeDataProvider);

    return MaterialApp(
      title: 'Living Word',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      darkTheme: appTheme,
      themeMode: ThemeMode.light,
      home: const BibleHomeScreen(),
    );
  }
}
