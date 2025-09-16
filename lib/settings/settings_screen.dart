import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/eco_tip.dart';
import '../core/design/design_system.dart';
import '../features/common/widgets/eco_app_bar.dart';
import 'settings_provider.dart';
import '../services/notifications/notification_service.dart';
// background visuals removed per request

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const EcoAppBar(title: 'Settings'),
      body: ListView(
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
                            await NotificationService.scheduleDailyTipNotification(settings.notificationTime);
                          } else {
                            await NotificationService.cancelDailyTipNotification();
                          }
                        },
                      ),
                      _TimeTile(
                        icon: Icons.schedule,
                        title: 'Daily Tip Time',
                        subtitle: settings.notificationTime.format(context),
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: settings.notificationTime);
                          if (picked != null) {
                            await notifier.setNotificationTime(picked);
                            if (settings.notificationsEnabled) {
                              await NotificationService.requestPermissions();
                              await NotificationService.scheduleDailyTipNotification(picked);
                              if (context.mounted) {
                                final when = picked.format(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Reminder scheduled for $when')),
                                );
                              }
                            }
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
