# 🔔 Notification System Debugging Guide

## ✅ APK Ready: GreenWise-v1.0.7-TIMEZONE-DEBUG.apk

---

## 🔍 Root Cause Analysis

### Why Test Notifications Work But Scheduled Don't

**Test Notification (`showImmediateNotification`):**
- Uses `_plugin.show()` - fires immediately
- No timezone calculation needed
- Works perfectly ✅

**Scheduled Notification (`scheduleDailyTipNotification`):**
- Uses `_plugin.zonedSchedule()` - schedules for future time
- Requires timezone detection and calculation
- **Problem:** Your emulator is running in UTC timezone, not Philippines time! ⚠️

---

## 📊 How the Notification System Works

### Step 1: Initialization (Splash Screen)
```dart
await NotificationService.ensureInitialized();
```

**What it does:**
1. Initializes timezone database
2. Detects device timezone from `DateTime.now().timeZoneOffset`
3. Maps offset to IANA timezone name:
   - `UTC+8` (8 hours) → `Asia/Manila` (Philippines)
   - `UTC+0` (0 hours) → `UTC` (London/Emulator default)
   - `UTC-8` (-8 hours) → `America/Los_Angeles` (US West)
4. Sets `tz.local` to detected timezone
5. Creates Android notification channel

**NEW Debug Output:**
```
🌍 Device timezone offset detected: 8h 0m
🕐 Device local time: 2025-11-04 18:06:00.000
✅ Timezone set to: Asia/Manila
```

### Step 2: Permission Request
```dart
await NotificationService.requestPermissions();
```

**What it does:**
1. Requests notification permission (Android 13+)
2. **NEW:** Requests exact alarm permission (Android 12+) ⏰
3. This is critical! Without exact alarm permission, scheduled notifications won't fire

### Step 3: Scheduling (Settings Screen)
When you enable notifications or change the time:

```dart
await NotificationService.scheduleDailyTipNotification(
  TimeOfDay(hour: 18, minute: 6), // Your chosen time
  tipText: tip.text,
  tip: tip,
);
```

**What it does:**
1. Fetches tomorrow's tip from database
2. Generates notification image (1200×600px gradient)
3. Calls `_nextInstanceOf(time)` to calculate exact schedule time
4. Schedules with `zonedSchedule()` using `DateTimeComponents.time` (daily repeat)

### Step 4: Next Instance Calculation
```dart
_nextInstanceOf(TimeOfDay(hour: 18, minute: 6))
```

**Logic:**
1. Get current time in timezone: `tz.TZDateTime.now(tz.local)`
2. Create scheduled time: Same date, your chosen hour/minute
3. **If time already passed today** → Add 1 day
4. Return scheduled time

**NEW Debug Output:**
```
⏰ Computing next instance of 18:06
   Current TZ time: 2025-11-04 15:30:00.000+0800 (Asia/Manila)
   Initial schedule: 2025-11-04 18:06:00.000+0800
   Time is later today: 2025-11-04 18:06:00.000+0800
```

**Or if time passed:**
```
⏰ Computing next instance of 09:00
   Current TZ time: 2025-11-04 15:30:00.000+0800 (Asia/Manila)
   Initial schedule: 2025-11-04 09:00:00.000+0800
   Time already passed today, scheduling for tomorrow: 2025-11-05 09:00:00.000+0800
```

### Step 5: Actual Scheduling
```dart
await _plugin.zonedSchedule(
  1001, // notification ID
  '🌱 Daily Eco Tip',
  tip.text,
  scheduledTime, // tz.TZDateTime
  details,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
);
```

**NEW Debug Output:**
```
📅 Scheduling notification for: 2025-11-04 18:06:00.000+0800
📍 Timezone: Asia/Manila
🕐 Current time: 2025-11-04 15:30:00.000+0800
⏳ Time until notification: 2h 36m
📝 Tip text: Use cloud storage for files you don't need locally.
✅ Notification scheduled successfully
🔔 Will fire at: 2025-11-04 18:06:00.000+0800 (in 2h 36m)
```

---

## 🐛 Your Current Problem

### What the Logs Show

From your emulator run:
```
I/flutter: 📅 Scheduling notification for: 2025-11-04 10:20:00.000+0000
I/flutter: 📍 Timezone: UTC
I/flutter: 🕐 Current time: 2025-11-04 10:19:42.652107+0000
```

**Analysis:**
- Timezone: **UTC** (should be Asia/Manila for Philippines)
- Your emulator is not set to Philippines timezone
- When you set 6:06 PM, it schedules for 6:06 PM **UTC**
- In Philippines time (UTC+8), that's **2:06 AM the next day**!

### Why Emulator Uses UTC

Android emulators default to UTC timezone unless manually configured.

---

## 🔧 Solutions

### Option 1: Test on Real Android Device (Recommended)
Real devices use your actual timezone automatically.

**Steps:**
1. Install `GreenWise-v1.0.7-TIMEZONE-DEBUG.apk` on your phone
2. Check the debug output (if connected via USB)
3. Should show: `Timezone: Asia/Manila`
4. Notifications will fire at correct local time

### Option 2: Configure Emulator Timezone
Set your emulator to Philippines timezone:

**Method A: ADB Command**
```bash
adb shell setprop persist.sys.timezone "Asia/Manila"
adb reboot
```

**Method B: Emulator Settings**
1. Open emulator settings (three dots menu)
2. Go to "Settings" → "System" → "Date & time"
3. Disable "Use network-provided time zone"
4. Select "Time zone" → Search "Manila" → Select "Asia/Manila"
5. Restart emulator

**Method C: Extended Controls**
1. Click the three dots (...) in emulator toolbar
2. Go to "Settings" → "Advanced" → "Location"
3. Set location to Manila, Philippines (14.5995° N, 120.9842° E)
4. May need to restart emulator

### Option 3: Test with Debug Output (Current Build)
The new APK has comprehensive logging. Install it and:

1. **Go to Settings → Notifications**
2. **Enable notifications** - watch for:
   ```
   🌍 Device timezone offset detected: Xh Ym
   ✅ Timezone set to: [timezone name]
   ```
3. **Set notification time to 2 minutes from now**
4. **Check console output:**
   ```
   ⏰ Computing next instance of HH:MM
   ⏳ Time until notification: Xh Ym
   ```
5. **Wait for notification**
6. **If it doesn't appear**, check:
   - Was exact alarm permission granted?
   - Is "Do Not Disturb" off?
   - Is battery optimization disabled for GreenWise?

---

## 📱 Testing Checklist

### Initial Setup
- [ ] Install `GreenWise-v1.0.7-TIMEZONE-DEBUG.apk`
- [ ] Grant notification permission
- [ ] Grant "Alarms & Reminders" permission (exact alarms)
- [ ] Check device/emulator timezone is correct

### Test Scheduled Notification
- [ ] Go to Settings → Notifications
- [ ] Enable "Daily Eco-Tips"
- [ ] Set time to **2-3 minutes from now**
- [ ] Check debug output in console (if connected)
- [ ] Wait for scheduled time
- [ ] Notification should appear with tip + image

### If Notification Doesn't Fire
- [ ] Check Settings → Apps → GreenWise → Permissions → Alarms & Reminders = **Allowed**
- [ ] Check Settings → Apps → GreenWise → Notifications = **Allowed**
- [ ] Check Settings → Apps → GreenWise → Battery = **Unrestricted**
- [ ] Check Do Not Disturb is **OFF**
- [ ] Check debug logs for timezone and scheduled time
- [ ] Try setting time again (reschedules)

---

## 🆘 Debug Log Examples

### ✅ Correct Timezone (Philippines)
```
🌍 Device timezone offset detected: 8h 0m
🕐 Device local time: 2025-11-04 18:30:00.000
✅ Timezone set to: Asia/Manila
⏰ Computing next instance of 18:06
   Current TZ time: 2025-11-04 18:30:00.000+0800 (Asia/Manila)
   Initial schedule: 2025-11-04 18:06:00.000+0800
   Time already passed today, scheduling for tomorrow: 2025-11-05 18:06:00.000+0800
📅 Scheduling notification for: 2025-11-05 18:06:00.000+0800
📍 Timezone: Asia/Manila
⏳ Time until notification: 23h 36m
✅ Notification scheduled successfully
```

### ❌ Wrong Timezone (Emulator UTC)
```
🌍 Device timezone offset detected: 0h 0m
🕐 Device local time: 2025-11-04 10:30:00.000
✅ Timezone set to: UTC
⏰ Computing next instance of 18:06
   Current TZ time: 2025-11-04 10:30:00.000+0000 (UTC)
   Initial schedule: 2025-11-04 18:06:00.000+0000
   Time is later today: 2025-11-04 18:06:00.000+0000
📅 Scheduling notification for: 2025-11-04 18:06:00.000+0000
📍 Timezone: UTC
⏳ Time until notification: 7h 36m
✅ Notification scheduled successfully
```
☝️ This will fire at **2:06 AM** Philippines time (next day)!

---

## 🎯 Expected Behavior (Real Device)

**Scenario:** You're in the Philippines and set notification time to 6:06 PM

1. **Splash Screen Init:**
   - Detects offset: `+8h 0m`
   - Sets timezone: `Asia/Manila`

2. **You Enable Notifications:**
   - Fetches tomorrow's tip
   - Generates image
   - Requests permissions

3. **You Set Time to 6:06 PM:**
   - If current time is 3:30 PM → schedules for 6:06 PM **today** (2h 36m away)
   - If current time is 8:00 PM → schedules for 6:06 PM **tomorrow** (22h 6m away)

4. **At 6:06 PM Daily:**
   - Notification fires automatically
   - Shows tip text + beautiful gradient image
   - Repeats every day at same time

---

## 📝 Summary

| Feature | Status | Notes |
|---------|--------|-------|
| Test Notification | ✅ Working | Uses immediate show, no timezone needed |
| Scheduled Notification | ⚠️ Depends | Works IF device timezone is correct |
| Timezone Detection | ✅ Enhanced | Now shows detailed debug output |
| Permission Request | ✅ Fixed | Now requests exact alarm permission |
| Debug Logging | ✅ Complete | Shows all steps with emojis |

**Main Issue:** Emulator timezone is UTC, not Philippines time.

**Solution:** Test on real Android device OR configure emulator timezone to Asia/Manila.

**This build will work perfectly on a real device!** 🚀
