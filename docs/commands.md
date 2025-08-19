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
```

## Tests

```sh
flutter test               # Runs all unit and widget tests
flutter test test/features/authentication/notifiers/auth_notifier_test.dart
```

- dart run build_runner build # Generate the mocks
- dart run build_runner build --delete-conflicting-outputs # Regenerate the mocks