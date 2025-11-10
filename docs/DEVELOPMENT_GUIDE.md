# Development Guide - NCC Finance Mobile

## Table of Contents
1. [Getting Started](#getting-started)
2. [Development Environment](#development-environment)
3. [Project Setup](#project-setup)
4. [Coding Standards](#coding-standards)
5. [Git Workflow](#git-workflow)
6. [Testing Guidelines](#testing-guidelines)
7. [Debugging](#debugging)
8. [Common Tasks](#common-tasks)
9. [Troubleshooting](#troubleshooting)
10. [Contributing](#contributing)

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.8.1 or higher
  ```bash
  flutter --version
  ```
- **Dart SDK**: Comes with Flutter
- **IDE**: VS Code or Android Studio
- **Git**: Version control
- **Firebase CLI** (optional): For Firebase management

### Recommended IDE Extensions

#### VS Code
- Flutter
- Dart
- Firebase Explorer
- GitLens
- Error Lens
- Bracket Pair Colorizer

#### Android Studio
- Flutter plugin
- Dart plugin
- Firebase plugins

## Development Environment

### Flutter Installation

#### macOS
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### Windows
1. Download Flutter SDK from https://flutter.dev
2. Extract to `C:\src\flutter`
3. Add to PATH: `C:\src\flutter\bin`
4. Run `flutter doctor`

#### Linux
```bash
# Download Flutter
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz

# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify
flutter doctor
```

### Platform Setup

#### Android Development
```bash
# Install Android Studio
# Configure Android SDK
flutter doctor --android-licenses

# Create emulator
flutter emulators --create
```

#### iOS Development (macOS only)
```bash
# Install Xcode from App Store
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Install CocoaPods
sudo gem install cocoapods
```

### Firebase Setup

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. **Configure Firebase** (if needed):
   ```bash
   flutterfire configure
   ```

## Project Setup

### Clone Repository

```bash
git clone https://github.com/NewCode-Crafters/ncc-finance-mobile.git
cd ncc-finance-mobile
```

### Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# For iOS (macOS only)
cd ios && pod install && cd ..
```

### Configure Firebase

The repository includes Firebase configuration files for evaluation purposes:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

**Note**: These are demo credentials and will be rotated after evaluation.

### Run the App

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode
flutter run --debug

# Run in profile mode (for performance testing)
flutter run --profile

# Run in release mode
flutter run --release
```

## Coding Standards

### Dart Code Style

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

#### Naming Conventions

```dart
// Classes: UpperCamelCase
class FinancialTransaction { }

// Files: snake_case
// financial_transaction.dart

// Variables & functions: lowerCamelCase
String userName;
void calculateBalance() { }

// Constants: lowerCamelCase
const maxRetries = 3;

// Private members: prefix with underscore
String _privateField;
void _privateMethod() { }
```

#### Code Organization

```dart
// 1. Imports (organized)
import 'dart:async';                          // Dart SDK
import 'package:flutter/material.dart';       // Flutter framework
import 'package:provider/provider.dart';      // External packages
import 'package:bytebank/core/utils.dart';    // Internal absolute imports
import '../models/transaction.dart';          // Internal relative imports

// 2. Class declaration
class TransactionScreen extends StatefulWidget {
  // 3. Static members
  static const String routeName = '/transactions';
  
  // 4. Final fields
  final String userId;
  
  // 5. Constructor
  const TransactionScreen({Key? key, required this.userId}) : super(key: key);
  
  // 6. Overridden methods
  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

// 7. State class (if applicable)
class _TransactionScreenState extends State<TransactionScreen> {
  // 8. Controllers & variables
  final _scrollController = ScrollController();
  bool _isLoading = false;
  
  // 9. Lifecycle methods
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // 10. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
  
  // 11. Private helper methods
  void _loadMore() { }
}
```

### Widget Best Practices

#### Use Const Constructors

```dart
// ✅ Good
const Text('Hello');
const SizedBox(height: 16);
const Padding(padding: EdgeInsets.all(8), child: Text('Test'));

// ❌ Avoid
Text('Hello');
SizedBox(height: 16);
```

#### Extract Widgets

```dart
// ✅ Good: Extract complex widgets
class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  
  const TransactionList({Key? key, required this.transactions}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) => TransactionCard(transaction: transactions[index]),
    );
  }
}

// ❌ Avoid: Large inline widgets
Widget build(BuildContext context) {
  return Column(
    children: [
      // 100 lines of widget code...
    ],
  );
}
```

#### Proper State Management

```dart
// ✅ Good: Use Consumer for localized rebuilds
Consumer<TransactionNotifier>(
  builder: (context, notifier, child) {
    return TransactionList(transactions: notifier.transactions);
  },
)

// ✅ Good: Use Selector for specific fields
Selector<TransactionNotifier, int>(
  selector: (context, notifier) => notifier.transactions.length,
  builder: (context, count, child) {
    return Text('Total: $count');
  },
)

// ❌ Avoid: Unnecessary rebuilds
context.watch<TransactionNotifier>(); // Rebuilds for any change
```

### Error Handling

```dart
// ✅ Good: Specific error handling
try {
  await service.createTransaction(transaction);
} on NetworkException catch (e) {
  _showError('Erro de rede: ${e.message}');
} on ValidationException catch (e) {
  _showError('Dados inválidos: ${e.message}');
} catch (e) {
  _showError('Erro inesperado. Tente novamente.');
  logger.error('Transaction creation failed', error: e);
}

// ❌ Avoid: Generic error handling
try {
  await service.createTransaction(transaction);
} catch (e) {
  print(e); // Don't print in production
  // No user feedback
}
```

### Documentation

```dart
/// Creates a new financial transaction.
///
/// The [transaction] parameter must have valid amount and category.
/// Throws [ValidationException] if data is invalid.
/// Throws [NetworkException] if connection fails.
///
/// Example:
/// ```dart
/// await service.createTransaction(
///   FinancialTransaction(
///     amount: 100.50,
///     category: 'Food',
///     date: DateTime.now(),
///   ),
/// );
/// ```
Future<void> createTransaction(FinancialTransaction transaction) async {
  // Implementation
}
```

## Git Workflow

### Branch Naming

```bash
# Feature branches
feature/add-transaction-filter
feature/implement-dark-mode

# Bug fixes
fix/transaction-date-validation
fix/profile-image-upload

# Enhancement/improvement
enhancement/optimize-list-performance
enhancement/improve-error-messages

# Documentation
docs/update-readme
docs/add-architecture-guide
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Format: <type>(<scope>): <subject>

# Types: feat, fix, docs, style, refactor, test, chore

# Examples:
git commit -m "feat(transactions): add date filter"
git commit -m "fix(auth): resolve login error handling"
git commit -m "docs(readme): update setup instructions"
git commit -m "refactor(dashboard): extract chart widget"
git commit -m "test(balance): add balance calculation tests"
git commit -m "chore(deps): update firebase packages"
```

### Pull Request Process

1. **Create Feature Branch**:
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make Changes & Commit**:
   ```bash
   git add .
   git commit -m "feat: add feature description"
   ```

3. **Push to Remote**:
   ```bash
   git push origin feature/my-feature
   ```

4. **Create Pull Request**:
   - Go to GitHub repository
   - Click "New Pull Request"
   - Fill in description template
   - Request review

5. **Address Review Comments**:
   ```bash
   git add .
   git commit -m "fix: address review comments"
   git push origin feature/my-feature
   ```

6. **Merge**:
   - Once approved, merge via GitHub
   - Delete feature branch

### Code Review Checklist

- [ ] Code follows style guide
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No console.log or debug code
- [ ] Error handling implemented
- [ ] Performance considerations addressed
- [ ] Security implications reviewed
- [ ] Backward compatibility maintained

## Testing Guidelines

### Unit Tests

```dart
// test/features/transactions/services/transaction_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('FinancialTransactionService', () {
    late FinancialTransactionService service;
    late FakeFirebaseFirestore firestore;
    
    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = FinancialTransactionService(firestore: firestore);
    });
    
    test('createTransaction should add document to Firestore', () async {
      // Arrange
      final transaction = FinancialTransaction(
        id: '',
        amount: 100.0,
        category: 'Food',
        date: DateTime.now(),
        balanceId: 'balance123',
      );
      
      // Act
      await service.createTransaction(transaction);
      
      // Assert
      final docs = await firestore
          .collection('users/user123/transactions')
          .get();
      expect(docs.docs.length, 1);
      expect(docs.docs.first.data()['amount'], 100.0);
    });
  });
}
```

### Widget Tests

```dart
// test/features/transactions/screens/transaction_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('TransactionScreen displays transactions', (tester) async {
    // Arrange
    final mockNotifier = MockTransactionNotifier();
    when(mockNotifier.transactions).thenReturn([
      FinancialTransaction(
        id: '1',
        amount: 100.0,
        category: 'Food',
        date: DateTime.now(),
        balanceId: 'balance123',
      ),
    ]);
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TransactionNotifier>.value(
          value: mockNotifier,
          child: TransactionScreen(),
        ),
      ),
    );
    
    // Assert
    expect(find.text('R\$ 100,00'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });
}
```

### Integration Tests

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bytebank/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete transaction flow', (tester) async {
    // Start app
    app.main();
    await tester.pumpAndSettle();
    
    // Login
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    
    // Navigate to transactions
    await tester.tap(find.text('Transações'));
    await tester.pumpAndSettle();
    
    // Create transaction
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    // ... more steps
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/transactions/services/transaction_service_test.dart

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Run integration tests
flutter test integration_test/app_test.dart
```

## Debugging

### Flutter DevTools

```bash
# Start DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Run app in debug mode
flutter run --debug
```

### Debugging Techniques

#### Print Debugging
```dart
// ✅ Use debugPrint (respects output throttling)
debugPrint('Transaction created: ${transaction.id}');

// ❌ Avoid print in production
print('Debug info'); // Remove before committing
```

#### Breakpoints
```dart
void createTransaction(Transaction transaction) {
  // Set breakpoint here in IDE
  final validated = _validate(transaction);
  // Step through code
}
```

#### Flutter Inspector
- View widget tree
- Inspect widget properties
- Debug layout issues
- Check widget sizes and constraints

#### Performance Profiling
```bash
# Profile mode
flutter run --profile

# Use DevTools Timeline tab
# Monitor frame rendering
# Identify performance bottlenecks
```

### Common Debugging Scenarios

#### Network Issues
```dart
// Log network requests
FirebaseFirestore.instance.settings = Settings(
  host: 'localhost:8080',
  sslEnabled: false,
  persistenceEnabled: false,
);
```

#### State Issues
```dart
// Log state changes
class MyNotifier extends ChangeNotifier {
  void updateState(NewState state) {
    debugPrint('State changing from $_state to $state');
    _state = state;
    notifyListeners();
  }
}
```

#### Build Issues
```bash
# Clean build
flutter clean
flutter pub get
flutter run

# Clear Gradle cache (Android)
cd android && ./gradlew clean && cd ..

# Update pods (iOS)
cd ios && pod repo update && pod install && cd ..
```

## Common Tasks

### Adding a New Feature

1. **Create Feature Branch**:
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Create Feature Structure**:
   ```
   lib/features/my_feature/
   ├── models/
   ├── notifiers/
   ├── screens/
   ├── services/
   └── widgets/
   ```

3. **Implement Service**:
   ```dart
   // lib/features/my_feature/services/my_service.dart
   class MyService {
     Future<void> doSomething() async {
       // Implementation
     }
   }
   ```

4. **Create Notifier**:
   ```dart
   // lib/features/my_feature/notifiers/my_notifier.dart
   class MyNotifier extends ChangeNotifier {
     final MyService _service;
     
     MyNotifier(this._service);
     
     Future<void> performAction() async {
       // Business logic
       notifyListeners();
     }
   }
   ```

5. **Build UI**:
   ```dart
   // lib/features/my_feature/screens/my_screen.dart
   class MyScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Consumer<MyNotifier>(
         builder: (context, notifier, child) {
           return Scaffold(...);
         },
       );
     }
   }
   ```

6. **Register Providers** (main.dart):
   ```dart
   Provider<MyService>(create: (_) => MyService()),
   ChangeNotifierProvider<MyNotifier>(
     create: (context) => MyNotifier(context.read<MyService>()),
   ),
   ```

7. **Add Tests**:
   ```dart
   // test/features/my_feature/services/my_service_test.dart
   void main() {
     test('should do something', () async {
       // Test implementation
     });
   }
   ```

### Updating Dependencies

```bash
# Check for outdated packages
flutter pub outdated

# Update all dependencies
flutter pub upgrade

# Update specific package
flutter pub upgrade package_name

# Update to latest major version
flutter pub upgrade --major-versions
```

### Generating Code

```bash
# Generate JSON serialization (if using json_serializable)
flutter pub run build_runner build

# Watch for changes
flutter pub run build_runner watch

# Delete conflicting outputs
flutter pub run build_runner build --delete-conflicting-outputs
```

### Building Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended)
flutter build appbundle --release

# iOS
flutter build ios --release

# With obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## Troubleshooting

### Common Issues

#### "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### "Pod install failed"
```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
flutter run
```

#### "Firebase not initialized"
- Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) exists
- Ensure Firebase is initialized in `main()`:
  ```dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ```

#### "Hot reload not working"
```bash
# Stop app
# Run clean
flutter clean
flutter pub get
# Restart app
flutter run
```

#### "Out of memory" during build
```bash
# Increase Gradle memory (android/gradle.properties)
org.gradle.jvmargs=-Xmx4096m
```

## Contributing

### Getting Help

- **Documentation**: Check `docs/` folder for guides
- **Issues**: Search existing GitHub issues
- **Team**: Contact team members via Discord/Slack
- **Firebase**: Check Firebase console for backend issues

### Reporting Bugs

When reporting bugs, include:
1. Description of the issue
2. Steps to reproduce
3. Expected vs actual behavior
4. Screenshots/logs
5. Device/OS information
6. Flutter version (`flutter --version`)

### Feature Requests

When requesting features:
1. Describe the use case
2. Explain the benefit
3. Provide examples or mockups
4. Consider implementation complexity

### Code of Conduct

- Be respectful and professional
- Focus on constructive feedback
- Help others learn and grow
- Follow project guidelines
- Maintain code quality standards

## Conclusion

This guide provides the foundation for developing NCC Finance Mobile. Always:
- Follow coding standards
- Write tests for new features
- Document your code
- Seek feedback early
- Keep learning and improving

For more specific topics, refer to other documentation:
- Architecture: `docs/ARCHITECTURE.md`
- Security: `docs/SECURITY.md`
- Performance: `docs/PERFORMANCE.md`
- Validation: `docs/VALIDATION_GUIDE.md`
