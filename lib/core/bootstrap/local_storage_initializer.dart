import 'package:hive_flutter/hive_flutter.dart';

/// Initializer for local storage (Hive) setup.
///
/// Call [initialize] early in the app lifecycle (before runApp).
class LocalStorageInitializer {
  static bool _initialized = false;

  /// Initialize Hive for Flutter.
  ///
  /// This must be called before accessing any Hive boxes.
  /// Safe to call multiple times (idempotent).
  static Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _initialized = true;
  }

  /// Check if Hive has been initialized.
  static bool get isInitialized => _initialized;
}
