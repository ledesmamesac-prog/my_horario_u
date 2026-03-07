# ─── Flutter ──────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ─── sqflite ──────────────────────────────────────────────────────────────────
-keep class com.tekartik.sqflite.** { *; }

# ─── flutter_local_notifications ──────────────────────────────────────────────
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*

# ─── timezone (dart_native) ───────────────────────────────────────────────────
-keep class com.example.** { *; }
-keep class org.threeten.** { *; }

# ─── permission_handler ───────────────────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }

# ─── image_picker ─────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.imagepicker.** { *; }

# ─── Gson / JSON (por si algún plugin lo usa) ─────────────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# ─── General: evitar eliminar clases con callbacks nativos ────────────────────
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclasseswithmembernames class * {
    native <methods>;
}
