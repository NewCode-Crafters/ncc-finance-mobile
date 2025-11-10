# Hexagonal Architecture Visual Diagrams

This document provides visual representations of the hexagonal architecture migration for the NCC Finance Mobile application.

---

## Table of Contents
1. [Current Architecture vs. Hexagonal Architecture](#current-architecture-vs-hexagonal-architecture)
2. [Dependency Flow Diagrams](#dependency-flow-diagrams)
3. [Feature Module Structure](#feature-module-structure)
4. [Layer Interaction Diagrams](#layer-interaction-diagrams)
5. [Transaction Flow Example](#transaction-flow-example)

---

## Current Architecture vs. Hexagonal Architecture

### Current Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                       PRESENTATION LAYER                     │
│                    (Screens & Widgets)                       │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐     │
│  │   Login     │  │ Transactions │  │   Dashboard    │     │
│  │   Screen    │  │    Screen    │  │     Screen     │     │
│  └──────┬──────┘  └──────┬───────┘  └────────┬───────┘     │
│         │                │                    │              │
└─────────┼────────────────┼────────────────────┼──────────────┘
          │                │                    │
          ▼                ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                   STATE MANAGEMENT LAYER                     │
│                    (Provider Notifiers)                      │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐     │
│  │    Auth     │  │ Transaction  │  │    Balance     │     │
│  │  Notifier   │  │   Notifier   │  │    Notifier    │     │
│  └──────┬──────┘  └──────┬───────┘  └────────┬───────┘     │
│         │                │                    │              │
└─────────┼────────────────┼────────────────────┼──────────────┘
          │                │                    │
          ▼                ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                      SERVICE LAYER                           │
│         (Business Logic + Infrastructure Mixed)              │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐     │
│  │    Auth     │  │ Transaction  │  │    Balance     │     │
│  │  Service    │  │   Service    │  │    Service     │     │
│  └──────┬──────┘  └──────┬───────┘  └────────┬───────┘     │
│         │                │                    │              │
│         └────────────────┼────────────────────┘              │
│                          │                                   │
└──────────────────────────┼───────────────────────────────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │    FIREBASE     │
                  │  (Firestore,    │
                  │   Auth, Storage)│
                  └─────────────────┘

PROBLEMS:
❌ Tight coupling to Firebase
❌ Business logic mixed with infrastructure
❌ Hard to test without Firebase
❌ Difficult to change data sources
```

### Hexagonal Architecture Diagram

```
                     ╔═══════════════════════════════╗
                     ║     PRESENTATION LAYER        ║
                     ║    (UI - Primary Adapter)     ║
                     ╚═══════════════════════════════╝
                                   │
                                   │ Uses
                                   ▼
                     ╔═══════════════════════════════╗
                     ║    APPLICATION LAYER          ║
                     ║  (Orchestration - Notifiers)  ║
                     ╚═══════════════════════════════╝
                                   │
                                   │ Uses
                                   ▼
        ╔════════════════════════════════════════════════════╗
        ║                 DOMAIN LAYER (CORE)                ║
        ║                                                    ║
        ║  ┌──────────────┐    ┌───────────────┐           ║
        ║  │   Entities   │    │   Use Cases   │           ║
        ║  │ (Business    │    │  (Business    │           ║
        ║  │   Objects)   │    │    Logic)     │           ║
        ║  └──────────────┘    └───────┬───────┘           ║
        ║                              │                    ║
        ║                              │                    ║
        ║                     ┌────────▼────────┐           ║
        ║                     │  Repository     │           ║
        ║                     │  Interfaces     │           ║
        ║                     │  (Output Ports) │           ║
        ║                     └─────────────────┘           ║
        ╚════════════════════════════════════════════════════╝
                                   ▲
                                   │ Implements
                                   │
        ╔══════════════════════════════════════════════════╗
        ║         INFRASTRUCTURE LAYER                     ║
        ║       (Secondary Adapters)                       ║
        ║                                                  ║
        ║  ┌──────────────┐  ┌──────────────┐            ║
        ║  │   Firebase   │  │     REST     │            ║
        ║  │  Repository  │  │  Repository  │            ║
        ║  │     Impl     │  │     Impl     │            ║
        ║  └──────┬───────┘  └──────┬───────┘            ║
        ║         │                  │                    ║
        ║         ▼                  ▼                    ║
        ║  ┌──────────────┐  ┌──────────────┐            ║
        ║  │   Firebase   │  │   HTTP API   │            ║
        ║  │ Data Source  │  │ Data Source  │            ║
        ║  └──────────────┘  └──────────────┘            ║
        ╚══════════════════════════════════════════════════╝

BENEFITS:
✅ Business logic isolated from infrastructure
✅ Easy to test (mock repositories)
✅ Easy to swap implementations
✅ Clear separation of concerns
✅ Technology-independent domain
```

---

## Dependency Flow Diagrams

### Dependency Direction Rule

```
┌─────────────────────────────────────────────────────────┐
│  DEPENDENCY RULE: All dependencies point INWARD         │
│                    (toward the domain)                   │
└─────────────────────────────────────────────────────────┘

Presentation Layer
       │
       │ depends on
       ▼
Application Layer
       │
       │ depends on
       ▼
  Domain Layer  ◄────── Infrastructure Layer
  (Core/Pure)             (implements)

✅ Infrastructure → Domain (implements interfaces)
✅ Application → Domain (uses entities, use cases)
✅ Presentation → Application (uses notifiers)

❌ Domain → Infrastructure (NEVER!)
❌ Domain → Application (NEVER!)
❌ Domain → Presentation (NEVER!)
```

### Module Dependencies

```
┌──────────────────────────────────────────────────────────────┐
│                    PRESENTATION                               │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐            │
│  │ Auth   │  │ Trans  │  │Profile │  │Dashboard│            │
│  │Screens │  │Screens │  │Screens │  │Screens  │            │
│  └───┬────┘  └───┬────┘  └───┬────┘  └───┬────┘            │
└──────┼───────────┼───────────┼───────────┼──────────────────┘
       │           │           │           │
       ▼           ▼           ▼           ▼
┌──────────────────────────────────────────────────────────────┐
│                   APPLICATION                                 │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐            │
│  │ Auth   │  │ Trans  │  │Profile │  │Balance  │            │
│  │Notifier│  │Notifier│  │Notifier│  │Notifier │            │
│  └───┬────┘  └───┬────┘  └───┬────┘  └───┬────┘            │
└──────┼───────────┼───────────┼───────────┼──────────────────┘
       │           │           │           │
       ▼           ▼           ▼           ▼
┌──────────────────────────────────────────────────────────────┐
│                      DOMAIN                                   │
│  ┌─────────────────────────────────────────────────┐         │
│  │              Use Cases                          │         │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐          │         │
│  │  │Login │ │Create│ │Get   │ │Update│          │         │
│  │  │      │ │Trans │ │Profile│ │Balance│         │         │
│  │  └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘          │         │
│  └─────┼────────┼────────┼────────┼───────────────┘         │
│        │        │        │        │                          │
│  ┌─────▼────────▼────────▼────────▼───────────────┐         │
│  │          Repository Interfaces (Ports)          │         │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐          │         │
│  │  │ Auth │ │Trans │ │User  │ │Balance│          │         │
│  │  │ Repo │ │ Repo │ │ Repo │ │ Repo  │          │         │
│  │  └──────┘ └──────┘ └──────┘ └──────┘          │         │
│  └─────────────────────────────────────────────────┘         │
│                          ▲                                    │
└──────────────────────────┼────────────────────────────────────┘
                           │ implements
┌──────────────────────────┼────────────────────────────────────┐
│                   INFRASTRUCTURE                              │
│  ┌─────────────────────────────────────────────────┐         │
│  │      Repository Implementations                 │         │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐          │         │
│  │  │Fire  │ │Fire  │ │Fire  │ │Fire  │          │         │
│  │  │base  │ │base  │ │base  │ │base  │          │         │
│  │  │Auth  │ │Trans │ │User  │ │Balance│          │         │
│  │  │Repo  │ │Repo  │ │Repo  │ │Repo   │          │         │
│  │  └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘          │         │
│  └─────┼────────┼────────┼────────┼───────────────┘         │
│        │        │        │        │                          │
│  ┌─────▼────────▼────────▼────────▼───────────────┐         │
│  │           Data Sources & DTOs                   │         │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐     │         │
│  │  │ Firebase │  │ Firebase │  │ Firebase │     │         │
│  │  │   Auth   │  │Firestore │  │ Storage  │     │         │
│  │  └──────────┘  └──────────┘  └──────────┘     │         │
│  └─────────────────────────────────────────────────┘         │
└──────────────────────────────────────────────────────────────┘
```

---

## Feature Module Structure

### Transaction Feature - Hexagonal Layout

```
lib/
│
├─ domain/
│  └─ transactions/
│     ├─ entities/
│     │  └─ transaction.dart ─────────┐
│     │                                │ Pure business objects
│     │                                │ No external dependencies
│     ├─ repositories/                 │
│     │  └─ transaction_repository.dart ◄── Interface (Output Port)
│     │                                │
│     └─ use_cases/                    │
│        ├─ create_transaction_use_case.dart
│        ├─ get_transactions_use_case.dart
│        ├─ update_transaction_use_case.dart
│        └─ delete_transaction_use_case.dart
│                    │
│                    │ Uses
│                    ▼
├─ infrastructure/
│  └─ transactions/
│     ├─ repositories/
│     │  └─ firebase_transaction_repository.dart ◄── Implements Port
│     │                                │
│     ├─ data_sources/                 │
│     │  └─ firebase_transaction_data_source.dart
│     │                                │
│     ├─ dtos/                         │
│     │  └─ transaction_dto.dart       │ Data transfer objects
│     │                                │
│     └─ mappers/                      │
│        └─ transaction_mapper.dart ───┘ DTO ↔ Entity conversion
│                    ▲
│                    │ Uses
│                    │
├─ application/
│  └─ notifiers/
│     └─ transaction_notifier.dart ◄── Orchestrates use cases
│                    ▲
│                    │ Uses
│                    │
└─ presentation/
   └─ screens/
      └─ transactions/
         ├─ transactions_screen.dart
         ├─ create_transaction_screen.dart
         └─ edit_transaction_screen.dart
```

### Authentication Feature - Hexagonal Layout

```
lib/
│
├─ domain/
│  └─ authentication/
│     ├─ entities/
│     │  └─ user.dart
│     │
│     ├─ repositories/
│     │  └─ auth_repository.dart ◄── Interface (Output Port)
│     │
│     └─ use_cases/
│        ├─ login_use_case.dart
│        ├─ logout_use_case.dart
│        ├─ register_use_case.dart
│        └─ reset_password_use_case.dart
│
├─ infrastructure/
│  └─ authentication/
│     ├─ repositories/
│     │  └─ firebase_auth_repository.dart ◄── Implements Port
│     │
│     ├─ data_sources/
│     │  └─ firebase_auth_data_source.dart
│     │
│     └─ dtos/
│        └─ user_dto.dart
│
├─ application/
│  └─ notifiers/
│     └─ auth_notifier.dart
│
└─ presentation/
   └─ screens/
      └─ authentication/
         ├─ login_screen.dart
         ├─ register_screen.dart
         └─ update_account_screen.dart
```

---

## Layer Interaction Diagrams

### Create Transaction Flow

```
USER INTERACTION
       │
       ▼
┌────────────────────────────────────────────────────────────┐
│  PRESENTATION: CreateTransactionScreen                     │
│  ┌──────────────────────────────────────────────┐         │
│  │ User fills form and clicks "Create"           │         │
│  └────────────────────┬─────────────────────────┘         │
└───────────────────────┼────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────────┐
│  APPLICATION: TransactionNotifier                          │
│  ┌──────────────────────────────────────────────┐         │
│  │ transactionNotifier.createTransaction(...)    │         │
│  │   • Validates input                           │         │
│  │   • Calls use case                            │         │
│  │   • Updates UI state                          │         │
│  └────────────────────┬─────────────────────────┘         │
└───────────────────────┼────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────────┐
│  DOMAIN: CreateTransactionUseCase                          │
│  ┌──────────────────────────────────────────────┐         │
│  │ execute(userId, amount, category, ...)        │         │
│  │   1. Validates business rules                 │         │
│  │   2. Creates Transaction entity               │         │
│  │   3. Calls repository.createTransaction()     │         │
│  │   4. Calls repository.updateBalance()         │         │
│  │   5. Returns created transaction              │         │
│  └────────────────────┬─────────────────────────┘         │
└───────────────────────┼────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────────┐
│  DOMAIN: TransactionRepository (Interface)                 │
│  ┌──────────────────────────────────────────────┐         │
│  │ abstract class TransactionRepository {        │         │
│  │   Future<Transaction> createTransaction(...); │         │
│  │ }                                             │         │
│  └────────────────────┬─────────────────────────┘         │
└───────────────────────┼────────────────────────────────────┘
                        │
                        ▼ (implements)
┌────────────────────────────────────────────────────────────┐
│  INFRASTRUCTURE: FirebaseTransactionRepository             │
│  ┌──────────────────────────────────────────────┐         │
│  │ createTransaction(...)                        │         │
│  │   1. Converts Entity to DTO                   │         │
│  │   2. Calls Firebase data source               │         │
│  │   3. Converts DTO back to Entity              │         │
│  │   4. Returns entity                           │         │
│  └────────────────────┬─────────────────────────┘         │
└───────────────────────┼────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────────┐
│  INFRASTRUCTURE: Firebase (External Service)               │
│  ┌──────────────────────────────────────────────┐         │
│  │ Firestore.collection('transactions').add(...) │         │
│  └───────────────────────────────────────────────┘         │
└────────────────────────────────────────────────────────────┘
                        │
                        ▼
                   SUCCESS/ERROR
                        │
                        │ (propagates back up)
                        ▼
                   UI UPDATES
```

### Get Transactions Flow

```
USER INTERACTION
       │
       ▼
┌────────────────────────────────────────────────────────────┐
│  PRESENTATION: TransactionsScreen                          │
│  ┌──────────────────────────────────────────────┐         │
│  │ Screen loads, initState() called              │         │
│  └────────────────────┬─────────────────────────┘         │
└───────────────────────┼────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────────┐
│  APPLICATION: TransactionNotifier                          │
│  ┌──────────────────────────────────────────────┐         │
│  │ fetchTransactions(userId)                     │         │
│  │   • Sets loading state                        │         │
│  │   • Calls use case                            │         │
│  │   • Updates transactions list                 │         │
│  │   • Notifies listeners                        │         │
│  └────────────────────┬─────────────────────────┘         │
└───────────────────────┼────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────────┐
│  DOMAIN: GetTransactionsUseCase                            │
│  ┌──────────────────────────────────────────────┐         │
│  │ execute(userId, startDate?, endDate?)         │         │
│  │   1. Calls repository.getTransactions()       │         │
│  │   2. Applies business filters if needed       │         │
│  │   3. Returns list of transactions             │         │
│  └────────────────────┬─────────────────────────┘         │
└───────────────────────┼────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────────┐
│  INFRASTRUCTURE: FirebaseTransactionRepository             │
│  ┌──────────────────────────────────────────────┐         │
│  │ getTransactions(...)                          │         │
│  │   1. Queries Firestore                        │         │
│  │   2. Gets DTOs from documents                 │         │
│  │   3. Maps DTOs to Entities                    │         │
│  │   4. Returns list of entities                 │         │
│  └────────────────────┬─────────────────────────┘         │
└───────────────────────┼────────────────────────────────────┘
                        │
                        ▼
                 TRANSACTIONS LIST
                        │
                        ▼
                   UI DISPLAYS
```

---

## Transaction Flow Example

### Complete Flow: Creating a Transaction

```
┌─────────────────────────────────────────────────────────────────────┐
│                       USER ACTION                                    │
│  User fills out transaction form:                                   │
│  - Amount: -50.00                                                    │
│  - Category: Groceries                                               │
│  - Date: 2025-11-10                                                  │
│  - Description: "Weekly groceries"                                   │
│  - Clicks "Create Transaction" button                                │
└────────────────────────────────┬─────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER: CreateTransactionScreen                         │
├─────────────────────────────────────────────────────────────────────┤
│ void _createTransaction() {                                         │
│   context.read<TransactionNotifier>().createTransaction(            │
│     userId: currentUser.id,                                         │
│     amount: -50.00,                                                 │
│     balanceId: selectedBalance.id,                                  │
│     category: 'GROCERIES',                                          │
│     date: DateTime(2025, 11, 10),                                   │
│     description: 'Weekly groceries',                                │
│   );                                                                │
│ }                                                                   │
└────────────────────────────────┬─────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│ APPLICATION LAYER: TransactionNotifier                              │
├─────────────────────────────────────────────────────────────────────┤
│ Future<void> createTransaction(...) async {                         │
│   _isLoading = true;                                                │
│   notifyListeners();  // UI shows loading spinner                   │
│                                                                     │
│   try {                                                             │
│     await _createTransactionUseCase.execute(                        │
│       userId: userId,                                               │
│       amount: amount,                                               │
│       balanceId: balanceId,                                         │
│       category: category,                                           │
│       date: date,                                                   │
│       description: description,                                     │
│     );                                                              │
│                                                                     │
│     _isLoading = false;                                             │
│     _successMessage = 'Transaction created!';                       │
│     notifyListeners();  // UI shows success                         │
│     await fetchTransactions(userId);  // Refresh list               │
│   } catch (e) {                                                     │
│     _error = e.toString();                                          │
│     _isLoading = false;                                             │
│     notifyListeners();  // UI shows error                           │
│   }                                                                 │
│ }                                                                   │
└────────────────────────────────┬─────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER: CreateTransactionUseCase                              │
├─────────────────────────────────────────────────────────────────────┤
│ Future<Transaction> execute(...) async {                            │
│   // BUSINESS RULE VALIDATION                                       │
│   if (amount == 0) {                                                │
│     throw ValidationException('Amount cannot be zero');             │
│   }                                                                 │
│                                                                     │
│   // CREATE ENTITY                                                  │
│   final transaction = Transaction(                                  │
│     id: '',  // Will be assigned by repository                      │
│     amount: amount,                                                 │
│     balanceId: balanceId,                                           │
│     category: category,                                             │
│     date: date,                                                     │
│     description: description,                                       │
│   );                                                                │
│                                                                     │
│   // CALL REPOSITORY (PORT)                                         │
│   final created = await _transactionRepository.createTransaction(   │
│     userId: userId,                                                 │
│     transaction: transaction,                                       │
│   );                                                                │
│                                                                     │
│   // UPDATE BALANCE (BUSINESS RULE)                                 │
│   await _balanceRepository.updateBalance(                           │
│     userId: userId,                                                 │
│     balanceId: balanceId,                                           │
│     amountChange: amount,  // -50.00                                │
│   );                                                                │
│                                                                     │
│   return created;                                                   │
│ }                                                                   │
└────────────────────────────────┬─────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│ INFRASTRUCTURE: FirebaseTransactionRepository                       │
├─────────────────────────────────────────────────────────────────────┤
│ Future<Transaction> createTransaction(...) async {                  │
│   // CONVERT ENTITY TO DTO                                          │
│   final dto = TransactionMapper.toDTO(transaction);                 │
│                                                                     │
│   // FIREBASE CALL                                                  │
│   final docRef = _firestore                                         │
│     .collection('users')                                            │
│     .doc(userId)                                                    │
│     .collection('transactions')                                     │
│     .doc();                                                         │
│                                                                     │
│   await docRef.set(dto.toFirestore());                              │
│                                                                     │
│   // CONVERT BACK TO ENTITY WITH ASSIGNED ID                        │
│   final createdDto = dto.copyWith(id: docRef.id);                   │
│   return TransactionMapper.toDomain(createdDto);                    │
│ }                                                                   │
└────────────────────────────────┬─────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│ FIREBASE FIRESTORE                                                  │
├─────────────────────────────────────────────────────────────────────┤
│ Document Created:                                                   │
│ /users/{userId}/transactions/{generatedId}                          │
│ {                                                                   │
│   "amount": -50.00,                                                 │
│   "balanceId": "balance123",                                        │
│   "category": "GROCERIES",                                          │
│   "date": Timestamp(2025-11-10),                                    │
│   "description": "Weekly groceries"                                 │
│ }                                                                   │
└────────────────────────────────┬─────────────────────────────────────┘
                                 │
                                 ▼
                            SUCCESS ✓
                                 │
                (Response propagates back up the stack)
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│ UI UPDATES                                                          │
├─────────────────────────────────────────────────────────────────────┤
│ 1. Loading spinner disappears                                       │
│ 2. Success message shown: "Transaction created!"                    │
│ 3. Transaction list refreshes                                       │
│ 4. Balance updates to reflect new transaction                       │
│ 5. User sees new transaction in list                                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Key Takeaways

### 1. Clear Separation of Concerns
Each layer has a specific responsibility:
- **Presentation:** Display and user interaction
- **Application:** Orchestration and state management
- **Domain:** Business logic and rules
- **Infrastructure:** External service integration

### 2. Dependency Inversion
- High-level modules (domain) don't depend on low-level modules (infrastructure)
- Both depend on abstractions (interfaces/ports)

### 3. Testability
Each layer can be tested independently:
```
✅ Domain: Test with pure unit tests (no mocks)
✅ Application: Test with mocked use cases
✅ Infrastructure: Test with mocked Firebase or fakes
✅ Presentation: Test with mocked notifiers
```

### 4. Flexibility
Easy to:
- Swap Firebase for REST API
- Change state management solution
- Modify UI without touching business logic
- Add new features following the same pattern

### 5. Maintainability
- Code is organized logically
- Business rules are centralized
- Changes are localized
- Easy to understand and navigate

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-10  
**Status:** Supplementary Visual Guide
