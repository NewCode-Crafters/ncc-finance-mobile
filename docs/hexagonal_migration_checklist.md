# Hexagonal Architecture Migration Checklist

This document provides a practical, step-by-step checklist for migrating the NCC Finance Mobile application to hexagonal architecture.

---

## Pre-Migration Checklist

### ✅ Preparation Phase

- [ ] **Read Documentation**
  - [ ] Review `hexagonal_architecture_analysis.md`
  - [ ] Study `hexagonal_architecture_diagrams.md`
  - [ ] Understand the pattern names and conventions

- [ ] **Team Alignment**
  - [ ] Share documents with the team
  - [ ] Conduct architecture review meeting
  - [ ] Get stakeholder approval
  - [ ] Assign responsibilities

- [ ] **Backup and Safety**
  - [ ] Create a new branch for migration
  - [ ] Ensure all tests pass in current state
  - [ ] Document current test coverage
  - [ ] Tag current stable version

- [ ] **Tool Setup**
  - [ ] Add `get_it` package for dependency injection
  - [ ] Set up testing tools (mockito, fake_cloud_firestore)
  - [ ] Configure linters for new structure

---

## Phase 1: Foundation Setup

### 🏗️ Create New Folder Structure

- [ ] **Create Domain Layer Folders**
  ```bash
  mkdir -p lib/domain/entities
  mkdir -p lib/domain/repositories
  mkdir -p lib/domain/use_cases
  mkdir -p lib/domain/exceptions
  ```

- [ ] **Create Infrastructure Layer Folders**
  ```bash
  mkdir -p lib/infrastructure/repositories
  mkdir -p lib/infrastructure/data_sources/remote
  mkdir -p lib/infrastructure/data_sources/local
  mkdir -p lib/infrastructure/dtos
  mkdir -p lib/infrastructure/mappers
  ```

- [ ] **Create Application Layer Folders**
  ```bash
  mkdir -p lib/application/notifiers
  mkdir -p lib/application/services
  ```

- [ ] **Create Presentation Layer Folders**
  ```bash
  mkdir -p lib/presentation/screens
  mkdir -p lib/presentation/widgets
  mkdir -p lib/presentation/theme
  ```

- [ ] **Create Core Folders**
  ```bash
  mkdir -p lib/core/di
  mkdir -p lib/core/constants
  mkdir -p lib/core/utils
  mkdir -p lib/core/error
  ```

### 🔧 Setup Dependency Injection

- [ ] **Add Dependencies**
  - [ ] Add `get_it: ^7.6.0` to `pubspec.yaml`
  - [ ] Run `flutter pub get`

- [ ] **Create Injection Container**
  - [ ] Create `lib/core/di/injection_container.dart`
  - [ ] Define `initializeDependencies()` function
  - [ ] Set up GetIt instance

- [ ] **Update main.dart**
  - [ ] Call `initializeDependencies()` in `main()`
  - [ ] Replace Provider registrations with GetIt

---

## Phase 2: Migrate Transaction Feature (Pilot)

### 🎯 Domain Layer

- [ ] **Create Transaction Entity**
  - [ ] Create `lib/domain/entities/transaction.dart`
  - [ ] Define business rules (isExpense, isIncome, etc.)
  - [ ] Add `copyWith()` method
  - [ ] Extend `Equatable` for value equality
  - [ ] Write unit tests for entity

- [ ] **Create Repository Interface**
  - [ ] Create `lib/domain/repositories/transaction_repository.dart`
  - [ ] Define abstract methods (createTransaction, getTransactions, etc.)
  - [ ] Document method purposes with comments

- [ ] **Create Use Cases**
  - [ ] Create `lib/domain/use_cases/transactions/create_transaction_use_case.dart`
  - [ ] Create `lib/domain/use_cases/transactions/get_transactions_use_case.dart`
  - [ ] Create `lib/domain/use_cases/transactions/update_transaction_use_case.dart`
  - [ ] Create `lib/domain/use_cases/transactions/delete_transaction_use_case.dart`
  - [ ] Implement business logic in each use case
  - [ ] Write unit tests for each use case

- [ ] **Create Domain Exceptions**
  - [ ] Create `lib/domain/exceptions/transaction_exception.dart`
  - [ ] Define custom exception types

### 🏗️ Infrastructure Layer

- [ ] **Create DTO**
  - [ ] Create `lib/infrastructure/dtos/transaction_dto.dart`
  - [ ] Add `fromFirestore()` factory
  - [ ] Add `toFirestore()` method
  - [ ] Add `copyWith()` method

- [ ] **Create Mapper**
  - [ ] Create `lib/infrastructure/mappers/transaction_mapper.dart`
  - [ ] Implement `toDomain()` method
  - [ ] Implement `toDTO()` method
  - [ ] Write unit tests for mapper

- [ ] **Create Data Source**
  - [ ] Create `lib/infrastructure/data_sources/remote/firebase_transaction_data_source.dart`
  - [ ] Implement Firebase operations
  - [ ] Handle Firebase exceptions

- [ ] **Create Repository Implementation**
  - [ ] Create `lib/infrastructure/repositories/firebase_transaction_repository.dart`
  - [ ] Implement TransactionRepository interface
  - [ ] Use mapper to convert between DTO and Entity
  - [ ] Handle errors and map to domain exceptions
  - [ ] Write integration tests

### 🎨 Application Layer

- [ ] **Update Transaction Notifier**
  - [ ] Refactor `lib/application/notifiers/transaction_notifier.dart`
  - [ ] Replace service calls with use case calls
  - [ ] Inject use cases via constructor
  - [ ] Update state management logic
  - [ ] Write unit tests with mocked use cases

### 🖼️ Presentation Layer

- [ ] **Reorganize Screens**
  - [ ] Move screens to `lib/presentation/screens/transactions/`
  - [ ] Update imports
  - [ ] Verify screens work with updated notifier

- [ ] **Update Widgets**
  - [ ] Move widgets to `lib/presentation/widgets/transactions/`
  - [ ] Update imports

### 🔌 Dependency Injection

- [ ] **Register Transaction Dependencies**
  - [ ] Register FirebaseFirestore instance
  - [ ] Register TransactionRepository
  - [ ] Register all transaction use cases
  - [ ] Register TransactionNotifier as factory

### ✅ Testing & Validation

- [ ] **Run Tests**
  - [ ] Run all unit tests: `flutter test`
  - [ ] Verify all tests pass
  - [ ] Check test coverage

- [ ] **Manual Testing**
  - [ ] Test create transaction flow
  - [ ] Test view transactions flow
  - [ ] Test update transaction flow
  - [ ] Test delete transaction flow
  - [ ] Verify UI updates correctly

- [ ] **Code Review**
  - [ ] Review code with team
  - [ ] Address feedback
  - [ ] Update documentation if needed

---

## Phase 3: Migrate Balance Feature

### 🎯 Domain Layer

- [ ] **Create Balance Entity**
  - [ ] Create `lib/domain/entities/balance.dart`
  - [ ] Define business rules
  - [ ] Write unit tests

- [ ] **Create Repository Interface**
  - [ ] Create `lib/domain/repositories/balance_repository.dart`
  - [ ] Define abstract methods

- [ ] **Create Use Cases**
  - [ ] Create `get_balances_use_case.dart`
  - [ ] Create `update_balance_use_case.dart`
  - [ ] Write unit tests

### 🏗️ Infrastructure Layer

- [ ] **Create DTO**
  - [ ] Create `lib/infrastructure/dtos/balance_dto.dart`

- [ ] **Create Mapper**
  - [ ] Create `lib/infrastructure/mappers/balance_mapper.dart`

- [ ] **Create Repository Implementation**
  - [ ] Create `lib/infrastructure/repositories/firebase_balance_repository.dart`
  - [ ] Write integration tests

### 🎨 Application Layer

- [ ] **Update Balance Notifier**
  - [ ] Refactor to use use cases
  - [ ] Write unit tests

### 🔌 Dependency Injection

- [ ] **Register Balance Dependencies**
  - [ ] Register BalanceRepository
  - [ ] Register balance use cases
  - [ ] Register BalanceNotifier

### ✅ Testing & Validation

- [ ] Run all tests
- [ ] Manual testing
- [ ] Code review

---

## Phase 4: Migrate Authentication Feature

### 🎯 Domain Layer

- [ ] **Create User Entity**
  - [ ] Create `lib/domain/entities/user.dart`
  - [ ] Define business rules
  - [ ] Write unit tests

- [ ] **Create Repository Interface**
  - [ ] Create `lib/domain/repositories/auth_repository.dart`
  - [ ] Define abstract methods

- [ ] **Create Use Cases**
  - [ ] Create `login_use_case.dart`
  - [ ] Create `logout_use_case.dart`
  - [ ] Create `register_use_case.dart`
  - [ ] Create `reset_password_use_case.dart`
  - [ ] Write unit tests

### 🏗️ Infrastructure Layer

- [ ] **Create DTO**
  - [ ] Create `lib/infrastructure/dtos/user_dto.dart`

- [ ] **Create Mapper**
  - [ ] Create `lib/infrastructure/mappers/user_mapper.dart`

- [ ] **Create Data Source**
  - [ ] Create `lib/infrastructure/data_sources/remote/firebase_auth_data_source.dart`

- [ ] **Create Repository Implementation**
  - [ ] Create `lib/infrastructure/repositories/firebase_auth_repository.dart`
  - [ ] Write integration tests

### 🎨 Application Layer

- [ ] **Update Auth Notifier**
  - [ ] Refactor to use use cases
  - [ ] Write unit tests

### 🖼️ Presentation Layer

- [ ] **Reorganize Authentication Screens**
  - [ ] Move to `lib/presentation/screens/authentication/`
  - [ ] Update imports

### 🔌 Dependency Injection

- [ ] **Register Auth Dependencies**
  - [ ] Register AuthRepository
  - [ ] Register auth use cases
  - [ ] Register AuthNotifier

### ✅ Testing & Validation

- [ ] Run all tests
- [ ] Manual testing (login, logout, register)
- [ ] Code review

---

## Phase 5: Migrate Profile Feature

### 🎯 Domain Layer

- [ ] **Create UserProfile Entity**
  - [ ] Create `lib/domain/entities/user_profile.dart`
  - [ ] Write unit tests

- [ ] **Create Repository Interface**
  - [ ] Create `lib/domain/repositories/user_repository.dart`

- [ ] **Create Use Cases**
  - [ ] Create `get_user_profile_use_case.dart`
  - [ ] Create `update_profile_picture_use_case.dart`
  - [ ] Write unit tests

### 🏗️ Infrastructure Layer

- [ ] **Create DTO**
  - [ ] Create `lib/infrastructure/dtos/user_profile_dto.dart`

- [ ] **Create Mapper**
  - [ ] Create `lib/infrastructure/mappers/user_profile_mapper.dart`

- [ ] **Create Repository Implementation**
  - [ ] Create `lib/infrastructure/repositories/firebase_user_repository.dart`
  - [ ] Write integration tests

### 🎨 Application Layer

- [ ] **Update Profile Notifier**
  - [ ] Refactor to use use cases
  - [ ] Write unit tests

### 🖼️ Presentation Layer

- [ ] **Reorganize Profile Screens**
  - [ ] Move to `lib/presentation/screens/profile/`
  - [ ] Update imports

### 🔌 Dependency Injection

- [ ] **Register Profile Dependencies**
  - [ ] Register UserRepository
  - [ ] Register profile use cases
  - [ ] Register ProfileNotifier

### ✅ Testing & Validation

- [ ] Run all tests
- [ ] Manual testing
- [ ] Code review

---

## Phase 6: Migrate Investment Feature

### 🎯 Domain Layer

- [ ] **Create Investment Entity**
  - [ ] Create `lib/domain/entities/investment.dart`
  - [ ] Write unit tests

- [ ] **Create Repository Interface**
  - [ ] Create `lib/domain/repositories/investment_repository.dart`

- [ ] **Create Use Cases**
  - [ ] Create `create_investment_use_case.dart`
  - [ ] Create `get_investments_use_case.dart`
  - [ ] Write unit tests

### 🏗️ Infrastructure Layer

- [ ] **Create DTO**
  - [ ] Create `lib/infrastructure/dtos/investment_dto.dart`

- [ ] **Create Mapper**
  - [ ] Create `lib/infrastructure/mappers/investment_mapper.dart`

- [ ] **Create Repository Implementation**
  - [ ] Create `lib/infrastructure/repositories/firebase_investment_repository.dart`
  - [ ] Write integration tests

### 🎨 Application Layer

- [ ] **Update Investment Notifier**
  - [ ] Refactor to use use cases
  - [ ] Write unit tests

### 🖼️ Presentation Layer

- [ ] **Reorganize Investment Screens**
  - [ ] Move to `lib/presentation/screens/investments/`
  - [ ] Update imports

### 🔌 Dependency Injection

- [ ] **Register Investment Dependencies**
  - [ ] Register InvestmentRepository
  - [ ] Register investment use cases
  - [ ] Register InvestmentNotifier

### ✅ Testing & Validation

- [ ] Run all tests
- [ ] Manual testing
- [ ] Code review

---

## Phase 7: Migrate Dashboard Feature

### 🎯 Domain Layer

- [ ] **Review Existing Entities**
  - [ ] Ensure dashboard uses existing entities (Balance, Transaction)

- [ ] **Create Dashboard Use Cases (if needed)**
  - [ ] Create `get_dashboard_data_use_case.dart` (combines multiple entities)
  - [ ] Write unit tests

### 🎨 Application Layer

- [ ] **Update Dashboard Notifier**
  - [ ] Refactor to use use cases
  - [ ] Write unit tests

### 🖼️ Presentation Layer

- [ ] **Reorganize Dashboard Screen**
  - [ ] Move to `lib/presentation/screens/dashboard/`
  - [ ] Move widgets to `lib/presentation/widgets/dashboard/`
  - [ ] Update imports

### 🔌 Dependency Injection

- [ ] **Register Dashboard Dependencies**
  - [ ] Register dashboard use cases (if any)
  - [ ] Register DashboardNotifier

### ✅ Testing & Validation

- [ ] Run all tests
- [ ] Manual testing
- [ ] Code review

---

## Phase 8: Cleanup and Optimization

### 🧹 Remove Old Code

- [ ] **Delete Old Feature Folders**
  - [ ] Delete `lib/features/` folder (after verifying everything works)
  - [ ] Verify no broken imports

- [ ] **Consolidate Core**
  - [ ] Move remaining `lib/core/` items to appropriate layers
  - [ ] Update imports

### 📊 Update Documentation

- [ ] **Update README**
  - [ ] Document new folder structure
  - [ ] Update architecture section
  - [ ] Add migration notes

- [ ] **Update Code Comments**
  - [ ] Add comments to complex use cases
  - [ ] Document business rules in entities
  - [ ] Add repository interface documentation

### 🧪 Comprehensive Testing

- [ ] **Run Full Test Suite**
  - [ ] Unit tests: `flutter test`
  - [ ] Integration tests
  - [ ] Widget tests
  - [ ] Check test coverage (aim for >80%)

- [ ] **Manual Testing**
  - [ ] Test all user flows
  - [ ] Test error scenarios
  - [ ] Test edge cases

### 🚀 Performance Testing

- [ ] **Profile App Performance**
  - [ ] Check app startup time
  - [ ] Verify no memory leaks
  - [ ] Test with large datasets

### 📝 Code Review

- [ ] **Team Review**
  - [ ] Conduct final code review
  - [ ] Address all feedback
  - [ ] Ensure consistent coding style

---

## Phase 9: Deployment Preparation

### ✅ Pre-Deployment Checklist

- [ ] **Verify All Tests Pass**
  - [ ] Run: `flutter test`
  - [ ] Check for warnings
  - [ ] Verify coverage

- [ ] **Lint and Format**
  - [ ] Run: `flutter analyze`
  - [ ] Run: `dart format lib/`
  - [ ] Fix any issues

- [ ] **Build Verification**
  - [ ] Build Android: `flutter build apk`
  - [ ] Build iOS: `flutter build ios` (if applicable)
  - [ ] Test builds on devices

- [ ] **Update Version**
  - [ ] Bump version in `pubspec.yaml`
  - [ ] Update changelog

### 🚀 Deployment

- [ ] **Merge to Main**
  - [ ] Create pull request
  - [ ] Get approval from team
  - [ ] Merge to main branch

- [ ] **Tag Release**
  - [ ] Create git tag: `git tag -a v2.0.0 -m "Hexagonal architecture migration"`
  - [ ] Push tag: `git push origin v2.0.0`

- [ ] **Deploy to Staging**
  - [ ] Test in staging environment
  - [ ] Verify all features work

- [ ] **Deploy to Production**
  - [ ] Monitor for errors
  - [ ] Be ready to rollback if needed

### 📈 Post-Deployment

- [ ] **Monitor Application**
  - [ ] Check error logs
  - [ ] Monitor performance metrics
  - [ ] Gather user feedback

- [ ] **Document Lessons Learned**
  - [ ] What went well?
  - [ ] What could be improved?
  - [ ] Update migration guide

---

## Success Metrics

### ✅ Migration is Complete When:

- [ ] All features are working as before
- [ ] No regressions in functionality
- [ ] All tests pass (unit, integration, widget)
- [ ] Test coverage is maintained or improved (>80%)
- [ ] Code is well-documented
- [ ] Team understands new architecture
- [ ] App performance is same or better
- [ ] No critical bugs in production

### 📊 Quality Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Test Coverage | >80% | ⬜ |
| Code Duplication | <5% | ⬜ |
| Cyclomatic Complexity | <10 per function | ⬜ |
| Build Time | <3 minutes | ⬜ |
| App Size | <50MB | ⬜ |
| Startup Time | <2 seconds | ⬜ |

---

## Troubleshooting

### Common Issues

**Issue:** Circular dependencies
- **Solution:** Review dependency direction; ensure domain doesn't depend on infrastructure

**Issue:** Tests failing after migration
- **Solution:** Update test mocks to match new interfaces; use GetIt for DI in tests

**Issue:** Missing imports after moving files
- **Solution:** Use IDE refactoring tools; run `flutter pub get`; fix imports systematically

**Issue:** Provider not finding notifiers
- **Solution:** Register notifiers in injection_container.dart; use GetIt instead of Provider

**Issue:** Firebase errors
- **Solution:** Verify repository implementations; check DTO mappings; ensure Firebase is initialized

---

## Resources

### Documentation
- [hexagonal_architecture_analysis.md](./hexagonal_architecture_analysis.md)
- [hexagonal_architecture_diagrams.md](./hexagonal_architecture_diagrams.md)

### External Resources
- [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Tutorial](https://resocoder.com/flutter-clean-architecture-tdd/)

### Tools
- [get_it](https://pub.dev/packages/get_it) - Dependency Injection
- [mockito](https://pub.dev/packages/mockito) - Mocking for tests
- [fake_cloud_firestore](https://pub.dev/packages/fake_cloud_firestore) - Firebase mocking

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-10  
**Status:** Active Migration Checklist
