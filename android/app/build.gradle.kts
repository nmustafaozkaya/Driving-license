plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.util.Properties
import java.io.FileInputStream

// Load keystore from key.properties (android/ directory root) and validate
val keystoreProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) {
        this.load(FileInputStream(f))
    }
}
val propStoreFile = keystoreProps.getProperty("storeFile")
val propStorePassword = keystoreProps.getProperty("storePassword")
val propKeyAlias = keystoreProps.getProperty("keyAlias")
val propKeyPassword = keystoreProps.getProperty("keyPassword")
if (propStoreFile.isNullOrBlank() || propStorePassword.isNullOrBlank() ||
    propKeyAlias.isNullOrBlank() || propKeyPassword.isNullOrBlank()) {
    throw GradleException("Missing signing properties. Ensure android/key.properties has storeFile, storePassword, keyAlias, keyPassword.")
}
// Resolve keystore path: absolute path -> file(...), otherwise relative to repo root
val storeFileResolved = if (propStoreFile.startsWith("/") || propStoreFile.contains(":")) {
    file(propStoreFile)
} else {
    rootProject.file(propStoreFile)
}
if (!storeFileResolved.exists()) {
    throw GradleException("Keystore file not found: ${storeFileResolved}. Update storeFile in android/key.properties or use an absolute path.")
}

android {
    namespace = "com.trafikkocu.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.trafikkocu.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Optional: ship only Turkish resources to reduce size
        resourceConfigurations.addAll(listOf("tr"))
    }

    signingConfigs {
        create("release") {
            storeFile = storeFileResolved
            storePassword = propStorePassword
            keyAlias = propKeyAlias
            keyPassword = propKeyPassword
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Force release signing; do not fall back to debug to avoid Play Console errors
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
