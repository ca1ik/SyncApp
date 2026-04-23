package com.syncapp.couples

import android.content.Context
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import androidx.work.workDataOf

/**
 * WidgetSyncWorker — ana ekran widget'ından tetiklenen arka plan veri yazımı.
 * WorkManager garantili yürütme sağlar; Firebase uzak sunucusuna yazmak için
 * kullanılır (Flutter engine kapalıyken bile).
 *
 * NOT: Gerçek üretim senaryosunda burada bir REST API çağrısı veya
 *      direct Firestore REST API kullanılmalıdır.
 */
class WidgetSyncWorker(
    context: Context,
    params: WorkerParameters,
) : Worker(context, params) {

    companion object {
        private const val KEY_SIGNAL = "signal"

        fun enqueue(context: Context, signal: String) {
            val data = workDataOf(KEY_SIGNAL to signal)
            val request = OneTimeWorkRequestBuilder<WidgetSyncWorker>()
                .setInputData(data)
                .build()
            WorkManager.getInstance(context).enqueue(request)
        }
    }

    override fun doWork(): Result {
        val signal = inputData.getString(KEY_SIGNAL) ?: return Result.failure()

        // TODO: Firestore REST API veya Cloud Function endpoint'ine POST at
        // Bu kısım, gerçek implementasyonda HTTP isteği ile değiştirilir.
        // Örnek: FirestoreRestClient.saveMoodLog(signal)

        android.util.Log.i("WidgetSyncWorker", "Widget sinyal gönderildi: $signal")
        return Result.success()
    }
}
