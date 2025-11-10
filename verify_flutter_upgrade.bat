@echo off
REM Flutter SDK 3.35.7 Upgrade Verification Script for Windows
REM This script verifies that the Flutter upgrade was successful

setlocal enabledelayedexpansion

set EXPECTED_FLUTTER_VERSION=3.35.7
set EXPECTED_REVISION=adc901062556672b4138e18a4dc62a4be8f4b3c2

echo ========================================
echo Flutter SDK Upgrade Verification Script
echo ========================================
echo.

echo Step 1: Checking Flutter installation...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo Please install Flutter from https://docs.flutter.dev/get-started/install
    exit /b 1
)
echo [OK] Flutter is installed
echo.

echo Step 2: Checking Flutter version...
for /f "tokens=2" %%i in ('flutter --version ^| findstr "Flutter"') do set FLUTTER_VERSION=%%i
echo [INFO] Current Flutter version: %FLUTTER_VERSION%

if "%FLUTTER_VERSION%"=="%EXPECTED_FLUTTER_VERSION%" (
    echo [OK] Flutter version matches expected version
) else (
    echo [WARNING] Flutter version does not exactly match
    echo Expected: %EXPECTED_FLUTTER_VERSION%
    echo Current: %FLUTTER_VERSION%
    echo.
    echo Please run: flutter upgrade
)
echo.

echo Step 3: Checking Flutter channel...
for /f "tokens=5" %%i in ('flutter --version ^| findstr "channel"') do set FLUTTER_CHANNEL=%%i
echo [INFO] Current channel: %FLUTTER_CHANNEL%
if "%FLUTTER_CHANNEL%"=="stable" (
    echo [OK] Using stable channel
) else (
    echo [ERROR] Not using stable channel
    echo Please run: flutter channel stable ^&^& flutter upgrade
    exit /b 1
)
echo.

echo Step 4: Cleaning previous builds...
flutter clean >nul 2>&1
echo [OK] Clean completed
echo.

echo Step 5: Getting dependencies...
flutter pub get >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies
    exit /b 1
)
echo [OK] Dependencies resolved successfully
echo.

echo Step 6: Running Flutter analyze...
flutter analyze --no-pub
if %errorlevel% neq 0 (
    echo [ERROR] Flutter analyze found issues
    echo Please review and fix the issues above
    exit /b 1
)
echo [OK] Flutter analyze passed with no issues
echo.

echo Step 7: Running unit tests...
flutter test
if %errorlevel% neq 0 (
    echo [ERROR] Some unit tests failed
    echo Please review and fix the failing tests
    exit /b 1
)
echo [OK] All unit tests passed
echo.

echo Step 8: Verifying build configuration...
if exist codemagic.yaml (
    echo [OK] codemagic.yaml exists
    
    findstr /C:"flutter: 3.35.7" codemagic.yaml >nul
    if %errorlevel% equ 0 (
        echo [OK] codemagic.yaml specifies Flutter 3.35.7
    ) else (
        echo [ERROR] codemagic.yaml does not specify Flutter 3.35.7
        exit /b 1
    )
) else (
    echo [ERROR] codemagic.yaml not found
    exit /b 1
)
echo.

echo Step 9: Checking pubspec.yaml...
findstr /C:"sdk: ^3.35.7" pubspec.yaml >nul
if %errorlevel% equ 0 (
    echo [OK] pubspec.yaml SDK constraint is correct
) else (
    echo [ERROR] pubspec.yaml SDK constraint is not set to ^3.35.7
    exit /b 1
)
echo.

echo Step 10: Checking .metadata file...
findstr /C:"%EXPECTED_REVISION%" .metadata >nul
if %errorlevel% equ 0 (
    echo [OK] .metadata file contains correct revision
) else (
    echo [ERROR] .metadata file does not contain expected revision
    exit /b 1
)
echo.

echo Step 11: Testing debug build (Android)...
echo [INFO] This may take a few minutes...
flutter build apk --debug > %TEMP%\flutter_build.log 2>&1
if %errorlevel% equ 0 (
    echo [OK] Android debug build successful
) else (
    echo [ERROR] Android debug build failed
    echo Check %TEMP%\flutter_build.log for details
    exit /b 1
)
echo.

echo ========================================
echo All verification steps passed!
echo ========================================
echo.
echo Your Flutter SDK upgrade is complete and verified.
echo.
echo Next steps:
echo 1. Push your changes if you haven't already
echo 2. Create a PR to merge the changes
echo 3. Monitor CodeMagic CI/CD builds
echo 4. Test the app on physical devices/emulators
echo.
echo For more information, see FLUTTER_UPGRADE_GUIDE.md

endlocal
