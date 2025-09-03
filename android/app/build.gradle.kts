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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nccfinance.bytebank"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = calculatedBuildVersion
        versionName = flutter.versionName
    }

    signingConfigs {
        // Create a single 'release' signing config. It will pick values from
        // CI environment variables when present (useful for Codemagic) or fall
        // back to the local key.properties file when running locally.
        create("release") {
          if (System.getenv()["CI"].toBoolean()) {
                storeFile = file(System.getenv()["CM_KEYSTORE_PATH"])
                storePassword = System.getenv()["CM_KEYSTORE_PASSWORD"]
                keyAlias = System.getenv()["CM_KEY_ALIAS"]
                keyPassword = System.getenv()["CM_KEY_PASSWORD"]                
            } else {
                // Local development: read from key.properties (keystoreProperties)
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")            
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
