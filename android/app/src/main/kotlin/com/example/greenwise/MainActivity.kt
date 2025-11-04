package com.example.greenwise

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.greenwise/native_notifications"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleNotification" -> {
                    try {
                        val hour = call.argument<Int>("hour")!!
                        val minute = call.argument<Int>("minute")!!
                        val title = call.argument<String>("title")!!
                        val body = call.argument<String>("body")!!
                        val imagePath = call.argument<String?>("imagePath")
                        
                        NotificationScheduler.scheduleNotification(this, hour, minute, title, body, imagePath)
                        result.success("Scheduled")
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "cancelNotification" -> {
                    try {
                        NotificationScheduler.cancelNotification(this)
                        result.success("Cancelled")
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "canScheduleExactAlarms" -> {
                    try {
                        val alarmManager = getSystemService(ALARM_SERVICE) as android.app.AlarmManager
                        val canSchedule = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            alarmManager.canScheduleExactAlarms()
                        } else {
                            true
                        }
                        result.success(canSchedule)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
