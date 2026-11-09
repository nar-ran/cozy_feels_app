# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Google Sign In & Google APIs
-keep class com.google.android.gms.auth.api.signin.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.api.client.**

# Core attributes & Line Numbers for Crash Reporting
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,SourceFile,LineNumberTable
-dontwarn java.lang.invoke.**

# Flutter Play Store Split / Deferred Components
-dontwarn com.google.android.play.core.**
