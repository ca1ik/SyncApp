package com.example.sync_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/**
 * SyncNotificationHelper — partner sinyali bildirimleri oluşturucu.
 * Interaktif aksiyon düğmeleri (Geri Bildir / Sessiz Kal) içeren bildirim oluşturur.
 */
object SyncNotificationHelper {

    private const val CHANNEL_ID = "sync_partner_channel"
    private const val CHANNEL_NAME = "Partner Sinyalleri"
    private const val CHANNEL_DESCRIPTION = "Partnerinden gelen duygusal durum bildirimleri"
    private const val NOTIFICATION_ID = 1001

    private const val ACTION_REPLY = "com.example.sync_app.ACTION_NOTIFY_REPLY"
    private const val ACTION_SILENCE = "com.example.sync_app.ACTION_NOTIFY_SILENCE"

    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance).apply {
                description = CHANNEL_DESCRIPTION
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 200, 100, 200)
            }
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    fun showPartnerSignalNotification(
        context: Context,
        title: String,
        body: String,
        contentIntent: PendingIntent?,
    ) {
        createNotificationChannel(context)

        val replyIntent = Intent(ACTION_REPLY).apply {
            setPackage(context.packageName)
        }
        val replyPendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            replyIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val silenceIntent = Intent(ACTION_SILENCE).apply {
            setPackage(context.packageName)
        }
        val silencePendingIntent = PendingIntent.getBroadcast(
            context,
            1,
            silenceIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val defaultContentIntent = contentIntent ?: run {
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            PendingIntent.getActivity(
                context,
                2,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(defaultContentIntent)
            .addAction(
                android.R.drawable.ic_menu_send,
                "Geri Bildir",
                replyPendingIntent,
            )
            .addAction(
                android.R.drawable.ic_lock_silent_mode,
                "Sessiz Kal",
                silencePendingIntent,
            )
            .build()

        try {
            NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
        } catch (e: SecurityException) {
            android.util.Log.w("SyncNotificationHelper", "Bildirim izni yok: ${e.message}")
        }
    }
}
