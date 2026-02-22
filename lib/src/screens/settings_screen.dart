import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../providers/settings_providers.dart';
import 'notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const SafeArea(top: false, bottom: true, child: SettingsContent()),
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
        _buildTextAlignmentSelector(context, ref, settings),
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

        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          subtitle: const Text('Open reminder and memory verse settings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
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
                  title: const Text('Sepia'),
                  value: AppThemeMode.sepia,
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
                  title: const Text('Rose'),
                  value: AppThemeMode.rose,
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
                  title: const Text('Paper'),
                  value: AppThemeMode.paper,
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
                  title: const Text('AMOLED'),
                  value: AppThemeMode.amoled,
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
      subtitle: DropdownButtonFormField<String>(
        value: settings.fontFamily,
        isExpanded: true,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
        ),
        items: _fontOptions
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.value,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          ref.read(appSettingsProvider.notifier).state = settings.copyWith(
            fontFamily: value,
          );
        },
      ),
    );
  }

  List<_FontOption> get _fontOptions => const [
    _FontOption(label: 'System Default', value: 'System'),
    _FontOption(label: 'Sans Serif', value: 'Sans-serif'),
    _FontOption(label: 'Serif', value: 'Serif'),
    _FontOption(label: 'Monospace', value: 'Monospace'),
    _FontOption(label: 'Roboto', value: 'Roboto'),
    _FontOption(label: 'Open Sans', value: 'Open Sans'),
    _FontOption(label: 'Lato', value: 'Lato'),
    _FontOption(label: 'Montserrat', value: 'Montserrat'),
    _FontOption(label: 'Merriweather', value: 'Merriweather'),
    _FontOption(label: 'Georgia', value: 'Georgia'),
  ];

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

  Widget _buildTextAlignmentSelector(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.format_align_left),
      title: const Text('Text alignment'),
      subtitle: DropdownButtonFormField<VerseTextAlignment>(
        value: settings.verseTextAlignment,
        isExpanded: true,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
        ),
        items: const [
          DropdownMenuItem(
            value: VerseTextAlignment.left,
            child: Text('Align left'),
          ),
          DropdownMenuItem(
            value: VerseTextAlignment.justify,
            child: Text('Justify'),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;
          ref.read(appSettingsProvider.notifier).state = settings.copyWith(
            verseTextAlignment: value,
          );
        },
      ),
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

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.sepia:
        return 'Sepia';
      case AppThemeMode.rose:
        return 'Rose';
      case AppThemeMode.paper:
        return 'Paper';
      case AppThemeMode.amoled:
        return 'AMOLED';
    }
  }
}

class _FontOption {
  final String label;
  final String value;

  const _FontOption({required this.label, required this.value});
}
