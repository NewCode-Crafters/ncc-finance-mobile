import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// App services and notifiers
import 'package:bytebank/features/authentication/services/firebase_auth_service.dart';
import 'package:bytebank/features/authentication/services/auth_service.dart';
import 'package:bytebank/infrastructure/repositories/firebase_user_repository.dart';
import 'package:bytebank/domain/repositories/user_repository.dart';
import 'package:bytebank/domain/use_cases/profile/get_user_profile_use_case.dart';
import 'package:bytebank/domain/use_cases/profile/upload_profile_picture_use_case.dart';
import 'package:bytebank/domain/use_cases/profile/pick_and_upload_profile_picture_use_case.dart';
import 'package:bytebank/features/dashboard/services/balance_service.dart';
import 'package:bytebank/domain/repositories/balance_repository.dart';
import 'package:bytebank/core/services/metadata_service.dart';
import 'package:bytebank/domain/repositories/i_financial_transaction_repository.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_data_source.dart';
import 'package:bytebank/infrastructure/repositories/firebase_transaction_repository.dart';
import 'package:bytebank/infrastructure/mappers/financial_transaction_mapper.dart';
import 'package:bytebank/infrastructure/repositories/firebase_balance_repository.dart';
import 'package:bytebank/infrastructure/mappers/balance_mapper.dart';
import 'package:bytebank/domain/use_cases/balances/get_balances_use_case.dart';
import 'package:bytebank/domain/use_cases/balances/update_balance_use_case.dart';
import 'package:bytebank/application/notifiers/balance_notifier.dart'
    as app_balance;
import 'package:bytebank/domain/use_cases/transactions/get_transactions_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/create_transaction_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/update_transaction_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/delete_transaction_use_case.dart';
import 'package:bytebank/application/notifiers/transaction_notifier.dart'
    as app_notifier;
import 'package:bytebank/infrastructure/repositories/firebase_investment_repository.dart';
import 'package:bytebank/domain/use_cases/investments/get_investments_use_case.dart';
import 'package:bytebank/domain/use_cases/investments/create_investment_use_case.dart';
import 'package:bytebank/domain/use_cases/investments/delete_investment_use_case.dart';
import 'package:bytebank/application/notifiers/investment_notifier.dart'
    as app_investment;

import 'package:bytebank/features/authentication/notifiers/auth_notifier.dart';
import 'package:bytebank/features/profile/notifiers/profile_notifier.dart';
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
  sl.registerLazySingleton<BalanceService>(() => BalanceService());

  sl.registerLazySingleton<MetadataService>(() => MetadataService());

  // -- Transaction infrastructure
  sl.registerLazySingleton<FirebaseTransactionDataSource>(
    () => FirebaseTransactionDataSource(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<FirebaseTransactionRepository>(
    () => FirebaseTransactionRepository(
      dataSource: sl<FirebaseTransactionDataSource>(),
      mapper: sl<FinancialTransactionMapper>(),
      currentUserId: null,
    ),
  );

  sl.registerLazySingleton<IFinancialTransactionRepository>(
    () => sl<FirebaseTransactionRepository>(),
  );

  sl.registerLazySingleton<FinancialTransactionMapper>(
    () => const FinancialTransactionMapper(),
  );

  // -- Balance infrastructure & mappers
  sl.registerLazySingleton<BalanceMapper>(() => BalanceMapper());

  // -- Domain use-cases for transactions
  sl.registerLazySingleton<GetTransactionsUseCase>(
    () => GetTransactionsUseCase(sl<IFinancialTransactionRepository>()),
  );
  sl.registerLazySingleton<CreateTransactionUseCase>(
    () => CreateTransactionUseCase(sl<IFinancialTransactionRepository>()),
  );
  sl.registerLazySingleton<UpdateTransactionUseCase>(
    () => UpdateTransactionUseCase(sl<IFinancialTransactionRepository>()),
  );
  sl.registerLazySingleton<DeleteTransactionUseCase>(
    () => DeleteTransactionUseCase(sl<IFinancialTransactionRepository>()),
  );

  // -- Notifiers (factories so each consumer gets a fresh instance)
  sl.registerFactory<AuthNotifier>(() => AuthNotifier(sl<AuthService>()));

  // Profile infra + use-cases
  // Register the IUserRepository interface to the concrete implementation
  sl.registerLazySingleton<IUserRepository>(
    () => FirebaseUserRepository(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(repository: sl<IUserRepository>()),
  );
  sl.registerLazySingleton<UploadProfilePictureUseCase>(
    () => UploadProfilePictureUseCase(repository: sl<IUserRepository>()),
  );
  sl.registerLazySingleton<PickAndUploadProfilePictureUseCase>(
    () => PickAndUploadProfilePictureUseCase(repository: sl<IUserRepository>()),
  );

  sl.registerFactory<ProfileNotifier>(
    () => ProfileNotifier(
      getUserProfile: sl<GetUserProfileUseCase>(),
      pickAndUploadProfilePicture: sl<PickAndUploadProfilePictureUseCase>(),
    ),
  );

  // Application-layer BalanceNotifier backed by domain use-cases
  sl.registerLazySingleton<FirebaseBalanceRepository>(
    () => FirebaseBalanceRepository(firestore: sl<FirebaseFirestore>()),
  );

  // Register the IBalanceRepository interface to the concrete implementation
  sl.registerLazySingleton<IBalanceRepository>(
    () => FirebaseBalanceRepository(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<GetBalancesUseCase>(
    () => GetBalancesUseCase(sl<FirebaseBalanceRepository>()),
  );
  sl.registerLazySingleton<UpdateBalanceUseCase>(
    () => UpdateBalanceUseCase(sl<FirebaseBalanceRepository>()),
  );

  sl.registerLazySingleton<app_balance.BalanceNotifier>(
    () => app_balance.BalanceNotifier(
      sl<GetBalancesUseCase>(),
      sl<UpdateBalanceUseCase>(),
    ),
  );

  sl.registerLazySingleton<FirebaseInvestmentRepository>(
    () => FirebaseInvestmentRepository(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<GetInvestmentsUseCase>(
    () => GetInvestmentsUseCase(repository: sl<FirebaseInvestmentRepository>()),
  );
  sl.registerLazySingleton<CreateInvestmentUseCase>(
    () =>
        CreateInvestmentUseCase(repository: sl<FirebaseInvestmentRepository>()),
  );
  sl.registerLazySingleton<DeleteInvestmentUseCase>(
    () =>
        DeleteInvestmentUseCase(repository: sl<FirebaseInvestmentRepository>()),
  );

  sl.registerFactory<app_investment.InvestmentNotifier>(
    () => app_investment.InvestmentNotifier(
      sl<GetInvestmentsUseCase>(),
      sl<CreateInvestmentUseCase>(),
      sl<DeleteInvestmentUseCase>(),
    ),
  );
  sl.registerFactory<ChartAnimationNotifier>(() => ChartAnimationNotifier());

  sl.registerFactory<app_notifier.TransactionNotifier>(
    () => app_notifier.TransactionNotifier(
      getUseCase: sl<GetTransactionsUseCase>(),
      createUseCase: sl<CreateTransactionUseCase>(),
      updateUseCase: sl<UpdateTransactionUseCase>(),
      deleteUseCase: sl<DeleteTransactionUseCase>(),
      metadataService: sl<MetadataService>(),
    ),
  );

  sl.registerFactory<TransactionAttachmentsNotifier>(
    () => TransactionAttachmentsNotifier(),
  );

  // -----------------------------------------------------------------------
  // Note: Keep registrations in the recommended order: external -> infra -> domain -> app -> presentation
  // Expand this function as you migrate features. For tests, consider registering test doubles.
}
