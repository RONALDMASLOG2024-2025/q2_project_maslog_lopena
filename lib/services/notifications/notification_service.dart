import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Daily notification scheduler using timezone-aware alarms.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _dailyTipChannelId = 'daily_tip';
  static const _dailyTipChannelName = 'Daily Tip';
  static const _dailyTipChannelDesc = 'Daily eco tip reminder';
  static const _dailyTipNotificationId = 1001;

  static Future<void> ensureInitialized() async {
    if (kIsWeb) {
      _initialized = true;
      return; // Notifications not supported on web in this app
    }
    if (_initialized) return;

    // Init timezones without native timezone plugin. Default to a sensible
    // location; if unavailable, fall back to UTC.
    try {
      tz.initializeTimeZones();
      // Prefer a Philippines timezone matching the project's locale; adjust if needed.
      tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    } catch (_) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Init plugin (no-op in tests if plugin not registered)
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    } catch (_) {}

    // On Android create/update a high-importance, lock-screen visible channel
    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(const AndroidNotificationChannel(
        _dailyTipChannelId,
        _dailyTipChannelName,
        description: _dailyTipChannelDesc,
        importance: Importance.high,
      ));
    } catch (_) {}

    _initialized = true;
  }

  /// Request notification permissions on supported platforms.
  static Future<void> requestPermissions() async {
  if (kIsWeb) return;
    if (!_initialized) await ensureInitialized();
    try {
      // iOS/macOS
      final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: false,
      );
      // Android 13+
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
    } catch (_) {}
  }

  /// Schedule a daily notification at the specified [time].
  static Future<void> scheduleDailyTipNotification(TimeOfDay time) async {
  if (kIsWeb) return;
    if (!_initialized) await ensureInitialized();

    // Cancel any existing schedule to avoid duplicates
    await _plugin.cancel(_dailyTipNotificationId);

    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        _dailyTipChannelId,
        _dailyTipChannelName,
        channelDescription: _dailyTipChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.timeSensitive,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final next = _nextInstanceOf(time);

    try {
      await _plugin.zonedSchedule(
        _dailyTipNotificationId,
        'GreenWise Tip',
        "Check today's eco tip",
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_tip',
      );
    } catch (_) {}
  }

  /// Cancel the daily reminder if scheduled.
  static Future<void> cancelDailyTipNotification() async {
  if (kIsWeb) return;
    if (!_initialized) await ensureInitialized();
    await _plugin.cancel(_dailyTipNotificationId);
  }

  static tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(now.location, now.year, now.month, now.day, time.hour, time.minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
