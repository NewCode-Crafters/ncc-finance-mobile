# Useful commands

## Flutter

```sh
flutter run                # Runs the app on a connected device or emulator
flutter clean              # Cleans the build directory
flutterfire configure      # Configures Firebase for your Flutter app
flutter pub get            # Fetches dependencies listed in pubspec.yaml
flutter pub upgrade        # Upgrades dependencies to the latest versions
flutter doctor             # Checks your environment for any issues
flutter build apk          # Builds the Android APK file
flutter build ios          # Builds the iOS app
flutter analyze            # Analyzes the project for errors and warnings
flutter format .           # Formats all Dart files in the current directory
flutter create .           # Creates a new Flutter project in the current directory
flutter pub outdated       # Shows which dependencies have newer versions available
flutter pub add package_name
flutter build apk --release   # Generates a build
```

## Tests

```sh
flutter test               # Runs all unit and widget tests
flutter test test/features/authentication/notifiers/auth_notifier_test.dart # Runs an specific suit test
```

### Mocks Mocks

```sh
dart run build_runner build # Generate the mocks
dart run build_runner build --delete-conflicting-outputs # Regenerate the mocks
```

## Splash Screen & App Icon

```sh
dart run flutter_native_splash:create # Package command to create or recreate the configs
dart run flutter_launcher_icons:generate # Generates Icon for platforms
dart run flutter_launcher_icons:generate --override # Regenerates Icon for platforms
```

## Change App name

```sh
flutter pub add dev:change_app_package_name
# When you run this, the tool will automatically find and edit all the necessary native files (build.gradle, AndroidManifest.xml, Info.plist, etc.).
# when rename, Firebase must register a new app to keep working
dart run change_app_package_name:main com.nccfinance.bytebank
```

## App Secrets to Continuos Delivery

### 1 - Generates a key keystore

```sh
keytool -genkey -v -keystore sorterncc.keystore -alias sorterncc -keyalg RSA -keysize 2048 -validity 10000
```

or use a new approach:

```sh
keytool -genkeypair -v \
 -keystore sorterncc.keystore \
 -alias sorterncc \
 -keyalg RSA \
 -keysize 2048 \
 -validity 10000 \
 -sigalg SHA256withRSA

```

### 2 - Create a file at the project root named key.properties (or android/key.properties):

```sh
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=sorterncc
storeFile=android/app/sorterncc.keystore
```

### 3 - Edit build.gradle.kts (Kotlin DSL)

_Docs_

- https://docs.flutter.dev/deployment/android
- https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/

### 4 - Verify the keystore List and verify the alias and certificate:

```sh
keytool -list -v -keystore android/sorterncc.keystore -alias sorterncc
```
