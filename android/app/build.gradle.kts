import java.util.Properties
import java.io.File
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cureeit.medkaro"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    // --- OPTIONAL: only used if key.properties exists ---
    val keyPropertiesFile: File = rootProject.file("key.properties")
    val keyProperties = Properties()
    if (keyPropertiesFile.exists()) {
        keyProperties.load(FileInputStream(keyPropertiesFile))
    }

    signingConfigs {
        // Create "release" ONLY if key.properties exists
        if (keyPropertiesFile.exists()) {
            create("release") {
                storeFile = file(keyProperties["storeFile"] as String)
                storePassword = keyProperties["storePassword"] as String
                keyAlias = keyProperties["keyAlias"] as String
                keyPassword = keyProperties["keyPassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.cureeit.medkaro"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 4
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // 🔥 If release signing is not defined, fall back to debug for local builds
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")

            isMinifyEnabled = false
            isShrinkResources = false
        }

        // debug is normal, no changes needed
        getByName("debug") {
            // uses default debug signing
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
