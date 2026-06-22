plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.togedog"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.togedog"
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

    packaging {
        jniLibs {
            // Required for dlopen('libtensorflowlite_jni.so') in tflite_flutter 0.12.x
            useLegacyPackaging = true
        }
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

// litert:2.1.5 already includes all classes from litert-api:1.4.0
configurations.all {
    exclude(group = "com.google.ai.edge.litert", module = "litert-api")
}

// tflite_flutter dlopens "libtensorflowlite_jni.so", but ultralytics_yolo forces
// com.google.ai.edge.litert:litert to 2.1.5, which ships that same runtime as "libLiteRt.so"
// (identical TFLite C API symbols). Duplicate the merged libLiteRt.so under the name
// tflite_flutter expects so both consumers load one runtime.
androidComponents {
    onVariants(selector().all()) { variant ->
        val capName = variant.name.replaceFirstChar { it.uppercaseChar() }
        tasks.matching { it.name == "merge${capName}NativeLibs" }.configureEach {
            doLast {
                outputs.files.asFileTree.matching { include("**/libLiteRt.so") }.forEach { liteRt ->
                    liteRt.copyTo(liteRt.resolveSibling("libtensorflowlite_jni.so"), overwrite = true)
                }
            }
        }
    }
}
