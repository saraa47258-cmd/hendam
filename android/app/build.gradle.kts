plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.hindam"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"   // ✅ الصحيح (بدون f)

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.hindam"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // Firebase Analytics requires minSdk 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.mediapipe:tasks-vision:latest.release")

    // Keep AndroidX versions compatible with AGP 8.8.0
    constraints {
        implementation("androidx.activity:activity-ktx") {
            version { strictly("1.10.1") }
            because("AGP 8.8.0 compatibility")
        }
        implementation("androidx.activity:activity") {
            version { strictly("1.10.1") }
            because("AGP 8.8.0 compatibility")
        }
        implementation("androidx.core:core-ktx") {
            version { strictly("1.16.0") }
            because("AGP 8.8.0 compatibility")
        }
        implementation("androidx.core:core") {
            version { strictly("1.16.0") }
            because("AGP 8.8.0 compatibility")
        }
        implementation("androidx.navigationevent:navigationevent-android") {
            version { strictly("1.0.0") }
            because("AGP 8.8.0 compatibility")
        }
    }
}
