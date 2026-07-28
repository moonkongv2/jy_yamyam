import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val isReleaseBuild = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true)
}

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use {
        keystoreProperties.load(it)
    }
} else if (isReleaseBuild) {
    throw GradleException("Release signing requires android/key.properties. Create it manually before building a release.")
}

fun requiredSigningProperty(name: String): String {
    val value = keystoreProperties.getProperty(name)
    if (value.isNullOrBlank() && isReleaseBuild) {
        throw GradleException("Release signing requires '$name' in android/key.properties.")
    }
    return value.orEmpty()
}

android {
    namespace = "com.yamyamrider.app"
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
        applicationId = "com.yamyamrider.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = requiredSigningProperty("keyAlias")
            keyPassword = requiredSigningProperty("keyPassword")
            storePassword = requiredSigningProperty("storePassword")

            val storeFilePath = requiredSigningProperty("storeFile")
            if (storeFilePath.isNotBlank()) {
                val releaseStoreFile = file(storeFilePath)
                if (!releaseStoreFile.exists() && isReleaseBuild) {
                    throw GradleException("Release signing storeFile from android/key.properties does not exist.")
                }
                storeFile = releaseStoreFile
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
