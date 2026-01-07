import 'dart:async';
import 'package:bytebank/core/services/i_connectivity_service.dart';

/// Fake connectivity service for testing.
///
/// Allows manual control of connectivity status via [setConnected].
class FakeConnectivityService implements IConnectivityService {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _currentStatus = true; // Default to connected

  FakeConnectivityService({bool initialStatus = true}) {
    _currentStatus = initialStatus;
    // Emit initial status after a microtask (simulates async behavior)
    Future.microtask(() => _controller.add(_currentStatus));
  }

  @override
  Stream<bool> get isConnected => _controller.stream;

  @override
  bool? get currentStatus => _currentStatus;

  /// Manually sets connectivity status (for testing).
  void setConnected(bool isConnected) {
    if (_currentStatus != isConnected) {
      _currentStatus = isConnected;
      _controller.add(isConnected);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
