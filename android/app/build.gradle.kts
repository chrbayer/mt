import java.io.FileInputStream
import java.util.Properties

// Written by build_android.sh from the MT_KEYSTORE_* environment variables and
// deleted again afterwards, so the signing secrets never live in the repo.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        FileInputStream(keystorePropertiesFile).use { load(it) }
    }
}

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.chrbayer.mathe_trainer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.chrbayer.mathe_trainer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Gradle legt sonst einen verschlüsselten Block mit der Liste der
    // Abhängigkeiten ins APK, den nur Google Play liest. F-Droid weist ein
    // APK mit diesem Block ab ("Found extra signing block 'Dependency
    // metadata'"), und zu Recht: er ist von außen nicht nachprüfbar.
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Falls back to the debug key so `flutter run --release` keeps
            // working without a keystore. Anything installed that way cannot
            // later be updated by a properly signed build - Android refuses a
            // signature change - so set MT_KEYSTORE_PATH before handing the
            // app to anyone.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// Version codes for APKs split by ABI (`flutter build apk --split-per-abi`).
//
// F-Droid builds one APK per ABI and expects the code as versionCode * 10 plus
// a digit per ABI - 21306 becomes 213061, 213062 and 213063. Its client picks
// the highest code a device can run, so the digits climb with capability:
// an arm64 tablet that could also run 32-bit code gets the arm64 APK.
//
// Flutter would put abi * 1000 in front instead (2021306); the property turns
// that off so there is exactly one scheme. The universal APK carries no ABI
// filter and keeps the plain code from pubspec.yaml.
extra["force-version-code-ignoring-abi"] = "true"

val abiDigits = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)

@Suppress("DEPRECATION")
(extensions.getByName("android") as com.android.build.gradle.AppExtension)
    .applicationVariants.all {
        val baseCode = versionCode
        outputs.all {
            val output = this as com.android.build.gradle.api.ApkVariantOutput
            val abi = output.getFilter(com.android.build.VariantOutput.FilterType.ABI)
            val digit = abiDigits[abi] ?: return@all
            output.versionCodeOverride = baseCode * 10 + digit
        }
    }

// Native libraries that plugins compile from C during the build (so far only
// libdartjni.so from package:jni) must come out byte for byte the same on
// every machine, or F-Droid's reproducible build rejects the release.
//
// They do not by default. The NDK links with --build-id=sha1, and that ID is a
// hash over the unstripped library - debug info included, which records
// absolute paths like the NDK's install location. The stripped library in the
// APK keeps the ID, so a different NDK path changes bytes in the APK even when
// the code is identical. That was exactly the one file F-Droid reported.
//
// Turning the ID off for every plugin's CMake build removes the only
// path-dependent bytes. The NDK's own linker flags stay; this one comes later on
// the command line and wins. Nothing here reads the ID: there is no crash
// reporting to symbolise against it.
rootProject.subprojects {
    plugins.withId("com.android.library") {
        @Suppress("DEPRECATION")
        (extensions.getByName("android") as com.android.build.gradle.LibraryExtension)
            .defaultConfig.externalNativeBuild.cmake
            .arguments("-DCMAKE_SHARED_LINKER_FLAGS=-Wl,--build-id=none")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
