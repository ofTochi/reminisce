plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.reminisce"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // In Kotlin DSL, this must be accessed via 'isCoreLibraryDesugaringEnabled'
        isCoreLibraryDesugaringEnabled = true
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Fixed the deprecation warning by moving to the compilerOptions DSL
    kotlinOptions {
        jvmTarget = "17"
    }
    
    // To fully satisfy the deprecation notice mentioned in your error:
    // Some newer Gradle versions prefer this block instead of the one above:
    /*
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
    */

    defaultConfig {
        applicationId = "com.example.reminisce"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
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

dependencies {
    // Ensure you use parentheses for Kotlin DSL
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}