import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../providers/notification_providers.dart';
import '../providers/settings_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          children: [
            _buildSectionHeader('General', Icons.notifications_active),
            _buildEnableTile(ref, settings),
            _buildFrequencyTile(context, ref, settings),
            _buildTimeTile(context, ref, settings),
            _buildDaySelectionTile(context, ref, settings),
            if (settings.notificationDayMode == NotificationDayMode.custom)
              _buildCustomDaysPreview(settings),
            if (settings.notificationTime == NotificationTime.custom)
              _buildCustomTimeTile(context, ref, settings),
            _buildActionTile(
              icon: Icons.shield_outlined,
              title: 'Request permission',
              subtitle: 'Allow this device to show reminders',
              onTap: () async {
                await ref
                    .read(localNotificationServiceProvider)
                    .requestPermissions();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permission request sent')),
                );
              },
            ),
            _buildActionTile(
              icon: Icons.notification_add,
              title: 'Send test notification',
              subtitle: 'Verify notifications are working',
              onTap: () async {
                await ref
                    .read(localNotificationServiceProvider)
                    .showTestNotification(settings);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent')),
                );
              },
            ),

            const Divider(height: 32),
            _buildSectionHeader('Reminder Types', Icons.tune),
            _buildTypeToggle(
              ref,
              settings,
              NotificationType.dailyVerse,
              'Daily verse',
            ),
            _buildTypeToggle(
              ref,
              settings,
              NotificationType.prayerReminder,
              'Prayer reminder',
            ),
            _buildTypeToggle(
              ref,
              settings,
              NotificationType.devotionalReminder,
              'Devotional reminder',
            ),
            if (settings.enabledNotifications.contains(
              NotificationType.prayerReminder,
            ))
              _buildPrayerTimesEditor(context, ref, settings),
            if (settings.enabledNotifications.contains(
              NotificationType.devotionalReminder,
            ))
              _buildDevotionTimeTile(context, ref, settings),

            const Divider(height: 32),
            _buildSectionHeader('Reading Plan Alarm', Icons.alarm),
            SwitchListTile(
              secondary: const Icon(Icons.menu_book),
              title: const Text('Reading plan notifications'),
              subtitle: const Text('Enable reading plan reminders'),
              value: settings.enabledNotifications.contains(
                NotificationType.readingPlanReminder,
              ),
              onChanged: (value) {
                final next = Set<NotificationType>.from(
                  settings.enabledNotifications,
                );
                if (value) {
                  next.add(NotificationType.readingPlanReminder);
                } else {
                  next.remove(NotificationType.readingPlanReminder);
                }

                ref.read(appSettingsProvider.notifier).state = settings
                    .copyWith(enabledNotifications: next);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.alarm),
              title: const Text('Hourly reminder until done'),
              subtitle: const Text(
                'Keeps reminding each hour until today\'s reading is complete.',
              ),
              value: settings.readingPlanAlarmEnabled,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).state = settings
                    .copyWith(readingPlanAlarmEnabled: value);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timelapse),
              title: const Text('Reminder window'),
              subtitle: Text(
                '${_formatHour(settings.readingPlanReminderStartHour)} - ${_formatHour(settings.readingPlanReminderEndHour)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final start = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.readingPlanReminderStartHour,
                    minute: 0,
                  ),
                );
                if (start == null || !context.mounted) return;

                final end = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.readingPlanReminderEndHour,
                    minute: 0,
                  ),
                );
                if (end == null) return;

                var startHour = start.hour;
                var endHour = end.hour;
                if (endHour <= startHour) {
                  endHour = (startHour + 1).clamp(1, 23);
                }

                ref.read(appSettingsProvider.notifier).state = settings
                    .copyWith(
                      readingPlanReminderStartHour: startHour,
                      readingPlanReminderEndHour: endHour,
                    );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Notification buttons: Pause 2h, 3h, 4h, 6h, or pause for today.',
              ),
            ),

            const Divider(height: 32),
            _buildSectionHeader('Memory Verses', Icons.auto_stories),
            SwitchListTile(
              secondary: const Icon(Icons.auto_stories),
              title: const Text('Memory verse notifications'),
              subtitle: const Text(
                'Receive encouraging verses during the day.',
              ),
              value: settings.memoryVerseEnabled,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).state = settings
                    .copyWith(memoryVerseEnabled: value);
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('How often'),
              subtitle: Text(_memoryCadenceLabel(settings.memoryVerseCadence)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showMemoryCadenceDialog(context, ref, settings),
            ),
            if (settings.memoryVerseCadence ==
                MemoryVerseCadence.defaultFourTimes)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Default times: 9:00 AM, 12:00 PM, 3:00 PM, 6:00 PM',
                  ),
                ),
              ),
            if (settings.memoryVerseCadence == MemoryVerseCadence.onceDaily)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    TimeOfDay(
                      hour: settings.memoryVerseWindowStartHour,
                      minute: settings.memoryVerseWindowStartMinute,
                    ),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.memoryVerseWindowStartHour,
                      minute: settings.memoryVerseWindowStartMinute,
                    ),
                  );
                  if (time == null) return;

                  ref.read(appSettingsProvider.notifier).state = settings
                      .copyWith(
                        memoryVerseWindowStartHour: time.hour,
                        memoryVerseWindowStartMinute: time.minute,
                      );
                },
              ),
            if (settings.memoryVerseCadence !=
                    MemoryVerseCadence.defaultFourTimes &&
                settings.memoryVerseCadence != MemoryVerseCadence.onceDaily)
              ListTile(
                leading: const Icon(Icons.timelapse),
                title: const Text('Time period'),
                subtitle: Text(
                  '${_formatTime(settings.memoryVerseWindowStartHour, settings.memoryVerseWindowStartMinute)} - '
                  '${_formatTime(settings.memoryVerseWindowEndHour, settings.memoryVerseWindowEndMinute)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final start = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.memoryVerseWindowStartHour,
                      minute: settings.memoryVerseWindowStartMinute,
                    ),
                  );
                  if (start == null || !context.mounted) return;

                  final end = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.memoryVerseWindowEndHour,
                      minute: settings.memoryVerseWindowEndMinute,
                    ),
                  );
                  if (end == null) return;

                  final startTotal = (start.hour * 60) + start.minute;
                  var endTotal = (end.hour * 60) + end.minute;
                  if (endTotal <= startTotal) {
                    endTotal = (startTotal + 60).clamp(0, (23 * 60) + 59);
                  }

                  ref.read(appSettingsProvider.notifier).state = settings
                      .copyWith(
                        memoryVerseWindowStartHour: start.hour,
                        memoryVerseWindowStartMinute: start.minute,
                        memoryVerseWindowEndHour: endTotal ~/ 60,
                        memoryVerseWindowEndMinute: endTotal % 60,
                      );
                },
              ),
            ListTile(
              leading: const Icon(Icons.swap_vert_circle_outlined),
              title: const Text('Verse source mode'),
              subtitle: Text(_memoryModeLabel(settings.memoryVerseMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showMemoryModeDialog(context, ref, settings),
            ),
            if (settings.memoryVerseMode == MemoryVerseMode.curated)
              _buildCuratedListEditor(context, ref, settings),

            const Divider(height: 32),
            _buildSectionHeader('Sound & Vibration', Icons.volume_up),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up),
              title: const Text('Sound'),
              subtitle: const Text('Play notification sound'),
              value: settings.soundEnabled,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).state = settings
                    .copyWith(soundEnabled: value);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.vibration),
              title: const Text('Vibration'),
              subtitle: const Text('Vibrate on notification'),
              value: settings.vibrationEnabled,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).state = settings
                    .copyWith(vibrationEnabled: value);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_off),
              title: const Text('Silent notifications'),
              subtitle: const Text('Show without sound or vibration'),
              value: settings.silentNotifications,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).state = settings
                    .copyWith(silentNotifications: value);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEnableTile(WidgetRef ref, AppSettings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications),
      title: const Text('Enable notifications'),
      subtitle: Text(
        settings.notificationFrequency == NotificationFrequency.off
            ? 'Currently off'
            : 'Currently on',
      ),
      value: settings.notificationFrequency != NotificationFrequency.off,
      onChanged: (value) {
        final nextFrequency = value
            ? NotificationFrequency.daily
            : NotificationFrequency.off;
        final nextTypes = value
            ? (settings.enabledNotifications.isEmpty
                  ? <NotificationType>{
                      NotificationType.dailyVerse,
                      NotificationType.readingPlanReminder,
                    }
                  : settings.enabledNotifications)
            : <NotificationType>{};

        ref.read(appSettingsProvider.notifier).state = settings.copyWith(
          notificationFrequency: nextFrequency,
          enabledNotifications: nextTypes,
        );
      },
    );
  }

  Widget _buildFrequencyTile(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.schedule),
      title: const Text('Frequency'),
      subtitle: Text(_frequencyLabel(settings.notificationFrequency)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notification Frequency'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: NotificationFrequency.values.map((freq) {
                return RadioListTile<NotificationFrequency>(
                  value: freq,
                  groupValue: settings.notificationFrequency,
                  title: Text(_frequencyLabel(freq)),
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(appSettingsProvider.notifier).state = settings
                        .copyWith(notificationFrequency: value);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeTile(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: const Text('Notification time'),
      subtitle: Text(_timeLabel(settings.notificationTime)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notification Time'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: NotificationTime.values.map((time) {
                return RadioListTile<NotificationTime>(
                  value: time,
                  groupValue: settings.notificationTime,
                  title: Text(_timeLabel(time)),
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(appSettingsProvider.notifier).state = settings
                        .copyWith(notificationTime: value);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomTimeTile(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.timer_outlined),
      title: const Text('Custom time'),
      subtitle: Text(
        MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay(
            hour: settings.customNotificationHour,
            minute: settings.customNotificationMinute,
          ),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selected = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: settings.customNotificationHour,
            minute: settings.customNotificationMinute,
          ),
        );
        if (selected == null) return;

        ref.read(appSettingsProvider.notifier).state = settings.copyWith(
          customNotificationHour: selected.hour,
          customNotificationMinute: selected.minute,
        );
      },
    );
  }

  Widget _buildDaySelectionTile(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.calendar_month),
      title: const Text('Notify on days'),
      subtitle: Text(_dayModeLabel(settings)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        var tempMode = settings.notificationDayMode;
        var tempCustomDays = Set<int>.from(settings.customNotificationWeekdays);
        if (tempCustomDays.isEmpty) {
          tempCustomDays = {
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
          };
        }

        showDialog<void>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Notification Days'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<NotificationDayMode>(
                        value: NotificationDayMode.everyDay,
                        groupValue: tempMode,
                        title: const Text('Every day'),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => tempMode = value);
                        },
                      ),
                      RadioListTile<NotificationDayMode>(
                        value: NotificationDayMode.weekdays,
                        groupValue: tempMode,
                        title: const Text('Weekdays'),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => tempMode = value);
                        },
                      ),
                      RadioListTile<NotificationDayMode>(
                        value: NotificationDayMode.weekends,
                        groupValue: tempMode,
                        title: const Text('Weekends'),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => tempMode = value);
                        },
                      ),
                      RadioListTile<NotificationDayMode>(
                        value: NotificationDayMode.custom,
                        groupValue: tempMode,
                        title: const Text('Custom'),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => tempMode = value);
                        },
                      ),
                      if (tempMode == NotificationDayMode.custom)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(7, (index) {
                              final weekday = index + 1;
                              final selected = tempCustomDays.contains(weekday);
                              return FilterChip(
                                label: Text(_weekdayShort(weekday)),
                                selected: selected,
                                onSelected: (isSelected) {
                                  setDialogState(() {
                                    if (isSelected) {
                                      tempCustomDays.add(weekday);
                                    } else if (tempCustomDays.length > 1) {
                                      tempCustomDays.remove(weekday);
                                    }
                                  });
                                },
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      ref.read(appSettingsProvider.notifier).state = settings
                          .copyWith(
                            notificationDayMode: tempMode,
                            customNotificationWeekdays: tempCustomDays,
                          );
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomDaysPreview(AppSettings settings) {
    final ordered = settings.customNotificationWeekdays.toList()..sort();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ordered
            .map((day) => Chip(label: Text(_weekdayLabel(day))))
            .toList(),
      ),
    );
  }

  Widget _buildTypeToggle(
    WidgetRef ref,
    AppSettings settings,
    NotificationType type,
    String label,
  ) {
    final enabled = settings.enabledNotifications.contains(type);
    return CheckboxListTile(
      value: enabled,
      title: Text(label),
      onChanged: (value) {
        final next = Set<NotificationType>.from(settings.enabledNotifications);
        var prayerTimes = List<int>.from(settings.prayerReminderMinutes);
        var devotionHour = settings.devotionalReminderHour;
        var devotionMinute = settings.devotionalReminderMinute;

        if (value == true) {
          next.add(type);
          if (type == NotificationType.prayerReminder && prayerTimes.isEmpty) {
            prayerTimes = [360, 720, 1080];
          }
          if (type == NotificationType.devotionalReminder &&
              devotionHour == 0 &&
              devotionMinute == 0) {
            final defaultTime = _resolveGeneralTime(settings);
            devotionHour = defaultTime.hour;
            devotionMinute = defaultTime.minute;
          }
        } else {
          next.remove(type);
        }

        ref.read(appSettingsProvider.notifier).state = settings.copyWith(
          enabledNotifications: next,
          prayerReminderMinutes: prayerTimes,
          devotionalReminderHour: devotionHour,
          devotionalReminderMinute: devotionMinute,
        );
      },
    );
  }

  Widget _buildPrayerTimesEditor(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final times = List<int>.from(settings.prayerReminderMinutes)..sort();
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.add_alarm),
          title: const Text('Prayer times'),
          subtitle: const Text('Add one or more times for prayer reminders'),
          trailing: const Icon(Icons.add),
          onTap: () async {
            final selected = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 6, minute: 0),
            );
            if (selected == null) return;

            final minutes = (selected.hour * 60) + selected.minute;
            if (times.contains(minutes)) return;
            final next = [...times, minutes]..sort();

            ref.read(appSettingsProvider.notifier).state = settings.copyWith(
              prayerReminderMinutes: next,
            );
          },
        ),
        if (times.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('No prayer time added yet.'),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: times.map((value) {
                final hour = value ~/ 60;
                final minute = value % 60;
                return Chip(
                  label: Text(_formatTime(hour, minute)),
                  onDeleted: () {
                    final next = [...times]..remove(value);
                    ref.read(appSettingsProvider.notifier).state = settings
                        .copyWith(prayerReminderMinutes: next);
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildDevotionTimeTile(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.self_improvement),
      title: const Text('Devotion time'),
      subtitle: Text(
        _formatTime(
          settings.devotionalReminderHour,
          settings.devotionalReminderMinute,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selected = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: settings.devotionalReminderHour,
            minute: settings.devotionalReminderMinute,
          ),
        );
        if (selected == null) return;

        ref.read(appSettingsProvider.notifier).state = settings.copyWith(
          devotionalReminderHour: selected.hour,
          devotionalReminderMinute: selected.minute,
        );
      },
    );
  }

  Widget _buildCuratedListEditor(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final verses = settings.curatedMemoryVerseReferences;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: const Text('Add memory verse reference'),
          subtitle: const Text('Example: 1 John 1:1'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            var inputValue = '';
            final value = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Add Verse Reference'),
                content: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'John 3:16'),
                  onChanged: (value) {
                    inputValue = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, inputValue),
                    child: const Text('Add'),
                  ),
                ],
              ),
            );

            final cleaned = value?.trim() ?? '';
            if (cleaned.isEmpty) return;

            final next = List<String>.from(verses);
            if (!next.contains(cleaned)) {
              next.add(cleaned);
            }

            ref.read(appSettingsProvider.notifier).state = settings.copyWith(
              curatedMemoryVerseReferences: next,
            );
          },
        ),
        if (verses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('No custom verses yet.'),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: verses.map((refText) {
                return Chip(
                  label: Text(refText),
                  onDeleted: () {
                    final next = List<String>.from(verses)
                      ..removeWhere((item) => item == refText);
                    ref.read(appSettingsProvider.notifier).state = settings
                        .copyWith(curatedMemoryVerseReferences: next);
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _showMemoryModeDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Memory Verse Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: MemoryVerseMode.values.map((mode) {
            return RadioListTile<MemoryVerseMode>(
              value: mode,
              groupValue: settings.memoryVerseMode,
              title: Text(_memoryModeLabel(mode)),
              onChanged: (value) {
                if (value == null) return;
                ref.read(appSettingsProvider.notifier).state = settings
                    .copyWith(memoryVerseMode: value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showMemoryCadenceDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Memory Verse Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: MemoryVerseCadence.values.map((cadence) {
            return RadioListTile<MemoryVerseCadence>(
              value: cadence,
              groupValue: settings.memoryVerseCadence,
              title: Text(_memoryCadenceLabel(cadence)),
              onChanged: (value) {
                if (value == null) return;
                ref.read(appSettingsProvider.notifier).state = settings
                    .copyWith(memoryVerseCadence: value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _frequencyLabel(NotificationFrequency value) {
    switch (value) {
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

  String _dayModeLabel(AppSettings settings) {
    switch (settings.notificationDayMode) {
      case NotificationDayMode.everyDay:
        return 'Every day';
      case NotificationDayMode.weekdays:
        return 'Weekdays (Mon-Fri)';
      case NotificationDayMode.weekends:
        return 'Weekends (Sat-Sun)';
      case NotificationDayMode.custom:
        if (settings.customNotificationWeekdays.isEmpty) {
          return 'Custom';
        }
        final days = settings.customNotificationWeekdays.toList()..sort();
        return days.map(_weekdayShort).join(', ');
    }
  }

  String _weekdayShort(int day) {
    switch (day) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
      default:
        return 'Sun';
    }
  }

  String _weekdayLabel(int day) {
    switch (day) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
      default:
        return 'Sunday';
    }
  }

  String _timeLabel(NotificationTime value) {
    switch (value) {
      case NotificationTime.morning:
        return 'Morning';
      case NotificationTime.afternoon:
        return 'Afternoon';
      case NotificationTime.evening:
        return 'Evening';
      case NotificationTime.custom:
        return 'Custom';
    }
  }

  TimeOfDay _resolveGeneralTime(AppSettings settings) {
    if (settings.notificationTime == NotificationTime.custom) {
      return TimeOfDay(
        hour: settings.customNotificationHour,
        minute: settings.customNotificationMinute,
      );
    }

    switch (settings.notificationTime) {
      case NotificationTime.morning:
        return const TimeOfDay(hour: 8, minute: 0);
      case NotificationTime.afternoon:
        return const TimeOfDay(hour: 13, minute: 0);
      case NotificationTime.evening:
        return const TimeOfDay(hour: 19, minute: 0);
      case NotificationTime.custom:
        return TimeOfDay(
          hour: settings.customNotificationHour,
          minute: settings.customNotificationMinute,
        );
    }
  }

  String _memoryModeLabel(MemoryVerseMode mode) {
    switch (mode) {
      case MemoryVerseMode.encouragementRandom:
        return 'Random encouraging verses';
      case MemoryVerseMode.encouragementSequential:
        return 'Encouraging verses in order';
      case MemoryVerseMode.curated:
        return 'My verse list';
    }
  }

  String _memoryCadenceLabel(MemoryVerseCadence cadence) {
    switch (cadence) {
      case MemoryVerseCadence.defaultFourTimes:
        return 'Default (9 AM, 12 PM, 3 PM, 6 PM)';
      case MemoryVerseCadence.every30Minutes:
        return 'Every 30 minutes';
      case MemoryVerseCadence.hourly:
        return 'Every 1 hour';
      case MemoryVerseCadence.every2Hours:
        return 'Every 2 hours';
      case MemoryVerseCadence.onceDaily:
        return 'Once daily';
    }
  }

  String _formatTime(int hour, int minute) {
    final safeHour = hour.clamp(0, 23);
    final safeMinute = minute.clamp(0, 59);
    final suffix = safeHour >= 12 ? 'PM' : 'AM';
    final shownHour = safeHour % 12 == 0 ? 12 : safeHour % 12;
    final shownMinute = safeMinute.toString().padLeft(2, '0');
    return '$shownHour:$shownMinute $suffix';
  }

  String _formatHour(int hour) {
    final safe = hour.clamp(0, 23);
    final suffix = safe >= 12 ? 'PM' : 'AM';
    final shown = safe % 12 == 0 ? 12 : safe % 12;
    return '$shown:00 $suffix';
  }
}
