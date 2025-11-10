#!/bin/bash

# Flutter SDK 3.35.7 Upgrade Verification Script
# This script verifies that the Flutter upgrade was successful

set -e  # Exit on error

EXPECTED_FLUTTER_VERSION="3.35.7"
EXPECTED_REVISION="adc901062556672b4138e18a4dc62a4be8f4b3c2"

echo "========================================"
echo "Flutter SDK Upgrade Verification Script"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error message
error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print info message
info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

echo "Step 1: Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    error "Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://docs.flutter.dev/get-started/install"
    exit 1
fi
success "Flutter is installed"
echo ""

echo "Step 2: Checking Flutter version..."
FLUTTER_VERSION=$(flutter --version | grep "Flutter" | awk '{print $2}')
info "Current Flutter version: $FLUTTER_VERSION"

if [[ "$FLUTTER_VERSION" == "$EXPECTED_FLUTTER_VERSION" ]]; then
    success "Flutter version matches expected version ($EXPECTED_FLUTTER_VERSION)"
elif [[ "$FLUTTER_VERSION" > "$EXPECTED_FLUTTER_VERSION" ]]; then
    info "Flutter version ($FLUTTER_VERSION) is newer than expected ($EXPECTED_FLUTTER_VERSION)"
    success "This should be compatible"
else
    error "Flutter version ($FLUTTER_VERSION) is older than expected ($EXPECTED_FLUTTER_VERSION)"
    echo "Please run: flutter upgrade"
    exit 1
fi
echo ""

echo "Step 3: Checking Flutter channel..."
FLUTTER_CHANNEL=$(flutter --version | grep "channel" | awk '{print $5}')
info "Current channel: $FLUTTER_CHANNEL"
if [[ "$FLUTTER_CHANNEL" == "stable" ]]; then
    success "Using stable channel"
else
    error "Not using stable channel. Run: flutter channel stable && flutter upgrade"
    exit 1
fi
echo ""

echo "Step 4: Cleaning previous builds..."
flutter clean > /dev/null 2>&1
success "Clean completed"
echo ""

echo "Step 5: Getting dependencies..."
if flutter pub get; then
    success "Dependencies resolved successfully"
else
    error "Failed to get dependencies"
    exit 1
fi
echo ""

echo "Step 6: Running Flutter analyze..."
if flutter analyze --no-pub; then
    success "Flutter analyze passed with no issues"
else
    error "Flutter analyze found issues"
    echo "Please review and fix the issues above"
    exit 1
fi
echo ""

echo "Step 7: Running unit tests..."
if flutter test; then
    success "All unit tests passed"
else
    error "Some unit tests failed"
    echo "Please review and fix the failing tests"
    exit 1
fi
echo ""

echo "Step 8: Verifying build configuration..."
if [ -f "codemagic.yaml" ]; then
    success "codemagic.yaml exists"
    
    # Check if Flutter version is specified in codemagic.yaml
    if grep -q "flutter: 3.35.7" codemagic.yaml; then
        success "codemagic.yaml specifies Flutter 3.35.7"
    else
        error "codemagic.yaml does not specify Flutter 3.35.7"
        exit 1
    fi
else
    error "codemagic.yaml not found"
    exit 1
fi
echo ""

echo "Step 9: Checking pubspec.yaml..."
if grep -q "sdk: \^3.35.7" pubspec.yaml; then
    success "pubspec.yaml SDK constraint is correct (^3.35.7)"
else
    error "pubspec.yaml SDK constraint is not set to ^3.35.7"
    exit 1
fi
echo ""

echo "Step 10: Checking .metadata file..."
if grep -q "$EXPECTED_REVISION" .metadata; then
    success ".metadata file contains correct revision"
else
    error ".metadata file does not contain expected revision"
    exit 1
fi
echo ""

echo "Step 11: Testing debug build (Android)..."
info "This may take a few minutes..."
if flutter build apk --debug > /tmp/flutter_build.log 2>&1; then
    success "Android debug build successful"
else
    error "Android debug build failed"
    echo "Check /tmp/flutter_build.log for details"
    exit 1
fi
echo ""

echo "========================================"
echo "All verification steps passed!"
echo "========================================"
echo ""
echo "Your Flutter SDK upgrade is complete and verified."
echo ""
echo "Next steps:"
echo "1. Push your changes if you haven't already"
echo "2. Create a PR to merge the changes"
echo "3. Monitor CodeMagic CI/CD builds"
echo "4. Test the app on physical devices/emulators"
echo ""
echo "For more information, see FLUTTER_UPGRADE_GUIDE.md"
