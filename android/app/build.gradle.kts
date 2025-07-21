plugins {
    id("com.android.application")
    id("kotlin-android")
    // ✅ Flutter plugin must be applied after Android & Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.timetable_ai"  // ✅ Correct namespace used here
    compileSdk = flutter.compileSdkVersion  // ✅ Inherited from Flutter
    ndkVersion = "27.0.12077973"            // ✅ Optional but fine

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.timetable_ai" // ✅ Must match your namespace
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // ⚠️ Only for development
        }
    }
}

flutter {
    source = "../.."
}
