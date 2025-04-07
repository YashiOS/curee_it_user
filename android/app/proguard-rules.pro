# Fix for Razorpay and missing ProGuard annotations
-keep class proguard.annotation.** { *; }
-keep @interface proguard.annotation.**
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
