import 'package:bytebank/application/notifiers/balance_notifier.dart';
import 'package:bytebank/application/notifiers/profile_notifier.dart';

/// Bootstraps critical data after user authentication.
///
/// Executes ONE time per userId to pre-load balances and profile,
/// preventing redundant fetches during rebuilds or hot reloads.
class PostLoginDataBootstrapper {
  final BalanceNotifier _balanceNotifier;
  final ProfileNotifier _profileNotifier;

  String? _lastBootstrappedUserId;
  bool _isBootstrapping = false;

  PostLoginDataBootstrapper({
    required BalanceNotifier balanceNotifier,
    required ProfileNotifier profileNotifier,
  })  : _balanceNotifier = balanceNotifier,
        _profileNotifier = profileNotifier;

  /// Executes bootstrap for the given [userId].
  ///
  /// - Returns immediately if already bootstrapped for this userId
  /// - Returns immediately if currently bootstrapping (prevents race conditions)
  /// - Fetches balances and profile in parallel
  ///
  /// Safe to call multiple times - internally guards against duplicate execution.
  Future<void> run(String userId) async {
    // Guard: Already bootstrapped for this user
    if (_lastBootstrappedUserId == userId) {
      return;
    }

    // Guard: Currently bootstrapping (race condition protection)
    if (_isBootstrapping) {
      return;
    }

    _isBootstrapping = true;

    try {
      // Fetch critical data in parallel (uses Future.wait with eagerError: false
      // to ensure both futures complete even if one fails)
      await Future.wait<void>(
        [
          _balanceNotifier.fetchBalances(userId: userId),
          _profileNotifier.fetchUserProfile(userId: userId),
        ],
        eagerError: false,
      );
    } catch (e) {
      // Silently fail - individual notifiers handle their own errors
      // and update their states accordingly. We don't want to block
      // the UI if one fetch fails.
    } finally {
      // Mark as completed for this user regardless of errors
      // This prevents infinite retry loops
      _lastBootstrappedUserId = userId;
      _isBootstrapping = false;
    }
  }

  /// Clears the bootstrap cache (useful for logout or testing).
  void reset() {
    _lastBootstrappedUserId = null;
    _isBootstrapping = false;
  }

  /// Checks if bootstrap was already executed for the given userId.
  bool isBootstrappedFor(String userId) {
    return _lastBootstrappedUserId == userId;
  }

  /// Checks if bootstrap is currently in progress.
  bool get isBootstrapping => _isBootstrapping;
}
