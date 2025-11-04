import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/design/design_system.dart';
import '../../../data/models/eco_tip.dart';
import '../../../data/repositories/tip_repository_sqlite.dart';
import '../../../services/notifications/notification_service.dart';
import '../../common/widgets/eco_app_bar.dart';
import '../../common/widgets/static_grid_bubbles_background.dart';
import '../domain/export_provider.dart';
import '../domain/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const EcoAppBar(title: 'Settings'),
      body: Stack(
        children: [
          Positioned.fill(child: IgnorePointer(child: StaticGridBubblesBackground())),
          ListView(
            padding: EdgeInsets.only(bottom: GWDs.s8),
            children: [
              const SizedBox(height: GWDs.s4),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                child: _SettingsSection(
                  title: 'Appearance',
                  children: [
                    _SwitchTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Use the dark color theme',
                      value: settings.darkMode,
                      onChanged: notifier.toggleDarkMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GWDs.s6),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                child: _SettingsSection(
                  title: 'Tip Categories',
                  children: [
                    _CategoryChooser(
                      selected: settings.enabledCategories,
                      onToggle: (c) => notifier.toggleCategory(c.name),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GWDs.s6),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                child: _SettingsSection(
                  title: 'Notifications',
                  children: [
                    _SwitchTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Daily Reminder',
                      subtitle: 'Notify me about today\'s eco tip',
                      value: settings.notificationsEnabled,
                      onChanged: (v) async {
                        await notifier.setNotificationsEnabled(v);
                        if (v) {
                          await NotificationService.requestPermissions();
                          // Fetch tomorrow's tip for notification with visual
                          try {
                            final repo = TipRepositorySqlite();
                            final tomorrow = DateTime.now().add(const Duration(days: 1));
                            final tip = await repo.getDailyTip(tomorrow);
                            await NotificationService.scheduleDailyTipNotification(
                              settings.notificationTime,
                              tipText: tip.text,
                              tip: tip, // Pass full tip for image generation
                            );
                          } catch (_) {
                            await NotificationService.scheduleDailyTipNotification(settings.notificationTime);
                          }
                        } else {
                          await NotificationService.cancelDailyTipNotification();
                        }
                      },
                    ),
                    if (settings.notificationsEnabled) _TimeTile(
                      icon: Icons.schedule,
                      title: 'Daily Tip Time',
                      subtitle: settings.notificationTime.format(context),
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: settings.notificationTime);
                        if (picked != null) {
                          await notifier.setNotificationTime(picked);
                          if (settings.notificationsEnabled) {
                            await NotificationService.requestPermissions();
                            // Fetch tomorrow's tip for notification with visual
                            try {
                              final repo = TipRepositorySqlite();
                              final tomorrow = DateTime.now().add(const Duration(days: 1));
                              final tip = await repo.getDailyTip(tomorrow);
                              await NotificationService.scheduleDailyTipNotification(
                                picked,
                                tipText: tip.text,
                                tip: tip, // Pass full tip for image generation
                              );
                            } catch (_) {
                              await NotificationService.scheduleDailyTipNotification(picked);
                            }
                            if (context.mounted) {
                              final when = picked.format(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('⏰ Reminder scheduled for $when daily\n💡 Make sure time is at least 2 minutes away'),
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                    // Android Alarm Settings (for exact alarms permission)
                    if (settings.notificationsEnabled && Platform.isAndroid) _ActionTile(
                      icon: Icons.alarm,
                      title: 'Grant Exact Alarm Permission',
                      subtitle: 'Open Android settings to allow exact alarms',
                      onTap: () async {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('⏰ Enable Exact Alarms'),
                              content: const Text(
                                '1. Tap OK to open Android Settings\n\n'
                                '2. Find "GreenWise" in the list\n\n'
                                '3. Tap "Alarms & Reminders"\n\n'
                                '4. Toggle to "Allow"\n\n'
                                'This lets notifications fire at the exact time you set.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    try {
                                      // Try to open exact alarm settings
                                      await SystemChannels.platform.invokeMethod(
                                        'startActivity',
                                        <String, dynamic>{
                                          'action': 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
                                        },
                                      );
                                    } catch (e) {
                                      // Fallback: open general app settings
                                      try {
                                        await SystemChannels.platform.invokeMethod(
                                          'startActivity',
                                          <String, dynamic>{
                                            'action': 'android.settings.APPLICATION_DETAILS_SETTINGS',
                                            'data': 'package:com.example.greenwise',
                                          },
                                        );
                                      } catch (_) {
                                        if (ctx.mounted) {
                                          ScaffoldMessenger.of(ctx).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please open Settings manually: Apps → GreenWise → Alarms & Reminders'),
                                              duration: Duration(seconds: 5),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: const Text('Open Settings'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GWDs.s6),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                child: _SettingsSection(
                  title: 'Data Backup',
                  children: [
                    _ActionTile(
                      icon: Icons.upload_outlined,
                      title: 'Export Progress',
                      subtitle: 'Save your data to a file',
                      onTap: () => _handleExport(context, ref),
                    ),
                    _ActionTile(
                      icon: Icons.download_outlined,
                      title: 'Import Progress',
                      subtitle: 'Restore from clipboard',
                      onTap: () => _handleImport(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GWDs.s6),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                child: _SettingsSection(
                  title: 'About',
                  children: [
                    _InfoTile(
                      icon: Icons.eco_outlined,
                      title: 'GreenWise Beta',
                      subtitle: 'Build purposeful sustainable habits',
                    ),
                    _InfoTile(
                      icon: Icons.info_outline,
                      title: 'Version',
                      subtitle: '0.1.0-dev',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GWDs.s6),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                child: Text('Changes are saved automatically.', style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(height: GWDs.s7),
            ],
          ),
        ],
      ),
      backgroundColor: cs.surface,
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title; final List<Widget> children; const _SettingsSection({required this.title, required this.children});
  @override Widget build(BuildContext context){
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      ...children,
    ]);
  }
}

class _SwitchTile extends StatelessWidget { final IconData icon; final String title; final String subtitle; final bool value; final ValueChanged<bool> onChanged; const _SwitchTile({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});
  @override Widget build(BuildContext context){ final cs=Theme.of(context).colorScheme; return Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: cs.surfaceContainerHighest.withValues(alpha:.85),
      border: Border.all(color: cs.primary.withValues(alpha:.08)),
    ),
    child: SwitchListTile(
      contentPadding: const EdgeInsets.fromLTRB(20,4,16,4),
      title: Row(children:[Icon(icon,color: cs.primary), const SizedBox(width:12), Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)))]),
      subtitle: Padding(padding: const EdgeInsets.only(left:40), child: Text(subtitle)),
      value: value,
      onChanged: onChanged,
    ),
  ); }
}

class _TimeTile extends StatelessWidget { final IconData icon; final String title; final String subtitle; final VoidCallback onTap; const _TimeTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override Widget build(BuildContext context){ final cs=Theme.of(context).colorScheme; return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: cs.surfaceContainerHighest.withValues(alpha:.85),
      border: Border.all(color: cs.primary.withValues(alpha:.08)),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.fromLTRB(20,10,16,10),
      leading: Icon(icon,color: cs.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  ); }
}

class _InfoTile extends StatelessWidget { final IconData icon; final String title; final String subtitle; const _InfoTile({required this.icon, required this.title, required this.subtitle});
  @override Widget build(BuildContext context){ final cs=Theme.of(context).colorScheme; return Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: cs.surfaceContainerHighest.withValues(alpha:.85),
      border: Border.all(color: cs.primary.withValues(alpha:.08)),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.fromLTRB(20,10,16,10),
      leading: Icon(icon,color: cs.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    ),
  ); }
}

class _CategoryChooser extends ConsumerWidget { final Set<String> selected; final void Function(EcoTipCategory) onToggle; const _CategoryChooser({required this.selected, required this.onToggle});
  @override Widget build(BuildContext context, WidgetRef ref){ final all = EcoTipCategory.values; return Wrap(spacing: 10, runSpacing: 10, children: all.map((c){ final isSelected = selected.isEmpty || selected.contains(c.name); return FilterChip(
    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha:.85),
    checkmarkColor: Theme.of(context).colorScheme.onPrimary,
    label: Text(c.name),
    selected: isSelected,
    onSelected: (_)=> onToggle(c),
  ); }).toList()); }
}

class _ActionTile extends StatelessWidget { 
  final IconData icon; 
  final String title; 
  final String subtitle; 
  final VoidCallback onTap; 
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  
  @override Widget build(BuildContext context){ 
    final cs=Theme.of(context).colorScheme; 
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: cs.surfaceContainerHighest.withValues(alpha:.85),
        border: Border.all(color: cs.primary.withValues(alpha:.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(20,10,16,10),
        leading: Icon(icon,color: cs.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    ); 
  }
}

/// Export progress data to file and share
Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
  try {
    // Show loading
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing backup...')),
      );
    }
    
    // Get export data
    final jsonString = await ref.read(exportProgressProvider.future);
    
    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/greenwise_backup_$timestamp.json');
    await file.writeAsString(jsonString);
    
    // Share the file
    final result = await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'GreenWise Progress Backup',
      text: 'Your GreenWise progress data backup. Keep this file safe!',
    );
    
    if (context.mounted) {
      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Backup exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
}

/// Import progress data from clipboard
Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
  try {
    // Show dialog with instructions
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Progress'),
        content: const Text(
          'Make sure you have copied the backup JSON to your clipboard, then tap Import.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    
    if (confirmed != true || !context.mounted) return;
    
    // Get clipboard data
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final jsonString = clipboardData?.text;
    
    if (jsonString == null || jsonString.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty')),
        );
      }
      return;
    }
    
    // Show loading
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importing backup...')),
      );
    }
    
    // Import data
    final success = await ref.read(importProgressProvider(jsonString).future);
    
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Progress restored successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Invalid backup file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
}
