pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    // ضروري لمشاريع Flutter
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    // أماكن البحث عن الإضافات (Plugins)
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    // لودر Flutter (اترك النسخة كما هي من قالب Flutter)
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    // نسخ الـ AGP و Kotlin حسب بيئتك
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false

    // ✅ أضف نسخة Google Services هنا
    id("com.google.gms.google-services") version "4.4.4" apply false
}

// الموديول الأساسي للتطبيق
include(":app")
