package com.example.greenwise

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.io.File
import java.util.Calendar

class NotificationScheduler {
    companion object {
        private const val TAG = "NotificationScheduler"
        private const val ALARM_REQUEST_CODE = 1001
        private const val NOTIFICATION_CHANNEL_ID = "daily_tip"
        
        fun scheduleNotification(
            context: Context, 
            hour: Int, 
            minute: Int, 
            title: String, 
            body: String,
            imagePath: String? = null
        ) {
            Log.d(TAG, "Scheduling notification for $hour:$minute")
            if (imagePath != null) {
                Log.d(TAG, "With image: $imagePath")
            }
            
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            // Check if we can schedule exact alarms
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (!alarmManager.canScheduleExactAlarms()) {
                    Log.e(TAG, "Cannot schedule exact alarms - permission not granted!")
                    return
                }
            }
            
            // Create intent for the broadcast receiver
            val intent = Intent(context, NotificationReceiver::class.java).apply {
                putExtra("title", title)
                putExtra("body", body)
                if (imagePath != null) {
                    putExtra("imagePath", imagePath)
                }
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Calculate next occurrence
            val calendar = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                
                // If time has passed today, schedule for tomorrow
                if (timeInMillis <= System.currentTimeMillis()) {
                    add(Calendar.DAY_OF_MONTH, 1)
                }
            }
            
            Log.d(TAG, "Scheduling for: ${calendar.time}")
            
            // Use setAlarmClock for highest priority
            val alarmClockInfo = AlarmManager.AlarmClockInfo(
                calendar.timeInMillis,
                pendingIntent
            )
            
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
            Log.d(TAG, "Alarm scheduled successfully!")
        }
        
        fun cancelNotification(context: Context) {
            Log.d(TAG, "Cancelling scheduled notification")
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, NotificationReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
        }
    }
}

class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("NotificationReceiver", "Alarm triggered!")
        
        val title = intent.getStringExtra("title") ?: "🌱 Daily Eco Tip"
        val body = intent.getStringExtra("body") ?: "Check today's tip!"
        val imagePath = intent.getStringExtra("imagePath")
        
        // Build notification with image if available
        val notificationBuilder = NotificationCompat.Builder(context, "daily_tip")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
        
        // Add image if path is provided
        if (imagePath != null) {
            try {
                val imageFile = File(imagePath)
                if (imageFile.exists()) {
                    val bitmap = BitmapFactory.decodeFile(imagePath)
                    if (bitmap != null) {
                        notificationBuilder
                            .setLargeIcon(bitmap)
                            .setStyle(
                                NotificationCompat.BigPictureStyle()
                                    .bigPicture(bitmap)
                                    .setSummaryText("GreenWise")
                            )
                        Log.d("NotificationReceiver", "Image loaded successfully!")
                    } else {
                        Log.w("NotificationReceiver", "Failed to decode bitmap from: $imagePath")
                    }
                } else {
                    Log.w("NotificationReceiver", "Image file not found: $imagePath")
                }
            } catch (e: Exception) {
                Log.e("NotificationReceiver", "Error loading image: ${e.message}")
            }
        }
        
        val notification = notificationBuilder.build()
        NotificationManagerCompat.from(context).notify(1001, notification)
        Log.d("NotificationReceiver", "Notification shown!")
    }
}
