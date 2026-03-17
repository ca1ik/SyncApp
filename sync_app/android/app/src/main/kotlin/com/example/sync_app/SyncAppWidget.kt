package com.example.sync_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.example.sync_app.R

/**
 * SyncAppWidget — Android Ana Ekran Widget'ı.
 *
 * Kullanıcı uygulamayı açmadan ana ekrandaki widget'a dokunarak
 * "Bugün ofiste çok yoruldum, sessizliğe ihtiyacım var" sinyalini
 * Android'in native servisleri üzerinden anında iletebilir.
 *
 * Layout: res/layout/sync_app_widget.xml
 * Config: res/xml/sync_widget_info.xml
 */
class SyncAppWidget : AppWidgetProvider() {

    companion object {
        const val ACTION_SIGNAL_TAP = "com.example.sync_app.WIDGET_SIGNAL_TAP"
        const val EXTRA_SIGNAL       = "extra_signal"

        // Varsayılan sinyal düğmeleri widget'ta gösterilir
        private val QUICK_SIGNALS = listOf(
            "exhausted"  to "🔋 Yoruldum",
            "need_silence" to "🤫 Sessizlik",
            "need_hug"   to "🤗 Sarıl",
        )

        /**
         * Widget içeriğini günceller.
         * Flutter'dan MethodChannel aracılığıyla çağrılır.
         */
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            signal: String,
            energyLevel: Int,
            toleranceLevel: Int,
            displayName: String,
        ) {
            val views = RemoteViews(context.packageName, R.layout.sync_app_widget)

            // Kullanıcı adı ve enerji seviyesi
            views.setTextViewText(
                R.id.widget_user_name,
                displayName,
            )
            views.setTextViewText(
                R.id.widget_energy_text,
                "🔋 $energyLevel% · 🧘 $toleranceLevel%",
            )
            views.setTextViewText(
                R.id.widget_signal_text,
                signalToEmoji(signal),
            )

            // Her hızlı sinyal düğmesi için PendingIntent
            QUICK_SIGNALS.forEachIndexed { index, (sig, _) ->
                val btnId = when (index) {
                    0 -> R.id.widget_btn_1
                    1 -> R.id.widget_btn_2
                    else -> R.id.widget_btn_3
                }
                val pi = buildSignalPendingIntent(context, sig, appWidgetId)
                views.setOnClickPendingIntent(btnId, pi)
            }

            // Uygulamayı açan merkez dokunma
            val openAppIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            val openPi = PendingIntent.getActivity(
                context, appWidgetId + 1000, openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_main_area, openPi)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun buildSignalPendingIntent(
            context: Context,
            signal: String,
            widgetId: Int,
        ): PendingIntent {
            val intent = Intent(context, WidgetSignalReceiver::class.java).apply {
                action = ACTION_SIGNAL_TAP
                putExtra(EXTRA_SIGNAL, signal)
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                `package` = context.packageName
            }
            // requestCode sinyal başına farklı → her düğme benzersiz PI alır
            val requestCode = signal.hashCode() and 0xFFFF
            return PendingIntent.getBroadcast(
                context, requestCode, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun signalToEmoji(signal: String): String = when (signal) {
            "need_hug"     -> "🤗 Sarılmaya ihtiyacım var"
            "need_silence" -> "🤫 Sessizliğe ihtiyacım var"
            "need_space"   -> "🌙 Biraz yalnız kalmam lazım"
            "need_talk"    -> "💬 Konuşmaya hazırım"
            "exhausted"    -> "🔋 Çok yoruldum"
            "happy"        -> "✨ Harika hissediyorum"
            "anxious"      -> "🫂 Biraz kaygılıyım"
            else           -> "😊 Her şey normal"
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { id ->
            updateWidget(
                context          = context,
                appWidgetManager = appWidgetManager,
                appWidgetId      = id,
                signal           = "neutral",
                energyLevel      = 0,
                toleranceLevel   = 0,
                displayName      = "Sync",
            )
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        // Widget ilk kez ekranına eklendiğinde tetiklenir
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        // Son widget ekrandan kaldırıldığında
    }
}

/**
 * WidgetSignalReceiver — widget üzerindeki sinyal düğmelerini dinler.
 * Sinyal, WorkManager aracılığıyla Firestore'a yazılır.
 */
class WidgetSignalReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != SyncAppWidget.ACTION_SIGNAL_TAP) return

        val signal = intent.getStringExtra(SyncAppWidget.EXTRA_SIGNAL) ?: return

        // Flutter engine çalışıyorsa MethodChannel aracılığıyla ilet,
        // değilse WorkManager ile background sync tetikle.
        WidgetSyncWorker.enqueue(context, signal)

        // Widget'taki görsel anında güncelle (optimistic update)
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val ids = appWidgetManager.getAppWidgetIds(
            ComponentName(context, SyncAppWidget::class.java)
        )
        ids.forEach { id ->
            SyncAppWidget.updateWidget(
                context = context,
                appWidgetManager = appWidgetManager,
                appWidgetId = id,
                signal = signal,
                energyLevel = 0,
                toleranceLevel = 0,
                displayName = "Sync",
            )
        }
    }
}
