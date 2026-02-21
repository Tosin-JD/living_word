import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../providers/settings_providers.dart';
import 'reading_plan_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const SettingsContent(),
    );
  }
}

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final halfHeight = MediaQuery.of(context).size.height * 0.5;

    return SafeArea(
      top: false,
      bottom: false,
      child: SizedBox(
        height: halfHeight,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Settings'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Divider(height: 1),
              const Expanded(child: SettingsContent()),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return ListView(
      children: [
        _buildSectionHeader('Live Reader Controls', Icons.play_circle_outline),
        _buildFontSizeSlider(context, ref, settings),
        _buildFontStyleSelector(context, ref, settings),
        _buildLineSpacingSlider(context, ref, settings),
        _buildToggleTile(
          title: 'Show verse numbers',
          subtitle: 'Display verse numbers beside text',
          value: settings.showVerseNumbers,
          icon: Icons.numbers,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).state = settings.copyWith(
              showVerseNumbers: value,
            );
          },
        ),
        _buildToggleTile(
          title: 'Reading mode',
          subtitle: 'Distraction-free reading',
          value: settings.readingMode,
          icon: Icons.auto_stories,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).state = settings.copyWith(
              readingMode: value,
            );
          },
        ),
        _buildToggleTile(
          title: 'Auto-scroll',
          subtitle: 'Hands-free reading',
          value: settings.autoScroll,
          icon: Icons.play_circle_outline,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).state = settings.copyWith(
              autoScroll: value,
            );
          },
        ),
        _buildAutoScrollSpeedSlider(context, ref, settings),

        const Divider(height: 32),

        _buildSectionHeader('Appearance', Icons.palette),
        _buildThemeSelector(context, ref, settings),

        const Divider(height: 32),

        _buildSectionHeader('Reading Plan', Icons.menu_book),
        _buildReadingPlanTile(context),

        const Divider(height: 32),

        _buildSectionHeader('Notifications', Icons.notifications),
        _buildNotificationFrequencySelector(context, ref, settings),
        _buildNotificationTimeSelector(context, ref, settings),

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Notification Types',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        _buildNotificationTypeToggle(
          title: 'Daily verse',
          type: NotificationType.dailyVerse,
          settings: settings,
          ref: ref,
        ),
        _buildNotificationTypeToggle(
          title: 'Prayer reminder',
          type: NotificationType.prayerReminder,
          settings: settings,
          ref: ref,
        ),
        _buildNotificationTypeToggle(
          title: 'Devotional reminder',
          type: NotificationType.devotionalReminder,
          settings: settings,
          ref: ref,
        ),

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Sound & Vibration',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        _buildToggleTile(
          title: 'Sound',
          subtitle: 'Play notification sound',
          value: settings.soundEnabled,
          icon: Icons.volume_up,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).state = settings.copyWith(
              soundEnabled: value,
            );
          },
        ),
        _buildToggleTile(
          title: 'Vibration',
          subtitle: 'Vibrate on notification',
          value: settings.vibrationEnabled,
          icon: Icons.vibration,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).state = settings.copyWith(
              vibrationEnabled: value,
            );
          },
        ),
        _buildToggleTile(
          title: 'Silent notifications',
          subtitle: 'Show without sound or vibration',
          value: settings.silentNotifications,
          icon: Icons.notifications_off,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).state = settings.copyWith(
              silentNotifications: value,
            );
          },
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Theme'),
      subtitle: Text(_getThemeLabel(settings.themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<AppThemeMode>(
                  title: const Text('Light'),
                  value: AppThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider.notifier).state = settings
                          .copyWith(themeMode: value);
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<AppThemeMode>(
                  title: const Text('Dark'),
                  value: AppThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider.notifier).state = settings
                          .copyWith(themeMode: value);
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<AppThemeMode>(
                  title: const Text('System default'),
                  value: AppThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider.notifier).state = settings
                          .copyWith(themeMode: value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadingPlanTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.library_books),
      title: const Text('Reading Plan'),
      subtitle: const Text('Open reading plan screen'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        final navigator = Navigator.of(context, rootNavigator: true);
        Navigator.pop(context);
        navigator.push(
          MaterialPageRoute(builder: (_) => const ReadingPlanScreen()),
        );
      },
    );
  }

  Widget _buildFontSizeSlider(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.format_size),
      title: const Text('Font size'),
      subtitle: Slider(
        value: settings.fontSize,
        min: 10,
        max: 32,
        divisions: 22,
        label: settings.fontSize.toStringAsFixed(0),
        onChanged: (value) {
          ref.read(appSettingsProvider.notifier).state = settings.copyWith(
            fontSize: value,
          );
        },
      ),
    );
  }

  Widget _buildFontStyleSelector(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.font_download),
      title: const Text('Font style'),
      subtitle: Text(settings.fontFamily),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Font'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFontOption('System', 'System', settings, ref, context),
                _buildFontOption('Serif', 'Serif', settings, ref, context),
                _buildFontOption(
                  'Sans-serif',
                  'Sans-serif',
                  settings,
                  ref,
                  context,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontOption(
    String label,
    String fontFamily,
    AppSettings settings,
    WidgetRef ref,
    BuildContext context,
  ) {
    return RadioListTile<String>(
      title: Text(label),
      value: fontFamily,
      groupValue: settings.fontFamily,
      onChanged: (value) {
        if (value != null) {
          ref.read(appSettingsProvider.notifier).state = settings.copyWith(
            fontFamily: value,
          );
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildLineSpacingSlider(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.format_line_spacing),
      title: const Text('Line spacing'),
      subtitle: Slider(
        value: settings.lineSpacing,
        min: 1.0,
        max: 2.5,
        divisions: 15,
        label: settings.lineSpacing.toStringAsFixed(1),
        onChanged: (value) {
          ref.read(appSettingsProvider.notifier).state = settings.copyWith(
            lineSpacing: value,
          );
        },
      ),
    );
  }

  Widget _buildAutoScrollSpeedSlider(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final label = '${settings.autoScrollSpeed.toStringAsFixed(0)} px/s';

    return ListTile(
      leading: const Icon(Icons.speed),
      title: const Text('Auto-scroll speed'),
      subtitle: Slider(
        value: settings.autoScrollSpeed,
        min: 4,
        max: 40,
        divisions: 36,
        label: label,
        onChanged: (value) {
          ref.read(appSettingsProvider.notifier).state = settings.copyWith(
            autoScrollSpeed: value,
          );
        },
      ),
      trailing: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildNotificationFrequencySelector(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.schedule),
      title: const Text('Notification frequency'),
      subtitle: Text(_getFrequencyLabel(settings.notificationFrequency)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notification Frequency'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: NotificationFrequency.values.map((freq) {
                return RadioListTile<NotificationFrequency>(
                  title: Text(_getFrequencyLabel(freq)),
                  value: freq,
                  groupValue: settings.notificationFrequency,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider.notifier).state = settings
                          .copyWith(notificationFrequency: value);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationTimeSelector(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: const Text('Notification time'),
      subtitle: Text(_getTimeLabel(settings.notificationTime)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notification Time'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: NotificationTime.values.map((time) {
                return RadioListTile<NotificationTime>(
                  title: Text(_getTimeLabel(time)),
                  value: time,
                  groupValue: settings.notificationTime,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider.notifier).state = settings
                          .copyWith(notificationTime: value);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationTypeToggle({
    required String title,
    required NotificationType type,
    required AppSettings settings,
    required WidgetRef ref,
  }) {
    final isEnabled = settings.enabledNotifications.contains(type);

    return CheckboxListTile(
      title: Text(title),
      value: isEnabled,
      onChanged: (value) {
        final newSet = Set<NotificationType>.from(
          settings.enabledNotifications,
        );
        if (value == true) {
          newSet.add(type);
        } else {
          newSet.remove(type);
        }
        ref.read(appSettingsProvider.notifier).state = settings.copyWith(
          enabledNotifications: newSet,
        );
      },
    );
  }

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System default';
    }
  }

  String _getFrequencyLabel(NotificationFrequency freq) {
    switch (freq) {
      case NotificationFrequency.daily:
        return 'Daily';
      case NotificationFrequency.weekly:
        return 'Weekly';
      case NotificationFrequency.custom:
        return 'Custom schedule';
      case NotificationFrequency.off:
        return 'Off';
    }
  }

  String _getTimeLabel(NotificationTime time) {
    switch (time) {
      case NotificationTime.morning:
        return 'Morning';
      case NotificationTime.afternoon:
        return 'Afternoon';
      case NotificationTime.evening:
        return 'Evening';
      case NotificationTime.custom:
        return 'Custom time';
    }
  }
}
