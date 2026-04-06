plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.counselign"
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
        applicationId = "com.example.counselign"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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

// -----------------------
// Post-build APK rename task
// -----------------------
tasks.register<Copy>("renameReleaseApk") {
    val releaseDir = layout.buildDirectory.dir("outputs/flutter-apk").get().asFile
    val releaseApk = releaseDir.resolve("app-release.apk")
    val renamedApk = releaseDir.resolve("counselign-v${android.defaultConfig.versionName}.apk")

    from(releaseApk)
    into(releaseDir)
    rename { renamedApk.name }

    doLast {
        println("✅ APK renamed to ${renamedApk.name}")
    }
}

// Optional: Combine build + rename
tasks.register("buildAndRenameReleaseApk") {
    dependsOn("assembleRelease")
    finalizedBy("renameReleaseApk")
}
