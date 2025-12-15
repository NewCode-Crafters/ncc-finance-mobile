import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// App services and notifiers
import 'package:bytebank/features/authentication/services/firebase_auth_service.dart';
import 'package:bytebank/features/authentication/services/auth_service.dart';
import 'package:bytebank/features/profile/services/profile_service.dart';
import 'package:bytebank/features/dashboard/services/balance_service.dart';
import 'package:bytebank/features/investments/services/investment_service.dart';
import 'package:bytebank/core/services/metadata_service.dart';
import 'package:bytebank/features/transactions/services/financial_transaction_service.dart';

import 'package:bytebank/features/authentication/notifiers/auth_notifier.dart';
import 'package:bytebank/features/profile/notifiers/profile_notifier.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/investments/notifiers/investment_notifier.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_notifier.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_attachments_notifier.dart';
import 'package:bytebank/core/notifiers/chart_animation_notifier.dart';

// This file contains the application's dependency injection container.
// Call `initializeDependencies()` early in `main()` before running the app.

final GetIt sl = GetIt.instance;

/// Initialize and register app-wide dependencies.
///
/// - Register external packages (Firebase, HTTP clients)
/// - Register repository implementations (infrastructure)
/// - Register domain use-cases
/// - Register notifiers / blocs as factories
Future<void> initializeDependencies() async {
  // -- External / third-party packages
  // Register a singleton of FirebaseFirestore so repositories can use it.
  // If you initialize Firebase in main(), use FirebaseFirestore.instance here.
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // -- Services (lazy singletons)
  sl.registerLazySingleton<AuthService>(() => FirebaseAuthService());
  sl.registerLazySingleton<ProfileService>(() => ProfileService());
  sl.registerLazySingleton<BalanceService>(() => BalanceService());
  sl.registerLazySingleton<InvestmentService>(() => InvestmentService());
  sl.registerLazySingleton<MetadataService>(() => MetadataService());
  sl.registerLazySingleton<FinancialTransactionService>(
    () => FinancialTransactionService(),
  );

  // -- Notifiers (factories so each consumer gets a fresh instance)
  sl.registerFactory<AuthNotifier>(() => AuthNotifier(sl<AuthService>()));
  sl.registerFactory<ProfileNotifier>(
    () => ProfileNotifier(sl<ProfileService>()),
  );
  sl.registerFactory<BalanceNotifier>(
    () => BalanceNotifier(sl<BalanceService>()),
  );
  sl.registerFactory<InvestmentNotifier>(
    () => InvestmentNotifier(sl<InvestmentService>()),
  );
  sl.registerFactory<ChartAnimationNotifier>(() => ChartAnimationNotifier());
  sl.registerFactory<TransactionNotifier>(
    () => TransactionNotifier(
      sl<FinancialTransactionService>(),
      sl<MetadataService>(),
    ),
  );
  sl.registerFactory<TransactionAttachmentsNotifier>(
    () => TransactionAttachmentsNotifier(),
  );

  // -----------------------------------------------------------------------
  // Note: Keep registrations in the recommended order: external -> infra -> domain -> app -> presentation
  // Expand this function as you migrate features. For tests, consider registering test doubles.
}
