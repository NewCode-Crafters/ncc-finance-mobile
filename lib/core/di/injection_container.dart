import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // -----------------------------------------------------------------------
  // Example registrations (uncomment and replace with real implementations)
  // -----------------------------------------------------------------------
  // Domain repository interface -> Infrastructure implementation
  // sl.registerLazySingleton<TransactionRepository>(
  //   () => FirebaseTransactionRepository(sl<FirebaseFirestore>()),
  // );

  // Use cases
  // sl.registerLazySingleton<CreateTransactionUseCase>(
  //   () => CreateTransactionUseCase(sl<TransactionRepository>()),
  // );

  // Notifiers / Cubits / Blocs
  // Use registerFactory so a new instance is provided each time it's requested.
  // sl.registerFactory<TransactionNotifier>(
  //   () => TransactionNotifier(createTransactionUseCase: sl()),
  // );

  // -----------------------------------------------------------------------
  // Note: Keep registrations in the recommended order: external -> infra -> domain -> app -> presentation
  // Expand this function as you migrate features. For tests, consider registering test doubles.
}
