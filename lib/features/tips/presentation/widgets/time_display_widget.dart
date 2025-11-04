import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/design/design_system.dart';

/// Displays current time and next notification time for debugging timezone issues
class TimeDisplayWidget extends StatelessWidget {
  final TimeOfDay notificationTime;
  final bool notificationsEnabled;

  const TimeDisplayWidget({
    super.key,
    required this.notificationTime,
    required this.notificationsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();
    final currentTimeStr = DateFormat('h:mm a').format(now);
    final timezoneStr = now.timeZoneName;
    
    // Format notification time
    final notifHour = notificationTime.hour;
    final notifMinute = notificationTime.minute;
    final notifPeriod = notifHour >= 12 ? 'PM' : 'AM';
    final notifHour12 = notifHour > 12 ? notifHour - 12 : (notifHour == 0 ? 12 : notifHour);
    final notifTimeStr = '$notifHour12:${notifMinute.toString().padLeft(2, '0')} $notifPeriod';

    return GWCard(
      padding: EdgeInsets.symmetric(horizontal: GWDs.s5, vertical: GWDs.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: cs.primary),
              SizedBox(width: GWDs.s2),
              Expanded(
                child: Text(
                  'Current: $currentTimeStr ($timezoneStr)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (notificationsEnabled) ...[
            SizedBox(height: GWDs.s1),
            Row(
              children: [
                Icon(Icons.notifications_active, size: 16, color: cs.tertiary),
                SizedBox(width: GWDs.s2),
                Expanded(
                  child: Text(
                    'Next reminder: $notifTimeStr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: GWDs.s1),
            Row(
              children: [
                Icon(Icons.notifications_off, size: 16, color: cs.error),
                SizedBox(width: GWDs.s2),
                Expanded(
                  child: Text(
                    'Notifications disabled',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
