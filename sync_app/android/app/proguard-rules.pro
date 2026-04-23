# Sync — ProGuard / R8 kuralları

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Billing (in_app_purchase)
-keep class com.android.billingclient.api.** { *; }
-dontwarn com.android.billingclient.api.**

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Google Play Core (deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# flutter_local_notifications
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Kotlin
-keep class kotlin.Metadata { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlinx.**

# Genel json modeller
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Stack trace okunabilir kalsın
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.android.AndroidExceptionPreHandler {
    <init>();
}
-keepclassmembers class kotlinx.coroutines.android.AndroidDispatcherFactory {
    <init>();
}
