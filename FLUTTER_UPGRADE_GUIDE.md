# Flutter SDK 3.35.7 Upgrade Guide

This document provides guidance for upgrading to Flutter SDK 3.35.7 and ensuring consistency across development environments and CI/CD pipelines.

## What Changed

### Version Updates
- **Previous SDK**: `^3.8.1` (Flutter ~3.5.x - 3.8.x)
- **New SDK**: `^3.35.7` (Flutter 3.35.7)
- **Revision**: `adc901062556672b4138e18a4dc62a4be8f4b3c2`

### Files Modified
- `pubspec.yaml` - Updated SDK constraint
- `.metadata` - Updated Flutter revision for all platforms
- `README.md` - Updated Flutter version requirement
- `README.pt_BR.md` - Updated Flutter version requirement (Portuguese)
- `codemagic.yaml` - **NEW** - CodeMagic CI/CD configuration file

## CodeMagic CI/CD Configuration

A new `codemagic.yaml` file has been added to ensure consistent Flutter version across all CI/CD workflows:

### Workflows Configured

1. **DEV-WORKFLOW** - PR Validation
   - Triggers: PRs from `task/*`, `fix/*`, `enhancement/*` branches
   - Steps: pub get, analyze, test, debug build

2. **HOMOLOG-WORKFLOW** - Staging Builds
   - Triggers: PRs from `dev` branch
   - Steps: pub get, analyze, test, release builds
   - Output: APK and IPA artifacts distributed via Firebase App Distribution

3. **PROD-WORKFLOW** - Production Builds
   - Triggers: Push to `main` or release tags
   - Steps: pub get, analyze, test, release builds (APK, AAB, IPA)
   - Output: Production artifacts for distribution

### Environment Variables Required in CodeMagic

The following environment variables need to be configured in CodeMagic:

- `FIREBASE_SERVICE_ACCOUNT` - Firebase service account credentials
- `FIREBASE_APP_ID` - Firebase App ID for distribution

## Local Development Setup

### Step 1: Update Flutter

If you're using Flutter installed via official installer:

```bash
flutter channel stable
flutter upgrade
flutter --version
```

Verify you have Flutter 3.35.7 or later.

### Step 2: Clean and Get Dependencies

```bash
cd ncc-finance-mobile
flutter clean
flutter pub get
```

### Step 3: Verify Installation

```bash
# Check Flutter version
flutter --version

# Should show: Flutter 3.35.7 or later
```

## Testing Checklist

After upgrading, perform the following tests:

### 1. Dependency Resolution
```bash
flutter pub get
```
✅ Verify all dependencies resolve without conflicts

### 2. Static Analysis
```bash
flutter analyze
```
✅ Verify no new errors or warnings are introduced

### 3. Unit Tests
```bash
flutter test
```
✅ Verify all tests pass

### 4. Build Verification

**Android Debug:**
```bash
flutter build apk --debug
```

**Android Release:**
```bash
flutter build apk --release
```

**iOS (on macOS):**
```bash
flutter build ios --release --no-codesign
```

✅ Verify builds complete successfully

### 5. Run on Device/Emulator
```bash
flutter devices
flutter run -d <device-id>
```
✅ Verify app runs without crashes

## Known Compatible Dependencies

All current dependencies in `pubspec.yaml` are compatible with Flutter 3.35.7:

- ✅ firebase_core: ^4.0.0
- ✅ firebase_auth: ^6.0.1
- ✅ cloud_firestore: ^6.0.0
- ✅ firebase_storage: ^13.0.0
- ✅ provider: ^6.1.5+1
- ✅ fl_chart: 1.0.0
- ✅ image_picker: ^1.2.0
- ✅ flutter_lints: ^5.0.0

## Troubleshooting

### Issue: "The current Dart SDK version is X but Y requires X"

**Solution:**
```bash
flutter clean
flutter pub get
```

### Issue: Build fails with "Gradle task assembleDebug failed"

**Solution:**
1. Update Android Gradle plugin in `android/build.gradle`
2. Run `flutter clean`
3. Rebuild

### Issue: CocoaPods issues on iOS

**Solution:**
```bash
cd ios
pod repo update
pod install
cd ..
flutter clean
flutter build ios
```

### Issue: Tests fail after upgrade

**Solution:**
1. Check for deprecated API usage
2. Update test mocks if needed
3. Verify test dependencies are up to date

## CI/CD Migration

### For CodeMagic Users

The `codemagic.yaml` file is now in the repository. CodeMagic will automatically detect and use this configuration.

**Steps:**
1. Push changes to your branch
2. CodeMagic will use Flutter 3.35.7 as specified in the yaml file
3. Configure environment variables in CodeMagic UI as noted above

### For Other CI/CD Systems

If you're using GitHub Actions, GitLab CI, or other CI systems:

1. Update your workflow files to use Flutter 3.35.7
2. Example for GitHub Actions:
   ```yaml
   - uses: subosito/flutter-action@v2
     with:
       flutter-version: '3.35.7'
       channel: 'stable'
   ```

## Benefits of This Update

1. **Latest Features**: Access to new Flutter 3.35.7 features and improvements
2. **Bug Fixes**: Latest bug fixes and stability improvements
3. **Security Updates**: Latest security patches
4. **CI/CD Consistency**: All builds use the same Flutter version
5. **Better Performance**: Performance improvements in Flutter 3.35.x
6. **Up-to-date Dependencies**: Compatible with latest package versions

## Rollback Plan

If you need to rollback to the previous version:

```bash
# Checkout previous commit
git checkout <previous-commit-hash>

# Or revert the Flutter version
flutter channel stable
flutter downgrade

# Then
flutter clean
flutter pub get
```

## Additional Resources

- [Flutter 3.35.7 Release Notes](https://docs.flutter.dev/release/release-notes)
- [Flutter Upgrade Guide](https://docs.flutter.dev/release/upgrade)
- [CodeMagic Documentation](https://docs.codemagic.io/flutter-configuration/flutter-projects/)

## Support

If you encounter issues during the upgrade:

1. Check this guide's troubleshooting section
2. Contact **joeltonmatos@gmail.com** for assistance
3. Open an issue in the repository with detailed error logs
