import 'package:bytebank/domain/repositories/attachment_repository.dart';
import 'package:bytebank/domain/repositories/auth_repository.dart';
import 'package:bytebank/domain/use_cases/auth/login_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/logout_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/send_password_reset_email_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/signup_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/delete_attachment_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/upload_attachment_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/watch_attachments_use_case.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_auth_data_source.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_attachment_data_source.dart';
import 'package:bytebank/infrastructure/data_sources/local/hive_transaction_cache_data_source.dart';
import 'package:bytebank/infrastructure/repositories/firebase_attachment_repository.dart';
import 'package:bytebank/infrastructure/repositories/firebase_auth_repository.dart';
import 'package:bytebank/core/cache/cache_policy.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// App services and notifiers
import 'package:bytebank/infrastructure/repositories/firebase_user_repository.dart';
import 'package:bytebank/domain/repositories/user_repository.dart';
import 'package:bytebank/domain/use_cases/profile/get_user_profile_use_case.dart';
import 'package:bytebank/domain/use_cases/profile/upload_profile_picture_use_case.dart';
import 'package:bytebank/domain/use_cases/profile/pick_and_upload_profile_picture_use_case.dart';
import 'package:bytebank/domain/repositories/balance_repository.dart';
import 'package:bytebank/infrastructure/services/metadata_service.dart';
import 'package:bytebank/domain/repositories/financial_transaction_repository.dart';
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

import 'package:bytebank/application/notifiers/auth_notifier.dart';
import 'package:bytebank/application/notifiers/profile_notifier.dart';
import 'package:bytebank/application/notifiers/transaction_attachments_notifier.dart';
import 'package:bytebank/application/notifiers/chart_animation_notifier.dart';
import 'package:bytebank/core/security/i_secure_storage.dart';
import 'package:bytebank/infrastructure/services/secure_storage_service.dart';
import 'package:bytebank/application/core/post_login_data_bootstrapper.dart';
import 'package:bytebank/core/services/i_connectivity_service.dart';
import 'package:bytebank/infrastructure/services/connectivity_service.dart';

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

  // -- Secure Storage (Phase 1.1 - Tech Challenge Fase 04)
  // Register the secure storage service for sensitive data (tokens, pins, etc.)
  sl.registerLazySingleton<ISecureStorage>(() => SecureStorageService());

  // -- Connectivity Service (Phase 3.2 - Tech Challenge Fase 04)
  // Register connectivity service to monitor network status
  sl.registerLazySingleton<IConnectivityService>(() => ConnectivityService());

  // -- Authentication infra: data source and repository
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(
      firebaseAuth: null,
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<FirebaseAuthRepository>(
    () => FirebaseAuthRepository(sl<FirebaseAuthDataSource>()),
  );

  sl.registerLazySingleton<AuthRepository>(() => sl<FirebaseAuthRepository>());

  sl.registerLazySingleton<MetadataService>(() => MetadataService());

  // -- Cache infrastructure (Phase 2 - Tech Challenge Fase 04)
  // Register cache data source for local transactions storage
  sl.registerLazySingleton<HiveTransactionCacheDataSource>(
    () => HiveTransactionCacheDataSource()..initialize(),
  );

  // Register cache policy with default TTL (5 minutes)
  sl.registerLazySingleton<CachePolicy>(() => const CachePolicy());

  // -- Transaction infrastructure
  sl.registerLazySingleton<FirebaseTransactionDataSource>(
    () => FirebaseTransactionDataSource(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<FirebaseTransactionRepository>(
    () => FirebaseTransactionRepository(
      dataSource: sl<FirebaseTransactionDataSource>(),
      cacheDataSource: sl<HiveTransactionCacheDataSource>(),
      mapper: sl<FinancialTransactionMapper>(),
      cachePolicy: sl<CachePolicy>(),
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

  // -- Auth use-cases and Notifier
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SendPasswordResetEmailUseCase>(
    () => SendPasswordResetEmailUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );

  // Notifier factory that accepts use-cases
  sl.registerFactory<AuthNotifier>(
    () => AuthNotifier(
      login: sl<LoginUseCase>(),
      signUp: sl<SignUpUseCase>(),
      sendReset: sl<SendPasswordResetEmailUseCase>(),
      logout: sl<LogoutUseCase>(),
    ),
  );

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
    () => TransactionAttachmentsNotifier(
      uploadUseCase: sl<UploadAttachmentUseCase>(),
      deleteUseCase: sl<DeleteAttachmentUseCase>(),
      watchUseCase: sl<WatchAttachmentsUseCase>(),
    ),
  );

  // Attachment infra: data source, repository and use-cases
  sl.registerLazySingleton<FirebaseTransactionAttachmentDataSource>(
    () => FirebaseTransactionAttachmentDataSource(
      firestore: sl<FirebaseFirestore>(),
      storage: null,
    ),
  );

  sl.registerLazySingleton<FirebaseAttachmentRepository>(
    () => FirebaseAttachmentRepository(
      sl<FirebaseTransactionAttachmentDataSource>(),
    ),
  );

  sl.registerLazySingleton<AttachmentRepository>(
    () => sl<FirebaseAttachmentRepository>(),
  );

  sl.registerLazySingleton<UploadAttachmentUseCase>(
    () => UploadAttachmentUseCase(sl<AttachmentRepository>()),
  );
  sl.registerLazySingleton<DeleteAttachmentUseCase>(
    () => DeleteAttachmentUseCase(sl<AttachmentRepository>()),
  );
  sl.registerLazySingleton<WatchAttachmentsUseCase>(
    () => WatchAttachmentsUseCase(sl<AttachmentRepository>()),
  );

  // -- Post-login data bootstrapper (Phase 3.1 - Tech Challenge Fase 04)
  // Singleton bootstrapper to pre-load critical data after login
  sl.registerLazySingleton<PostLoginDataBootstrapper>(
    () => PostLoginDataBootstrapper(
      balanceNotifier: sl<app_balance.BalanceNotifier>(),
      profileNotifier: sl<ProfileNotifier>(),
    ),
  );

  // -----------------------------------------------------------------------
  // Note: Keep registrations in the recommended order: external -> infra -> domain -> app -> presentation
}
