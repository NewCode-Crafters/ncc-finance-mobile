# Architecture Guide - NCC Finance Mobile

## Table of Contents
1. [Overview](#overview)
2. [Architecture Pattern](#architecture-pattern)
3. [State Management](#state-management)
4. [Project Structure](#project-structure)
5. [Data Flow](#data-flow)
6. [Design Patterns](#design-patterns)
7. [Future Enhancements](#future-enhancements)

## Overview

NCC Finance Mobile (Bytebank) is a Flutter application built with a feature-based architecture. The application follows a clean separation of concerns with a clear distinction between presentation, business logic, and data layers.

### Technology Stack
- **Framework**: Flutter 3.8.1+
- **State Management**: Provider (with ChangeNotifier)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Localization**: intl package (pt_BR support)
- **Charts**: fl_chart
- **Testing**: mockito, fake_cloud_firestore, firebase_auth_mocks

## Architecture Pattern

The application uses a **Feature-Based Architecture** with a **Service-Notifier-Screen** pattern:

```
lib/
├── core/                    # Shared resources
│   ├── constants/          # App-wide constants
│   ├── models/             # Shared models
│   ├── notifiers/          # Shared state notifiers
│   ├── services/           # Shared services
│   ├── utils/              # Helper functions
│   ├── validators.dart     # Input validation
│   └── widgets/            # Reusable widgets
├── features/                # Feature modules
│   ├── authentication/     
│   │   ├── notifiers/      # Auth state management
│   │   ├── screens/        # Auth UI screens
│   │   └── services/       # Auth business logic
│   ├── dashboard/
│   ├── transactions/
│   ├── investments/
│   ├── profile/
│   └── splash/
├── theme/                   # Theme configuration
├── firebase_options.dart    # Firebase config
└── main.dart               # App entry point
```

### Layer Responsibilities

#### 1. Presentation Layer (Screens & Widgets)
- **Location**: `features/*/screens/` and `features/*/widgets/`
- **Responsibility**: UI rendering and user interaction
- **Dependencies**: Notifiers (via Provider), core widgets
- **Examples**: 
  - `LoginScreen` - displays login form
  - `DashboardScreen` - shows user balance and transactions
  - `CustomTextField` - reusable input component

#### 2. Business Logic Layer (Notifiers)
- **Location**: `features/*/notifiers/`
- **Responsibility**: State management, input validation, error handling
- **Pattern**: ChangeNotifier (from Provider package)
- **Examples**:
  - `AuthNotifier` - manages authentication state
  - `TransactionNotifier` - manages transaction list state
  - `BalanceNotifier` - manages balance calculations

#### 3. Data Layer (Services)
- **Location**: `features/*/services/` and `core/services/`
- **Responsibility**: Data access, API calls, Firebase operations
- **Pattern**: Service classes with interface contracts
- **Examples**:
  - `FirebaseAuthService` - implements `AuthService` interface
  - `FinancialTransactionService` - Firestore CRUD operations
  - `ProfileService` - user profile data management

## State Management

### Provider Pattern

The app uses **Provider** as its state management solution with the following architecture:

```dart
// Service Registration (main.dart)
MultiProvider(
  providers: [
    // Services (Stateless)
    Provider<AuthService>(create: (_) => FirebaseAuthService()),
    Provider<FinancialTransactionService>(create: (_) => FinancialTransactionService()),
    
    // Notifiers (Stateful)
    ChangeNotifierProvider<AuthNotifier>(
      create: (context) => AuthNotifier(context.read<AuthService>()),
    ),
    ChangeNotifierProvider<TransactionNotifier>(
      create: (context) => TransactionNotifier(
        context.read<FinancialTransactionService>(),
        context.read<MetadataService>(),
      ),
    ),
  ],
  child: MaterialApp(...),
)
```

### State Management Flow

```
User Action (UI)
    ↓
Notifier Method Called
    ↓
Business Logic Validation
    ↓
Service Method Called
    ↓
Firebase Operation
    ↓
Update State
    ↓
notifyListeners()
    ↓
UI Rebuilds
```

### Key State Management Principles

1. **Separation of Concerns**: Services handle data access, Notifiers handle state
2. **Immutable State**: State objects use `copyWith()` for immutability
3. **Single Responsibility**: Each notifier manages one feature's state
4. **Reactive UI**: Widgets rebuild automatically via `Consumer` or `context.watch()`

### Example: Auth State Management

```dart
// State Model
class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final String? successMessage;
  
  const AuthState({...});
  
  AuthState copyWith({...}) { ... }
  
  @override
  List<Object?> get props => [isLoading, errorMessage, isAuthenticated, successMessage];
}

// Notifier
class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  AuthState _state = const AuthState();
  AuthState get state => _state;
  
  Future<bool> login(String email, String password) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    
    try {
      await _authService.login(email, password);
      _state = _state.copyWith(isLoading: false, isAuthenticated: true);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }
}

// UI Consumption
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        if (authNotifier.state.isLoading) {
          return CircularProgressIndicator();
        }
        // ... render UI
      },
    );
  }
}
```

## Project Structure

### Feature Module Structure

Each feature follows a consistent structure:

```
feature_name/
├── models/              # Data models specific to this feature
├── notifiers/           # State management for this feature
├── screens/             # UI screens for this feature
├── services/            # Business logic and data access
├── widgets/             # Feature-specific reusable widgets
└── utils/              # Feature-specific utilities
```

### Example: Transactions Feature

```
transactions/
├── models/
│   ├── financial_transaction.dart
│   └── attachment.dart
├── notifiers/
│   ├── transaction_notifier.dart
│   └── transaction_attachments_notifier.dart
├── screens/
│   ├── transactions_screen.dart
│   ├── create_transaction_screen.dart
│   ├── edit_transaction_screen.dart
│   ├── view_transaction_screen.dart
│   └── expense_control_screen.dart
├── services/
│   ├── financial_transaction_service.dart
│   └── transaction_attachment_service.dart
└── widgets/
    ├── transaction_card.dart
    └── edit_attachments_section.dart
```

## Data Flow

### Complete Data Flow Example: Creating a Transaction

```
1. User fills form in CreateTransactionScreen
   ↓
2. User taps "Save" button
   ↓
3. Screen calls: context.read<TransactionNotifier>().createTransaction(...)
   ↓
4. TransactionNotifier validates input
   ↓
5. TransactionNotifier calls: _transactionService.createTransaction(...)
   ↓
6. FinancialTransactionService creates Firestore document
   ↓
7. FinancialTransactionService updates balance via BalanceService
   ↓
8. Success: TransactionNotifier updates state
   ↓
9. TransactionNotifier calls: notifyListeners()
   ↓
10. UI rebuilds showing success state
    ↓
11. User navigated back to transaction list
    ↓
12. TransactionScreen loads updated data
```

### Firebase Integration

#### Authentication Flow
```
User Login
    ↓
FirebaseAuthService.login()
    ↓
FirebaseAuth.signInWithEmailAndPassword()
    ↓
User object stored in Firebase Auth
    ↓
AuthStateChanges stream emits event
    ↓
AuthGate widget redirects to Dashboard
```

#### Data Persistence Flow
```
Create Transaction
    ↓
FinancialTransactionService.createTransaction()
    ↓
Firestore: /users/{userId}/transactions/{transactionId}
    ↓
Document created with: { amount, category, date, description, balanceId }
    ↓
Update Balance
    ↓
BalanceService.updateBalance()
    ↓
Firestore: /users/{userId}/balances/{balanceId}
    ↓
Atomic update: amount += transaction.amount
```

## Design Patterns

### 1. Repository Pattern (via Services)
Services act as repositories abstracting data access:

```dart
abstract class AuthService {
  Future<void> login(String email, String password);
  Future<void> signUp({required String name, required String email, required String password});
  Future<void> logout();
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  
  // Implementation details
}
```

**Benefits:**
- Testable (can mock AuthService)
- Flexible (can swap Firebase for another backend)
- Clear contracts (interface defines API)

### 2. Factory Pattern (Model Constructors)
Models use factory constructors for data transformation:

```dart
class FinancialTransaction {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  
  factory FinancialTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialTransaction(
      id: doc.id,
      amount: (data['amount'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}
```

### 3. Observer Pattern (Provider/ChangeNotifier)
ChangeNotifier implements the Observer pattern:
- **Subject**: Notifier (maintains state)
- **Observers**: Widgets (Consumer, Selector, context.watch)
- **Notification**: notifyListeners()

### 4. Dependency Injection (Provider)
Dependencies are injected via Provider:

```dart
// Registration
Provider<AuthService>(create: (_) => FirebaseAuthService())

// Injection
class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  AuthNotifier(this._authService); // Injected via constructor
}

// Consumption
ChangeNotifierProvider<AuthNotifier>(
  create: (context) => AuthNotifier(context.read<AuthService>()),
)
```

### 5. Strategy Pattern (Validation)
Different validation strategies can be applied:

```dart
class Validators {
  static final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }
  
  // Additional validation strategies
}
```

## Reactive Programming

### Current Reactive Patterns

1. **Stream-based Auth**: Firebase Auth provides `authStateChanges()` stream
2. **Change Notification**: Provider's ChangeNotifier pattern
3. **Reactive UI**: Widgets automatically rebuild on state changes

### Example: Reactive Authentication

```dart
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }
        if (snapshot.hasData) {
          return DashboardScreen();
        }
        return LoginScreen();
      },
    );
  }
}
```

## Performance Optimizations

### 1. Lazy Loading (Implemented)
- Transaction lists load incrementally
- Images loaded on-demand
- Charts render only when visible

### 2. Widget Optimization
- `const` constructors used where possible
- `Selector` instead of `Consumer` for targeted rebuilds
- Key usage for efficient list rendering

### 3. Data Caching
- Firebase automatically caches Firestore data
- Profile images cached by Firebase Storage
- Balance calculations cached in memory

### 4. Build Optimization
```dart
// Bad: Rebuilds entire widget tree
Consumer<TransactionNotifier>(
  builder: (context, notifier, child) {
    return ExpensiveWidget(data: notifier.transactions);
  },
)

// Good: Only rebuilds when specific data changes
Selector<TransactionNotifier, List<Transaction>>(
  selector: (context, notifier) => notifier.transactions,
  builder: (context, transactions, child) {
    return ExpensiveWidget(data: transactions);
  },
)
```

## Testing Strategy

### Unit Tests
- Services tested with mock Firebase
- Notifiers tested with mock services
- Validators tested with various inputs

### Widget Tests
- Screens tested with mock notifiers
- User interactions verified
- Error states validated

### Test Structure
```
test/
├── core/
│   └── widgets/
│       └── main_app_bar_test.dart
├── features/
│   ├── authentication/
│   │   ├── notifiers/
│   │   │   └── auth_notifier_test.dart
│   │   ├── screens/
│   │   │   └── login_screen_test.dart
│   │   └── services/
│   │       └── firebase_auth_service_test.dart
│   └── transactions/
│       └── services/
│           └── financial_transaction_service_test.dart
```

## Future Enhancements

### 1. Hexagonal Architecture Migration
- Separate domain, application, and infrastructure layers
- Use ports and adapters pattern
- Enable better testability and maintainability

### 2. Enhanced State Management
- Consider BLoC for complex state scenarios
- Implement Riverpod for better type safety
- Add state persistence with Hydrated BLoC

### 3. Offline Support
- Implement local database (Drift/Hive)
- Sync strategy for offline operations
- Conflict resolution for concurrent updates

### 4. Microservices Integration
- Add REST API layer
- Implement GraphQL for efficient queries
- Circuit breaker pattern for resilience

### 5. Advanced Features
- Real-time collaboration
- Push notifications
- Background sync
- Biometric authentication

## Best Practices

### 1. Code Organization
- ✅ Feature-based structure
- ✅ Clear separation of concerns
- ✅ Consistent naming conventions
- ✅ Reusable components in `core/`

### 2. State Management
- ✅ Immutable state objects
- ✅ Single source of truth
- ✅ Predictable state updates
- ✅ Error handling in notifiers

### 3. Error Handling
- ✅ Custom exception classes
- ✅ User-friendly error messages
- ✅ Graceful degradation
- ✅ Logging for debugging

### 4. Performance
- ✅ Lazy widget initialization
- ✅ Efficient list rendering
- ✅ Optimized rebuilds
- ✅ Asset optimization

### 5. Testing
- ✅ Unit tests for business logic
- ✅ Widget tests for UI
- ✅ Mock dependencies
- ✅ Test coverage for critical paths

## Conclusion

The NCC Finance Mobile architecture provides a solid foundation for a scalable, maintainable Flutter application. The feature-based structure combined with Provider state management offers:

- **Clarity**: Clear separation of UI, logic, and data
- **Testability**: All layers can be tested independently
- **Scalability**: Easy to add new features
- **Maintainability**: Consistent patterns throughout
- **Performance**: Optimized rendering and data access

As the application grows, consider migrating to hexagonal architecture and exploring more advanced state management solutions for complex scenarios.
