# Keep attributes needed for Gson serialization
-keepattributes Signature
-keepattributes *Annotation*

# Keep Gson model classes
-keep class com.google.gson.** { *; }

# Prevent ProGuard from removing necessary Gson classes
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep Gson field names
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Keep TypeToken
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken { *; }

# Prevent ProGuard from obfuscating Flutter classes
-keep class io.flutter.** { *; }
-keep class com.quickattend.** { *; }

# Keep all R (resources) classes, including drawables
-keep class com.quickattend.R$* { *; }

# Keep drawables specifically
-keep class android.R$drawable { *; }
-keep class com.quickattend.R$drawable { *; }
-keep class * extends android.app.Application { *; }


-dontwarn sun.misc.**
