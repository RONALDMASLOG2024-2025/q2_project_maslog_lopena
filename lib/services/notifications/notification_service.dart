import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import '../../data/models/eco_tip.dart';
import 'notification_image_generator.dart';

/// Daily notification scheduler using timezone-aware alarms.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const MethodChannel _nativeChannel = MethodChannel('com.example.greenwise/native_notifications');
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

    // Init timezones and detect device's local timezone from offset
    try {
      tz.initializeTimeZones();
      
      // Use offset-based timezone detection (more reliable than timeZoneName)
      final offset = DateTime.now().timeZoneOffset;
      final offsetHours = offset.inHours;
      final offsetMinutes = offset.inMinutes % 60;
      
      debugPrint('🌍 Device timezone offset detected: ${offset.inHours}h ${offset.inMinutes % 60}m');
      debugPrint('🕐 Device local time: ${DateTime.now()}');
      
      // Map offset to IANA timezone name
      String timezoneName = 'UTC';
      
      // Handle common timezones
      if (offsetHours == 8 && offsetMinutes == 0) {
        timezoneName = 'Asia/Manila'; // Philippines, Singapore, Hong Kong
      } else if (offsetHours == -8 && offsetMinutes == 0) {
        timezoneName = 'America/Los_Angeles'; // PST (US West Coast)
      } else if (offsetHours == -7 && offsetMinutes == 0) {
        timezoneName = 'America/Denver'; // MST (US Mountain)
      } else if (offsetHours == -6 && offsetMinutes == 0) {
        timezoneName = 'America/Chicago'; // CST (US Central)
      } else if (offsetHours == -5 && offsetMinutes == 0) {
        timezoneName = 'America/New_York'; // EST (US East Coast)
      } else if (offsetHours == 0 && offsetMinutes == 0) {
        timezoneName = 'UTC'; // London/UTC
      } else if (offsetHours == 1 && offsetMinutes == 0) {
        timezoneName = 'Europe/Paris'; // CET (Central European)
      } else if (offsetHours == 2 && offsetMinutes == 0) {
        timezoneName = 'Europe/Athens'; // EET (Eastern European)
      } else if (offsetHours == 3 && offsetMinutes == 0) {
        timezoneName = 'Europe/Moscow'; // MSK (Moscow)
      } else if (offsetHours == 5 && offsetMinutes == 30) {
        timezoneName = 'Asia/Kolkata'; // IST (India)
      } else if (offsetHours == 5 && offsetMinutes == 0) {
        timezoneName = 'Asia/Karachi'; // PKT (Pakistan)
      } else if (offsetHours == 9 && offsetMinutes == 0) {
        timezoneName = 'Asia/Tokyo'; // JST (Japan)
      } else if (offsetHours == 10 && offsetMinutes == 0) {
        timezoneName = 'Australia/Sydney'; // AEST (Australia East)
      } else if (offsetHours == -4 && offsetMinutes == 0) {
        timezoneName = 'America/Caracas'; // VET (Venezuela)
      } else if (offsetHours == -3 && offsetMinutes == 0) {
        timezoneName = 'America/Sao_Paulo'; // BRT (Brazil)
      } else {
        // For any other offset, try to find a matching timezone
        // or default to UTC
        timezoneName = 'UTC';
      }
      
      try {
        tz.setLocalLocation(tz.getLocation(timezoneName));
        debugPrint('✅ Timezone set to: $timezoneName');
      } catch (e) {
        // If timezone not found, use UTC
        debugPrint('⚠️ Failed to set timezone $timezoneName, using UTC. Error: $e');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      // Complete fallback: initialize and use UTC
      debugPrint('❌ Timezone initialization failed: $e');
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
      
      // Android 12+ - Request exact alarm permission for scheduled notifications
      await androidImpl?.requestExactAlarmsPermission();
    } catch (_) {}
  }

  /// Schedule a daily notification at the specified [time] with optional [tipText] and [tip] for image generation.
  /// If [tipText] is null, shows a generic reminder.
  /// If [tip] is provided, generates a beautiful visual notification image.
  /// 
  /// NATIVE ANDROID ALARMMANAGER APPROACH: Use platform channel to schedule via native AlarmManager.setAlarmClock()
  /// This is the ONLY reliable way to schedule notifications on Android 12+.
  static Future<void> scheduleDailyTipNotification(
    TimeOfDay time, {
    String? tipText,
    EcoTip? tip,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await ensureInitialized();

    final title = '🌱 Daily Eco Tip';
    final body = tipText ?? "Check today's eco tip to continue your sustainability journey!";

    try {
      // Check if we're on Android
      if (Platform.isAndroid) {
        debugPrint('📱 Using NATIVE Android AlarmManager for scheduling');
        debugPrint('⏰ Setting alarm for ${time.hour}:${time.minute}');
        
        // Generate notification image if tip is provided
        String? imagePath;
        if (tip != null) {
          debugPrint('🎨 Generating notification image...');
          await NotificationImageGenerator.cleanupOldImages();
          imagePath = await NotificationImageGenerator.generateTipImage(tip);
          debugPrint('✅ Image generated: $imagePath');
        }
        
        // Check if we can schedule exact alarms
        try {
          final canSchedule = await _nativeChannel.invokeMethod('canScheduleExactAlarms');
          debugPrint('🔐 Can schedule exact alarms: $canSchedule');
          
          if (!canSchedule) {
            debugPrint('❌ EXACT ALARM PERMISSION NOT GRANTED!');
            debugPrint('💡 User must go to Settings → Apps → GreenWise → Alarms & Reminders → Allow');
            return;
          }
        } catch (e) {
          debugPrint('⚠️ Could not check exact alarm permission: $e');
        }
        
        // Cancel any existing alarm
        try {
          await _nativeChannel.invokeMethod('cancelNotification');
          debugPrint('✅ Cancelled existing alarm');
        } catch (e) {
          debugPrint('⚠️ Could not cancel existing alarm: $e');
        }
        
        // Schedule new alarm via native code with image
        try {
          await _nativeChannel.invokeMethod('scheduleNotification', {
            'hour': time.hour,
            'minute': time.minute,
            'title': title,
            'body': body,
            'imagePath': imagePath, // Pass the image path to native code
          });
          
          debugPrint('✅ NATIVE ALARM SCHEDULED VIA ALARMMANAGER');
          debugPrint('🔔 Will fire at ${time.hour}:${time.minute} daily');
          if (imagePath != null) {
            debugPrint('🖼️ With beautiful notification image');
          }
          debugPrint('💡 This uses AlarmManager.setAlarmClock() - the most reliable method');
        } catch (e) {
          debugPrint('❌ Native alarm scheduling FAILED: $e');
          rethrow;
        }
      } else {
        // iOS/other platforms - use flutter_local_notifications
        debugPrint('� iOS detected, using flutter_local_notifications fallback');
        await _scheduleFallbackNotification(time, title, body, tip);
      }
    } catch (e) {
      debugPrint('❌ Critical error in scheduleDailyTipNotification: $e');
      rethrow;
    }
  }
  
  /// Fallback scheduling for iOS or if native Android fails
  static Future<void> _scheduleFallbackNotification(
    TimeOfDay time,
    String title,
    String body,
    EcoTip? tip,
  ) async {
    // Cancel any existing schedule
    await _plugin.cancel(_dailyTipNotificationId);

    // Generate notification image if tip is provided
    String? imagePath;
    if (tip != null) {
      await NotificationImageGenerator.cleanupOldImages();
      imagePath = await NotificationImageGenerator.generateTipImage(tip);
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _dailyTipChannelId,
        _dailyTipChannelName,
        channelDescription: _dailyTipChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.alarm,
        styleInformation: imagePath != null
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(imagePath),
                contentTitle: title,
                summaryText: 'GreenWise',
                hideExpandedLargeIcon: true,
              )
            : BigTextStyleInformation(
                body,
                contentTitle: title,
                summaryText: 'GreenWise',
              ),
        largeIcon: imagePath != null ? FilePathAndroidBitmap(imagePath) : null,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
      iOS: DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.timeSensitive,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Daily Eco Tip',
        attachments: imagePath != null
            ? [DarwinNotificationAttachment(imagePath)]
            : null,
      ),
    );

    final next = _nextInstanceOf(time);
    
    await _plugin.zonedSchedule(
      _dailyTipNotificationId,
      title,
      body,
      next,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: 'daily_tip',
    );
    
    debugPrint('✅ Fallback scheduling completed');
  }

  /// Cancel the daily reminder if scheduled.
  static Future<void> cancelDailyTipNotification() async {
    if (kIsWeb) return;
    if (!_initialized) await ensureInitialized();
    
    // Use native cancellation on Android
    if (Platform.isAndroid) {
      try {
        await _nativeChannel.invokeMethod('cancelNotification');
        debugPrint('✅ Cancelled native Android alarm');
      } catch (e) {
        debugPrint('⚠️ Could not cancel native alarm: $e');
      }
    } else {
      // Fallback for iOS/other platforms
      await _plugin.cancel(_dailyTipNotificationId);
    }
  }

  /// Show an immediate test notification (for debugging)
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
    EcoTip? tip,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await ensureInitialized();

    // Generate notification image if tip is provided
    String? imagePath;
    if (tip != null) {
      imagePath = await NotificationImageGenerator.generateTipImage(tip);
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _dailyTipChannelId,
        _dailyTipChannelName,
        channelDescription: _dailyTipChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
        styleInformation: imagePath != null
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(imagePath),
                contentTitle: title,
                summaryText: 'GreenWise',
                hideExpandedLargeIcon: true,
              )
            : BigTextStyleInformation(
                body,
                contentTitle: title,
                summaryText: 'GreenWise',
              ),
        largeIcon: imagePath != null ? FilePathAndroidBitmap(imagePath) : null,
      ),
      iOS: DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.timeSensitive,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Test Notification',
        attachments: imagePath != null
            ? [DarwinNotificationAttachment(imagePath)]
            : null,
      ),
    );

    await _plugin.show(
      999, // Use different ID for test notifications
      title,
      body,
      details,
    );
  }

  static tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    debugPrint('⏰ Computing next instance of ${time.format24h()}');
    debugPrint('   Current TZ time: $now (${tz.local.name})');
    
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    debugPrint('   Initial schedule: $scheduled');
    
    // Add minimum 2-minute buffer to avoid Android silently dropping the notification
    final minDelay = now.add(const Duration(minutes: 2));
    
    if (!scheduled.isAfter(minDelay)) {
      scheduled = scheduled.add(const Duration(days: 1));
      debugPrint('   Time too soon (need 2min buffer), scheduling for tomorrow: $scheduled');
    } else {
      debugPrint('   Time is later today: $scheduled');
    }
    
    return scheduled;
  }
}

// Extension to format TimeOfDay as 24h string for debugging
extension TimeOfDayFormat on TimeOfDay {
  String format24h() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
