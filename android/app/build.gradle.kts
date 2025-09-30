import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.nccfinance.bytebank"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    // Calculate a monotonic Android versionCode from versionName (major.minor.patch)
    // and the flutter versionCode (build number). Result: MMMmmppbb
    // where MMM=major, mm=minor, pp=patch, bb=buildNumber component.
    val flutterVersionNameStr = (flutter.versionName ?: "").toString()
    val flutterBuildNumber = (flutter.versionCode as? Int) ?: 0

    val versionParts = flutterVersionNameStr.split('.')
    val major = versionParts.getOrNull(0)?.toIntOrNull() ?: 0
    val minor = versionParts.getOrNull(1)?.toIntOrNull() ?: 0
    val patch = versionParts.getOrNull(2)?.toIntOrNull() ?: 0

    val calculatedBuildVersion = major * 100_000 + minor * 10_000 + patch * 100 + flutterBuildNumber


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.nccfinance.bytebank"
        // Respect the Flutter-provided minSdkVersion but ensure the minimum required by
        // plugins (e.g. cloud_firestore). This avoids hardcoding while enforcing 23.
        val flutterMinSdk = (flutter.minSdkVersion as? Int) ?: 23
        minSdkVersion(maxOf(flutterMinSdk, 23))
        targetSdk = flutter.targetSdkVersion
        versionCode = calculatedBuildVersion
        versionName = flutter.versionName
    }

    signingConfigs {
        // Create a single 'release' signing config. It will pick values from
        // CI environment variables when present (useful for Codemagic) or fall
        // back to the local key.properties file when running locally.
        create("release") {
            val isCi = System.getenv("CI")?.toBoolean() == true
            val ciHasKeystore = !System.getenv("CM_KEYSTORE_PATH").isNullOrBlank()

            if (isCi && ciHasKeystore) {
                storeFile = file(System.getenv()["CM_KEYSTORE_PATH"])
                storePassword = System.getenv()["CM_KEYSTORE_PASSWORD"]
                keyAlias = System.getenv()["CM_KEY_ALIAS"]
                keyPassword = System.getenv()["CM_KEY_PASSWORD"]                
            } else {
                // Local development: read from key.properties (keystoreProperties)
                // Only set values when they're present in key.properties to avoid nulls
                val keyAliasProp = keystoreProperties.getProperty("keyAlias")?.takeIf { it.isNotBlank() }
                val keyPasswordProp = keystoreProperties.getProperty("keyPassword")?.takeIf { it.isNotBlank() }
                val storeFileProp = keystoreProperties.getProperty("storeFile")?.takeIf { it.isNotBlank() }
                val storePasswordProp = keystoreProperties.getProperty("storePassword")?.takeIf { it.isNotBlank() }

                keyAliasProp?.let { keyAlias = it }
                keyPasswordProp?.let { keyPassword = it }
                storeFileProp?.let { storeFile = file(it) }
                storePasswordProp?.let { storePassword = it }
            }
        }        
    } 

    buildTypes {
        release {  
            val isCi = System.getenv("CI")?.toBoolean() == true
            val ciHasKeystore = !System.getenv("CM_KEYSTORE_PATH").isNullOrBlank()

            if (isCi && ciHasKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
