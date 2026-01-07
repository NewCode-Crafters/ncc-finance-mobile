import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bytebank/core/services/i_connectivity_service.dart';

/// Connectivity service implementation using connectivity_plus.
///
/// Monitors network connectivity and provides a stream of online/offline status.
class ConnectivityService implements IConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _controller;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool? _currentStatus;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        _controller = StreamController<bool>.broadcast() {
    _initialize();
  }

  @override
  Stream<bool> get isConnected => _controller.stream;

  @override
  bool? get currentStatus => _currentStatus;

  /// Initializes connectivity monitoring.
  void _initialize() {
    // Check initial status
    _connectivity.checkConnectivity().then((result) {
      _updateStatus(result);
    }).catchError((_) {
      // If check fails, assume online (optimistic default)
      _updateStatus([ConnectivityResult.wifi]);
    });

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateStatus,
      onError: (_) {
        // On error, assume online
        _updateStatus([ConnectivityResult.wifi]);
      },
    );
  }

  /// Updates connectivity status based on ConnectivityResult.
  void _updateStatus(List<ConnectivityResult> results) {
    // Consider connected if any connection is available (wifi, mobile, ethernet)
    final isConnected = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);

    if (_currentStatus != isConnected) {
      _currentStatus = isConnected;
      _controller.add(isConnected);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
