/// Enum representing the status of an async operation.
///
/// Use this to track state transitions in notifiers:
/// - idle: Initial state, no operation in progress
/// - loading: Operation in progress
/// - success: Operation completed successfully
/// - error: Operation failed
enum AsyncStatus {
  idle,
  loading,
  success,
  error,
}

/// Extension methods for AsyncStatus.
extension AsyncStatusX on AsyncStatus {
  bool get isIdle => this == AsyncStatus.idle;
  bool get isLoading => this == AsyncStatus.loading;
  bool get isSuccess => this == AsyncStatus.success;
  bool get isError => this == AsyncStatus.error;
}
