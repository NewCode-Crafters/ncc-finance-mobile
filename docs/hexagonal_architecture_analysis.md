# Hexagonal Architecture Migration Analysis

## Table of Contents
1. [Introduction](#introduction)
2. [Current Architecture Analysis](#current-architecture-analysis)
3. [Hexagonal Architecture Overview](#hexagonal-architecture-overview)
4. [Proposed Migration Strategy](#proposed-migration-strategy)
5. [Folder Structure](#folder-structure)
6. [File Naming Conventions](#file-naming-conventions)
7. [Pattern Implementation Examples](#pattern-implementation-examples)
8. [Best Practices](#best-practices)
9. [Migration Roadmap](#migration-roadmap)

---

## Introduction

This document provides a comprehensive analysis and migration plan for converting the NCC Finance Mobile application from its current feature-based architecture to **Hexagonal Architecture** (also known as Ports and Adapters Architecture).

**Document Purpose:**
- Analyze current architecture patterns
- Define hexagonal architecture principles
- Propose folder structure and naming conventions
- Provide implementation examples
- Guide the migration process with best practices

---

## Current Architecture Analysis

### Current Structure Overview

The project currently follows a **feature-based modular architecture**:

```
lib/
├── core/
│   ├── constants/
│   ├── models/
│   ├── notifiers/
│   ├── services/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── authentication/
│   │   ├── notifiers/
│   │   ├── screens/
│   │   └── services/
│   ├── dashboard/
│   │   ├── models/
│   │   ├── notifiers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── transactions/
│   │   ├── models/
│   │   ├── notifiers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── [other features...]
└── main.dart
```

### Current Architecture Characteristics

**✅ Strengths:**
- Clear feature separation
- Service layer abstraction
- Provider-based state management
- Some abstractions (e.g., `AuthService` interface)
- Test infrastructure in place

**⚠️ Areas for Improvement:**
- Direct Firebase dependencies in services (tight coupling)
- Business logic mixed with infrastructure code
- No clear domain layer separation
- Repository pattern not fully implemented
- Use cases not explicitly defined

### Current Dependency Flow

```
UI (Screens/Widgets)
    ↓
Notifiers (State Management)
    ↓
Services (Business + Infrastructure mixed)
    ↓
Firebase/External Services (Direct coupling)
```

**Problem:** The services layer contains both business logic and infrastructure concerns, making it hard to:
- Test business logic in isolation
- Switch data sources (e.g., from Firebase to REST API)
- Maintain and evolve the codebase
- Ensure business rules are technology-agnostic

---

## Hexagonal Architecture Overview

### Core Principles

Hexagonal Architecture (coined by Alistair Cockburn) organizes code around the **business domain**, keeping it isolated from external concerns.

**Key Concepts:**

1. **Domain (Core)** - The heart of the application
   - Contains business logic, entities, and use cases
   - No dependencies on frameworks or external systems
   - Pure Dart code, fully testable

2. **Ports** - Interfaces that define how the outside world communicates with the domain
   - **Input Ports (Driving/Primary):** Interfaces for use cases (what the app does)
   - **Output Ports (Driven/Secondary):** Interfaces for repositories and services (what the app needs)

3. **Adapters** - Implementations of ports
   - **Primary Adapters:** UI, CLI, API endpoints (trigger use cases)
   - **Secondary Adapters:** Database implementations, HTTP clients, Firebase adapters

### The Hexagonal Model

```
                    ┌─────────────────────────────────┐
                    │                                 │
    ┌───────────────┤         DOMAIN LAYER           ├───────────────┐
    │               │   (Entities, Use Cases,        │               │
    │               │    Business Rules)              │               │
    │               │                                 │               │
    │               └────────────┬───────────────────┘               │
    │                            │                                    │
    │                     ┌──────▼──────┐                            │
    │                     │    PORTS    │                            │
    │                     │ (Interfaces) │                           │
    │                     └──────┬──────┘                            │
    │                            │                                    │
    │       ┌────────────────────┼────────────────────┐             │
    │       │                    │                     │             │
┌───▼───────▼─┐            ┌────▼─────┐         ┌────▼──────────┐  │
│  PRIMARY    │            │ SECONDARY │         │   SECONDARY   │  │
│  ADAPTERS   │            │ ADAPTERS  │         │   ADAPTERS    │  │
│             │            │           │         │               │  │
│  - UI       │            │ - Firebase│         │  - HTTP API   │  │
│  - Widgets  │            │ - Local DB│         │  - Cache      │  │
│  - Screens  │            │           │         │               │  │
└─────────────┘            └───────────┘         └───────────────┘  │
                                                                      │
                                                                      │
```

### Benefits

1. **Technology Independence:** Business logic doesn't depend on frameworks
2. **Testability:** Easy to test with mocks (no Firebase needed)
3. **Flexibility:** Easy to swap implementations (Firebase → REST API)
4. **Maintainability:** Clear separation of concerns
5. **Scalability:** Each layer can evolve independently

---

## Proposed Migration Strategy

### Migration Approach

We recommend a **gradual, feature-by-feature migration** rather than a complete rewrite:

1. **Start with one feature** (e.g., transactions)
2. **Establish the new structure** with clear examples
3. **Validate with tests** to ensure nothing breaks
4. **Migrate remaining features** using the established pattern
5. **Refactor and optimize** once all features are migrated

### Layers in the New Architecture

```
Domain Layer (lib/domain)
    ├── Entities (business objects)
    ├── Use Cases (application-specific business rules)
    └── Repository Interfaces (ports)

Application Layer (lib/application)
    └── Notifiers/BLoC (orchestrate use cases)

Infrastructure Layer (lib/infrastructure)
    ├── Repositories (implementations)
    ├── Data Sources (Firebase, API, etc.)
    └── DTOs (Data Transfer Objects)

Presentation Layer (lib/presentation)
    ├── Screens
    ├── Widgets
    └── View Models (optional)
```

---

## Folder Structure

### Recommended Hexagonal Folder Structure

```
lib/
├── domain/                           # Pure business logic (no dependencies)
│   ├── entities/                     # Domain models (business objects)
│   │   ├── transaction.dart
│   │   ├── user_profile.dart
│   │   ├── investment.dart
│   │   └── balance.dart
│   ├── repositories/                 # Repository interfaces (ports)
│   │   ├── transaction_repository.dart
│   │   ├── user_repository.dart
│   │   ├── investment_repository.dart
│   │   └── balance_repository.dart
│   ├── use_cases/                    # Business use cases
│   │   ├── transactions/
│   │   │   ├── create_transaction_use_case.dart
│   │   │   ├── get_transactions_use_case.dart
│   │   │   ├── delete_transaction_use_case.dart
│   │   │   └── update_transaction_use_case.dart
│   │   ├── authentication/
│   │   │   ├── login_use_case.dart
│   │   │   ├── logout_use_case.dart
│   │   │   └── register_user_use_case.dart
│   │   ├── profile/
│   │   │   ├── get_user_profile_use_case.dart
│   │   │   └── update_profile_picture_use_case.dart
│   │   └── investments/
│   │       ├── create_investment_use_case.dart
│   │       └── get_investments_use_case.dart
│   └── exceptions/                   # Domain-specific exceptions
│       ├── transaction_exception.dart
│       ├── authentication_exception.dart
│       └── validation_exception.dart
│
├── infrastructure/                   # External dependencies implementation
│   ├── repositories/                 # Repository implementations
│   │   ├── firebase_transaction_repository.dart
│   │   ├── firebase_user_repository.dart
│   │   ├── firebase_investment_repository.dart
│   │   └── firebase_balance_repository.dart
│   ├── data_sources/                 # Data sources (APIs, DBs)
│   │   ├── remote/
│   │   │   ├── firebase_transaction_data_source.dart
│   │   │   ├── firebase_auth_data_source.dart
│   │   │   └── firebase_storage_data_source.dart
│   │   └── local/                    # For future local storage
│   │       └── cache_data_source.dart
│   ├── dtos/                         # Data Transfer Objects
│   │   ├── transaction_dto.dart
│   │   ├── user_dto.dart
│   │   └── investment_dto.dart
│   └── mappers/                      # Convert DTOs to Entities
│       ├── transaction_mapper.dart
│       ├── user_mapper.dart
│       └── investment_mapper.dart
│
├── application/                      # Application layer (orchestration)
│   ├── notifiers/                    # State management (Provider)
│   │   ├── transaction_notifier.dart
│   │   ├── auth_notifier.dart
│   │   ├── profile_notifier.dart
│   │   └── investment_notifier.dart
│   └── services/                     # Application services (orchestrate use cases)
│       ├── metadata_service.dart
│       └── image_picker_service.dart
│
├── presentation/                     # UI Layer
│   ├── screens/                      # All screens
│   │   ├── authentication/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── transactions/
│   │   │   ├── transactions_screen.dart
│   │   │   ├── create_transaction_screen.dart
│   │   │   └── edit_transaction_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── profile/
│   │   │   └── my_profile_screen.dart
│   │   └── investments/
│   │       ├── investments_screen.dart
│   │       └── create_investment_screen.dart
│   ├── widgets/                      # Reusable widgets
│   │   ├── common/
│   │   │   ├── custom_text_field.dart
│   │   │   ├── primary_button.dart
│   │   │   └── app_snackbar.dart
│   │   ├── transactions/
│   │   │   └── transaction_list_item.dart
│   │   └── dashboard/
│   │       └── action_card.dart
│   └── theme/                        # Theme and styling
│       └── theme.dart
│
├── core/                             # Shared utilities and constants
│   ├── constants/
│   │   ├── app_assets.dart
│   │   └── app_strings.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── color_helper.dart
│   ├── error/
│   │   └── failures.dart
│   └── di/                           # Dependency Injection
│       └── injection_container.dart  # Service locator setup
│
├── firebase_options.dart
└── main.dart                         # App entry point with DI setup
```

### Key Organizational Principles

1. **Domain Layer is Pure:** No imports from infrastructure or presentation
2. **Infrastructure Depends on Domain:** Implements domain interfaces
3. **Presentation Depends on Application & Domain:** Uses use cases via notifiers
4. **Dependency Direction:** Always points inward (toward domain)

```
Presentation → Application → Domain ← Infrastructure
```

---

## File Naming Conventions

### General Rules

1. **Use snake_case** for file names (Dart convention)
2. **Be descriptive and specific** - file names should indicate their purpose
3. **Include layer suffix** when necessary for clarity
4. **Group related files** in subdirectories

### By Layer

#### Domain Layer

**Entities:**
- `{entity_name}.dart`
- Examples: `transaction.dart`, `user_profile.dart`, `investment.dart`

**Repository Interfaces:**
- `{entity}_repository.dart`
- Examples: `transaction_repository.dart`, `user_repository.dart`

**Use Cases:**
- `{verb}_{entity}_use_case.dart`
- Examples: 
  - `create_transaction_use_case.dart`
  - `get_user_profile_use_case.dart`
  - `delete_investment_use_case.dart`

**Exceptions:**
- `{domain}_exception.dart`
- Examples: `transaction_exception.dart`, `authentication_exception.dart`

#### Infrastructure Layer

**Repository Implementations:**
- `{source}_{entity}_repository.dart`
- Examples: `firebase_transaction_repository.dart`, `local_user_repository.dart`

**Data Sources:**
- `{source}_{entity}_data_source.dart`
- Examples: 
  - `firebase_transaction_data_source.dart`
  - `rest_api_transaction_data_source.dart`

**DTOs (Data Transfer Objects):**
- `{entity}_dto.dart`
- Examples: `transaction_dto.dart`, `user_dto.dart`

**Mappers:**
- `{entity}_mapper.dart`
- Examples: `transaction_mapper.dart`, `user_mapper.dart`

#### Application Layer

**Notifiers:**
- `{feature}_notifier.dart`
- Examples: `transaction_notifier.dart`, `auth_notifier.dart`

**Services:**
- `{feature}_service.dart`
- Examples: `metadata_service.dart`, `image_picker_service.dart`

#### Presentation Layer

**Screens:**
- `{feature}_{purpose}_screen.dart`
- Examples:
  - `login_screen.dart`
  - `create_transaction_screen.dart`
  - `transactions_list_screen.dart`

**Widgets:**
- `{component_name}_widget.dart` or just `{component_name}.dart`
- Examples:
  - `transaction_list_item.dart`
  - `custom_text_field.dart`
  - `action_card.dart`

---

## Pattern Implementation Examples

### Example 1: Transaction Feature Migration

#### 1. Domain Layer - Entity

**File:** `lib/domain/entities/transaction.dart`

```dart
import 'package:equatable/equatable.dart';

/// Domain entity representing a financial transaction
/// Pure business object with no external dependencies
class Transaction extends Equatable {
  final String id;
  final double amount;
  final String balanceId;
  final String category;
  final DateTime date;
  final String? description;

  const Transaction({
    required this.id,
    required this.amount,
    required this.balanceId,
    required this.category,
    required this.date,
    this.description,
  });

  /// Business rule: Check if transaction is an expense
  bool get isExpense => amount < 0;

  /// Business rule: Check if transaction is income
  bool get isIncome => amount > 0;

  /// Business rule: Get absolute amount
  double get absoluteAmount => amount.abs();

  @override
  List<Object?> get props => [id, amount, balanceId, category, date, description];

  /// Create a copy with modified fields
  Transaction copyWith({
    String? id,
    double? amount,
    String? balanceId,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      balanceId: balanceId ?? this.balanceId,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
```

#### 2. Domain Layer - Repository Interface (Port)

**File:** `lib/domain/repositories/transaction_repository.dart`

```dart
import 'package:bytebank/domain/entities/transaction.dart';

/// Repository interface (Output Port)
/// Defines what operations are needed without specifying how
abstract class TransactionRepository {
  /// Create a new transaction
  Future<Transaction> createTransaction({
    required String userId,
    required Transaction transaction,
  });

  /// Get all transactions for a user with optional date filters
  Future<List<Transaction>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get paginated transactions
  Future<List<Transaction>> getTransactionsPage({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? lastDocumentIndex,
    required int limit,
  });

  /// Update an existing transaction
  Future<void> updateTransaction({
    required String userId,
    required Transaction transaction,
  });

  /// Delete a transaction
  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  });

  /// Get transaction by ID
  Future<Transaction?> getTransactionById({
    required String userId,
    required String transactionId,
  });
}
```

#### 3. Domain Layer - Use Case

**File:** `lib/domain/use_cases/transactions/create_transaction_use_case.dart`

```dart
import 'package:bytebank/domain/entities/transaction.dart';
import 'package:bytebank/domain/repositories/transaction_repository.dart';
import 'package:bytebank/domain/repositories/balance_repository.dart';

/// Use case for creating a transaction
/// Encapsulates business logic: create transaction + update balance
class CreateTransactionUseCase {
  final TransactionRepository transactionRepository;
  final BalanceRepository balanceRepository;

  CreateTransactionUseCase({
    required this.transactionRepository,
    required this.balanceRepository,
  });

  /// Execute the use case
  Future<Transaction> execute({
    required String userId,
    required double amount,
    required String balanceId,
    required String category,
    required DateTime date,
    String? description,
  }) async {
    // Business rule validation
    if (amount == 0) {
      throw ArgumentError('Transaction amount cannot be zero');
    }

    // Create transaction entity
    final transaction = Transaction(
      id: '', // Will be assigned by repository
      amount: amount,
      balanceId: balanceId,
      category: category,
      date: date,
      description: description,
    );

    // Create transaction in repository
    final createdTransaction = await transactionRepository.createTransaction(
      userId: userId,
      transaction: transaction,
    );

    // Update balance (business rule: transaction affects balance)
    await balanceRepository.updateBalance(
      userId: userId,
      balanceId: balanceId,
      amountChange: amount,
    );

    return createdTransaction;
  }
}
```

#### 4. Infrastructure Layer - DTO

**File:** `lib/infrastructure/dtos/transaction_dto.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Transfer Object for Firebase
/// Handles serialization/deserialization
class TransactionDTO {
  final String id;
  final double amount;
  final String balanceId;
  final String category;
  final Timestamp date;
  final String? description;

  TransactionDTO({
    required this.id,
    required this.amount,
    required this.balanceId,
    required this.category,
    required this.date,
    this.description,
  });

  /// Create DTO from Firestore document
  factory TransactionDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionDTO(
      id: doc.id,
      amount: (data['amount'] ?? 0.0).toDouble(),
      balanceId: data['balanceId'] ?? '',
      category: data['category'] ?? '',
      date: data['date'] as Timestamp,
      description: data['description'],
    );
  }

  /// Convert DTO to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'balanceId': balanceId,
      'category': category,
      'date': date,
      'description': description,
    };
  }
}
```

#### 5. Infrastructure Layer - Mapper

**File:** `lib/infrastructure/mappers/transaction_mapper.dart`

```dart
import 'package:bytebank/domain/entities/transaction.dart';
import 'package:bytebank/infrastructure/dtos/transaction_dto.dart';

/// Mapper to convert between DTO and Entity
class TransactionMapper {
  /// Convert DTO to Domain Entity
  static Transaction toDomain(TransactionDTO dto) {
    return Transaction(
      id: dto.id,
      amount: dto.amount,
      balanceId: dto.balanceId,
      category: dto.category,
      date: dto.date.toDate(),
      description: dto.description,
    );
  }

  /// Convert Domain Entity to DTO
  static TransactionDTO toDTO(Transaction transaction) {
    return TransactionDTO(
      id: transaction.id,
      amount: transaction.amount,
      balanceId: transaction.balanceId,
      category: transaction.category,
      date: Timestamp.fromDate(transaction.date),
      description: transaction.description,
    );
  }
}
```

#### 6. Infrastructure Layer - Repository Implementation

**File:** `lib/infrastructure/repositories/firebase_transaction_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/domain/entities/transaction.dart';
import 'package:bytebank/domain/repositories/transaction_repository.dart';
import 'package:bytebank/infrastructure/dtos/transaction_dto.dart';
import 'package:bytebank/infrastructure/mappers/transaction_mapper.dart';

/// Firebase implementation of TransactionRepository
/// Adapter that connects domain to Firebase infrastructure
class FirebaseTransactionRepository implements TransactionRepository {
  final FirebaseFirestore firestore;

  FirebaseTransactionRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Transaction> createTransaction({
    required String userId,
    required Transaction transaction,
  }) async {
    try {
      final transactionRef = firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc();

      final dto = TransactionMapper.toDTO(transaction);
      await transactionRef.set(dto.toFirestore());

      // Return transaction with assigned ID
      final createdDto = dto.copyWith(id: transactionRef.id);
      return TransactionMapper.toDomain(createdDto);
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TransactionMapper.toDomain(
                TransactionDTO.fromFirestore(doc),
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  @override
  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction({
    required String userId,
    required Transaction transaction,
  }) async {
    try {
      final dto = TransactionMapper.toDTO(transaction);
      await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id)
          .update(dto.toFirestore());
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Future<Transaction?> getTransactionById({
    required String userId,
    required String transactionId,
  }) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (!doc.exists) return null;

      return TransactionMapper.toDomain(
        TransactionDTO.fromFirestore(doc),
      );
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactionsPage({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? lastDocumentIndex,
    required int limit,
  }) async {
    // Implementation for pagination
    // Similar to getTransactions but with pagination logic
    throw UnimplementedError('Pagination implementation pending');
  }
}
```

#### 7. Application Layer - Notifier

**File:** `lib/application/notifiers/transaction_notifier.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:bytebank/domain/entities/transaction.dart';
import 'package:bytebank/domain/use_cases/transactions/create_transaction_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/get_transactions_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/delete_transaction_use_case.dart';

/// Application layer notifier
/// Orchestrates use cases and manages UI state
class TransactionNotifier extends ChangeNotifier {
  final CreateTransactionUseCase createTransactionUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;

  TransactionNotifier({
    required this.createTransactionUseCase,
    required this.getTransactionsUseCase,
    required this.deleteTransactionUseCase,
  });

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch transactions for a user
  Future<void> fetchTransactions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await getTransactionsUseCase.execute(userId: userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new transaction
  Future<void> createTransaction({
    required String userId,
    required double amount,
    required String balanceId,
    required String category,
    required DateTime date,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await createTransactionUseCase.execute(
        userId: userId,
        amount: amount,
        balanceId: balanceId,
        category: category,
        date: date,
        description: description,
      );

      // Refresh list
      await fetchTransactions(userId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) async {
    try {
      await deleteTransactionUseCase.execute(
        userId: userId,
        transactionId: transactionId,
      );

      // Refresh list
      await fetchTransactions(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

#### 8. Presentation Layer - Screen

**File:** `lib/presentation/screens/transactions/transactions_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bytebank/application/notifiers/transaction_notifier.dart';

/// Presentation layer - UI Screen
/// Depends only on application layer (notifiers)
class TransactionsScreen extends StatefulWidget {
  static const String routeName = '/transactions';

  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch transactions on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = context.read<TransactionNotifier>();
      notifier.fetchTransactions('current-user-id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Consumer<TransactionNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifier.error != null) {
            return Center(child: Text('Error: ${notifier.error}'));
          }

          if (notifier.transactions.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          return ListView.builder(
            itemCount: notifier.transactions.length,
            itemBuilder: (context, index) {
              final transaction = notifier.transactions[index];
              return ListTile(
                title: Text(transaction.description ?? 'No description'),
                subtitle: Text(transaction.category),
                trailing: Text('\$${transaction.amount.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}
```

#### 9. Dependency Injection Setup

**File:** `lib/core/di/injection_container.dart`

```dart
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/domain/repositories/transaction_repository.dart';
import 'package:bytebank/domain/repositories/balance_repository.dart';
import 'package:bytebank/domain/use_cases/transactions/create_transaction_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/get_transactions_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/delete_transaction_use_case.dart';
import 'package:bytebank/infrastructure/repositories/firebase_transaction_repository.dart';
import 'package:bytebank/infrastructure/repositories/firebase_balance_repository.dart';
import 'package:bytebank/application/notifiers/transaction_notifier.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
    () => FirebaseTransactionRepository(firestore: sl()),
  );
  sl.registerLazySingleton<BalanceRepository>(
    () => FirebaseBalanceRepository(firestore: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => CreateTransactionUseCase(
      transactionRepository: sl(),
      balanceRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => GetTransactionsUseCase(transactionRepository: sl()),
  );
  sl.registerLazySingleton(
    () => DeleteTransactionUseCase(
      transactionRepository: sl(),
      balanceRepository: sl(),
    ),
  );

  // Notifiers
  sl.registerFactory(
    () => TransactionNotifier(
      createTransactionUseCase: sl(),
      getTransactionsUseCase: sl(),
      deleteTransactionUseCase: sl(),
    ),
  );
}
```

---

## Best Practices

### 1. Dependency Rule

**Rule:** Dependencies should point inward (toward the domain).

```
✅ Infrastructure → Domain (implements interfaces)
✅ Application → Domain (uses entities, use cases)
✅ Presentation → Application (uses notifiers)

❌ Domain → Infrastructure (NO!)
❌ Domain → Presentation (NO!)
```

### 2. Pure Domain Layer

**Do:**
- Keep domain entities as pure Dart classes
- Put business logic in entities and use cases
- Define repository interfaces (ports) in domain
- Use value objects for validation

**Don't:**
- Import Firebase, HTTP, or any framework in domain
- Put UI logic in domain
- Access external services directly

### 3. Single Responsibility

**Each layer has one job:**
- **Domain:** Business logic and rules
- **Infrastructure:** Technical implementation
- **Application:** Orchestration
- **Presentation:** UI rendering

### 4. Testing Strategy

```
Domain Tests (Unit Tests):
- Test entities, use cases, business rules
- No mocks needed for pure logic
- Fast and comprehensive

Infrastructure Tests (Integration Tests):
- Test repository implementations
- Mock Firebase or use fakes
- Ensure correct data mapping

Application Tests (Unit Tests):
- Test notifiers with mocked use cases
- Verify state management logic

Presentation Tests (Widget Tests):
- Test UI rendering and interactions
- Mock notifiers
```

### 5. Error Handling

**Domain exceptions:**
```dart
// Domain-specific exceptions
class TransactionException implements Exception {
  final String message;
  TransactionException(this.message);
}

class ValidationException implements Exception {
  final String field;
  final String message;
  ValidationException(this.field, this.message);
}
```

**Infrastructure error mapping:**
```dart
// Map infrastructure errors to domain exceptions
try {
  await firestore.collection('transactions').add(data);
} on FirebaseException catch (e) {
  throw TransactionException('Failed to create transaction: ${e.message}');
}
```

### 6. Use Cases Should Be Small

Each use case should do **one thing**:

```
✅ CreateTransactionUseCase
✅ GetTransactionsUseCase
✅ DeleteTransactionUseCase
✅ UpdateTransactionUseCase

❌ TransactionManagementUseCase (too broad)
```

### 7. DTOs vs Entities

**When to use DTOs:**
- Communicating with external systems (Firebase, APIs)
- Serialization/deserialization
- Different structure than domain model

**When to use Entities:**
- Business logic
- Passing data between layers
- Internal application state

### 8. Mappers Are Essential

Always use mappers to convert between DTOs and Entities:

```dart
// Clear, testable, maintainable
final transaction = TransactionMapper.toDomain(dto);

// ❌ Avoid inline conversions scattered everywhere
```

### 9. Dependency Injection

**Use a service locator (get_it) or Provider:**

```dart
// Register dependencies once
sl.registerLazySingleton<TransactionRepository>(
  () => FirebaseTransactionRepository(firestore: sl()),
);

// Use everywhere
final repository = sl<TransactionRepository>();
```

### 10. Documentation

- Document business rules in domain entities
- Explain port purposes in repository interfaces
- Add architecture decision records (ADRs) for major changes

---

## Migration Roadmap

### Phase 1: Setup Foundation (Week 1)

**Tasks:**
1. Create new folder structure
2. Set up dependency injection (get_it)
3. Create base classes and interfaces
4. Add documentation

**Deliverables:**
- New folder structure in place
- `injection_container.dart` configured
- Base repository interfaces defined

### Phase 2: Migrate One Feature (Week 2-3)

**Feature:** Transactions (as reference implementation)

**Tasks:**
1. Create domain layer (entities, repository interface, use cases)
2. Create infrastructure layer (DTOs, mappers, repository implementation)
3. Update application layer (notifiers)
4. Update presentation layer (screens)
5. Write comprehensive tests
6. Update dependency injection

**Deliverables:**
- Fully migrated transaction feature
- Complete test coverage
- Documentation and examples

### Phase 3: Migrate Remaining Features (Week 4-6)

**Features:**
- Authentication
- Profile
- Dashboard
- Investments

**Tasks:**
1. Apply same pattern from Phase 2
2. Reuse common infrastructure (Firebase setup)
3. Test each feature thoroughly
4. Refactor common code

**Deliverables:**
- All features migrated
- Consistent architecture across app
- Updated tests

### Phase 4: Optimization & Cleanup (Week 7)

**Tasks:**
1. Remove old code and folder structure
2. Optimize dependency injection
3. Add missing documentation
4. Performance testing
5. Code review and refactoring

**Deliverables:**
- Clean codebase
- Optimized performance
- Complete documentation

### Phase 5: Validation & Deployment (Week 8)

**Tasks:**
1. End-to-end testing
2. User acceptance testing
3. Performance benchmarking
4. Deploy to staging
5. Monitor and fix issues

**Deliverables:**
- Fully tested application
- Deployed to production
- Migration complete!

---

## Conclusion

Hexagonal Architecture provides a solid foundation for building maintainable, testable, and scalable Flutter applications. By separating business logic from infrastructure concerns, the NCC Finance Mobile application will be:

1. **Easier to test** - Pure domain logic without Firebase dependencies
2. **More maintainable** - Clear separation of concerns
3. **More flexible** - Easy to swap implementations
4. **Better organized** - Logical folder structure
5. **Future-proof** - Ready for growth and changes

### Success Criteria

The migration will be considered successful when:

- ✅ All features work as before (no regressions)
- ✅ Test coverage is maintained or improved
- ✅ Business logic is independent of Firebase
- ✅ New features can be added easily
- ✅ Code is well-documented and clear

### Next Steps

1. **Review and approve** this document with the team
2. **Start Phase 1** - Set up foundation
3. **Complete pilot migration** - Transactions feature
4. **Iterate and improve** - Apply learnings
5. **Complete migration** - All features

---

## References

- **Hexagonal Architecture:** https://alistair.cockburn.us/hexagonal-architecture/
- **Clean Architecture (Uncle Bob):** https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **Flutter Clean Architecture:** https://resocoder.com/flutter-clean-architecture-tdd/
- **Ports and Adapters:** https://herbertograca.com/2017/09/14/ports-adapters-architecture/
- **Domain-Driven Design:** https://martinfowler.com/bliki/DomainDrivenDesign.html

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-10  
**Author:** NCC Finance Mobile Team  
**Status:** Approved for Implementation
