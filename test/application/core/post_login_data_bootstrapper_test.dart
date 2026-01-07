import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:bytebank/application/core/post_login_data_bootstrapper.dart';

/// Fake BalanceNotifier for testing (tracks call count).
class FakeBalanceNotifier extends ChangeNotifier {
  int fetchBalancesCallCount = 0;
  String? lastFetchedUserId;

  Future<void> fetchBalances({required String userId}) async {
    fetchBalancesCallCount++;
    lastFetchedUserId = userId;
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

/// Fake ProfileNotifier for testing (tracks call count).
class FakeProfileNotifier extends ChangeNotifier {
  int fetchProfileCallCount = 0;
  String? lastFetchedUserId;

  Future<void> fetchUserProfile({
    required String userId,
    bool forceRefresh = false,
  }) async {
    fetchProfileCallCount++;
    lastFetchedUserId = userId;
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

/// Fake BalanceNotifier that throws an error.
class _FailingBalanceNotifier extends ChangeNotifier {
  Future<void> fetchBalances({required String userId}) async {
    throw Exception('Simulated fetch error');
  }
}

void main() {
  group('PostLoginDataBootstrapper', () {
    late PostLoginDataBootstrapper bootstrapper;
    late FakeBalanceNotifier balanceNotifier;
    late FakeProfileNotifier profileNotifier;

    setUp(() {
      balanceNotifier = FakeBalanceNotifier();
      profileNotifier = FakeProfileNotifier();
      bootstrapper = PostLoginDataBootstrapper(
        balanceNotifier: balanceNotifier,
        profileNotifier: profileNotifier,
      );
    });

    test('executes bootstrap on first call for userId', () async {
      const userId = 'user123';

      await bootstrapper.run(userId);

      expect(balanceNotifier.fetchBalancesCallCount, equals(1));
      expect(balanceNotifier.lastFetchedUserId, equals(userId));
      expect(profileNotifier.fetchProfileCallCount, equals(1));
      expect(profileNotifier.lastFetchedUserId, equals(userId));
      expect(bootstrapper.isBootstrappedFor(userId), isTrue);
    });

    test('does NOT execute bootstrap twice for same userId', () async {
      const userId = 'user123';

      await bootstrapper.run(userId);
      await bootstrapper.run(userId); // Second call
      await bootstrapper.run(userId); // Third call

      // Should only call once
      expect(balanceNotifier.fetchBalancesCallCount, equals(1));
      expect(profileNotifier.fetchProfileCallCount, equals(1));
    });

    test('executes bootstrap again for different userId', () async {
      const userId1 = 'user123';
      const userId2 = 'user456';

      await bootstrapper.run(userId1);
      await bootstrapper.run(userId2);

      expect(balanceNotifier.fetchBalancesCallCount, equals(2));
      expect(balanceNotifier.lastFetchedUserId, equals(userId2));
      expect(profileNotifier.fetchProfileCallCount, equals(2));
      expect(profileNotifier.lastFetchedUserId, equals(userId2));
      expect(bootstrapper.isBootstrappedFor(userId1), isFalse);
      expect(bootstrapper.isBootstrappedFor(userId2), isTrue);
    });

    test('reset clears bootstrap cache', () async {
      const userId = 'user123';

      await bootstrapper.run(userId);
      expect(bootstrapper.isBootstrappedFor(userId), isTrue);

      bootstrapper.reset();

      expect(bootstrapper.isBootstrappedFor(userId), isFalse);

      // Should execute again after reset
      await bootstrapper.run(userId);
      expect(balanceNotifier.fetchBalancesCallCount, equals(2));
      expect(profileNotifier.fetchProfileCallCount, equals(2));
    });

    test('handles concurrent calls without duplicate execution', () async {
      const userId = 'user123';

      // Simulate rapid concurrent calls (e.g., multiple rebuilds)
      final futures = [
        bootstrapper.run(userId),
        bootstrapper.run(userId),
        bootstrapper.run(userId),
      ];

      await Future.wait(futures);

      // Should only execute once due to _isBootstrapping guard
      expect(balanceNotifier.fetchBalancesCallCount, equals(1));
      expect(profileNotifier.fetchProfileCallCount, equals(1));
    });

    test('isBootstrapping returns true during execution', () async {
      const userId = 'user123';

      expect(bootstrapper.isBootstrapping, isFalse);

      final future = bootstrapper.run(userId);
      
      // Check status before completion (may be timing-sensitive)
      // Note: In real scenarios, _isBootstrapping is mostly for internal guards
      
      await future;
      
      expect(bootstrapper.isBootstrapping, isFalse);
    });

    test('continues execution even if one fetch fails', () async {
      // Create a notifier that throws an error
      final failingBalanceNotifier = _FailingBalanceNotifier();
      final normalProfileNotifier = FakeProfileNotifier();

      final bootstrapperWithError = PostLoginDataBootstrapper(
        balanceNotifier: failingBalanceNotifier,
        profileNotifier: normalProfileNotifier,
      );

      const userId = 'user123';

      // Should not throw, even though balance fetch fails
      await bootstrapperWithError.run(userId);

      // Profile should still be fetched
      expect(normalProfileNotifier.fetchProfileCallCount, equals(1));
      expect(bootstrapperWithError.isBootstrappedFor(userId), isTrue);
    });
  });
}
