/// Interface for connectivity monitoring service.
///
/// Provides a stream of connectivity status (online/offline).
/// Implementations should wrap platform-specific connectivity packages.
abstract class IConnectivityService {
  /// Stream that emits true when connected, false when disconnected.
  ///
  /// Emits immediately upon subscription with current status,
  /// then emits whenever connectivity changes.
  Stream<bool> get isConnected;

  /// Checks current connectivity status synchronously (if available).
  ///
  /// Returns null if status is not yet determined.
  bool? get currentStatus;

  /// Disposes resources (closes streams, cancels subscriptions).
  void dispose();
}
