# ------------------------------
# ML Kit - Text Recognition (OCR)
# ------------------------------
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Google Play services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Firebase (nếu bạn dùng)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# AndroidX và các lớp hỗ trợ
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Giữ lại các lớp dùng qua reflection
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod
