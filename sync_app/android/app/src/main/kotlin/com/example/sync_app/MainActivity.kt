package com.example.sync_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity — Flutter ↔ Android Native köprüsü.
 *
 * İki MethodChannel:
 *  1. native_bridge  : Ana ekran widget güncellemesi ve interactive bildirimler.
 *  2. home_widget    : Android AppWidget sinyali gönderme (tek dokunuş).
 */
class MainActivity : FlutterActivity() {

    private val nativeChannel = "com.example.sync_app/native_bridge"
    private val widgetChannel  = "com.example.sync_app/home_widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── 1. Native Bridge Channel ─────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, nativeChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateHomeWidget" -> {
                        // Flutter'dan gelen ruh hali verisiyle home widget'ı güncelle
                        val signal       = call.argument<String>("signal")       ?: "neutral"
                        val energyLevel  = call.argument<Int>("energyLevel")     ?: 0
                        val toleranceLevel = call.argument<Int>("toleranceLevel") ?: 0
                        val displayName  = call.argument<String>("displayName")  ?: "Sen"

                        updateSyncWidget(signal, energyLevel, toleranceLevel, displayName)
                        result.success(true)
                    }

                    "showInteractivePushNotification" -> {
                        // Partnerden gelen acil sinyali native notification olarak göster
                        val title   = call.argument<String>("title")   ?: "Sync"
                        val body    = call.argument<String>("body")    ?: ""
                        val signal  = call.argument<String>("signal")  ?: "neutral"

                        showInteractiveNotification(title, body, signal)
                        result.success(true)
                    }

                    "getBatteryLevel" -> {
                        // Test amaçlı native pil seviyesi okuma
                        result.success(getNativeBatteryLevel())
                    }

                    else -> result.notImplemented()
                }
            }

        // ── 2. Home Widget Channel ───────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, widgetChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestWidgetInstall" -> {
                        // Android 12+ widget ekleme isteği
                        requestWidgetPin()
                        result.success(true)
                    }

                    "sendWidgetSignal" -> {
                        // Uygulama kapalıyken widget üzerinden gelen signal
                        val signal = call.argument<String>("signal") ?: "neutral"
                        broadcastWidgetSignal(signal)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    /**
     * SyncAppWidget içeriğini günceller.
     * RemoteViews ile widget layout'unu değiştirir ve AppWidgetManager'a gönderir.
     */
    private fun updateSyncWidget(
        signal: String,
        energyLevel: Int,
        toleranceLevel: Int,
        displayName: String
    ) {
        val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
        val componentName    = ComponentName(applicationContext, SyncAppWidget::class.java)
        val widgetIds        = appWidgetManager.getAppWidgetIds(componentName)

        widgetIds.forEach { widgetId ->
            SyncAppWidget.updateWidget(
                context          = applicationContext,
                appWidgetManager = appWidgetManager,
                appWidgetId      = widgetId,
                signal           = signal,
                energyLevel      = energyLevel,
                toleranceLevel   = toleranceLevel,
                displayName      = displayName,
            )
        }
    }

    /**
     * Partnerin sinyaline dair interaktif bildirim göster.
     * Bildirimde "Tamam" ve "Sonra Hatırlat" aksiyonları bulunur.
     */
    private fun showInteractiveNotification(title: String, body: String, signal: String) {
        // Notification intent — uygulamayı açar ve sinyal bilgisini iletir
        val intent = Intent(applicationContext, MainActivity::class.java).apply {
            putExtra("partner_signal", signal)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        SyncNotificationHelper.showPartnerSignalNotification(
            context = applicationContext,
            title   = title,
            body    = body,
            intent  = intent,
        )
    }

    /** Android widget pin isteği (API 26+) */
    private fun requestWidgetPin() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val widgetManager = getSystemService(AppWidgetManager::class.java)
            val provider      = ComponentName(this, SyncAppWidget::class.java)
            if (widgetManager.isRequestPinAppWidgetSupported) {
                widgetManager.requestPinAppWidget(provider, null, null)
            }
        }
    }

    /** Widget sinyal broadcast'i — uygulama kapalı olsa bile çalışır */
    private fun broadcastWidgetSignal(signal: String) {
        val intent = Intent(SyncAppWidget.ACTION_SIGNAL_TAP).apply {
            putExtra(SyncAppWidget.EXTRA_SIGNAL, signal)
            `package` = packageName
        }
        sendBroadcast(intent)
    }

    private fun getNativeBatteryLevel(): Int {
        val batteryManager = getSystemService(BATTERY_SERVICE) as android.os.BatteryManager
        return batteryManager.getIntProperty(android.os.BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }
}
