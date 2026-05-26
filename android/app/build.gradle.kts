plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.feloosy.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.feloosy.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "FELOOSY Dev")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "FELOOSY")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// home_widget 0.9.x transitively pulls in glance-appwidget:1.3.0-alpha01
// which requires AGP 9.1.0 and compileSdk 37. Force the stable 1.1.0
// that is compatible with AGP 8.x.
configurations.all {
    resolutionStrategy.force(
        "androidx.glance:glance:1.1.0",
        "androidx.glance:glance-appwidget:1.1.0",
        "androidx.glance:glance-preview:1.1.0",
    )
}
