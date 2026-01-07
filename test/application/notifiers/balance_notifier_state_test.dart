import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/application/notifiers/balance_notifier.dart';
import 'package:bytebank/application/core/async_status.dart';
import 'package:bytebank/domain/entities/balance.dart';
import 'package:bytebank/domain/repositories/balance_repository.dart';
import 'package:bytebank/domain/use_cases/balances/get_balances_use_case.dart';
import 'package:bytebank/domain/use_cases/balances/update_balance_use_case.dart';

void main() {
  group('BalanceNotifier State Transitions', () {
    late BalanceNotifier notifier;
    late _FakeGetBalancesUseCase fakeGetBalances;
    late _FakeUpdateBalanceUseCase fakeUpdateBalance;

    setUp(() {
      fakeGetBalances = _FakeGetBalancesUseCase();
      fakeUpdateBalance = _FakeUpdateBalanceUseCase();
      notifier = BalanceNotifier(fakeGetBalances, fakeUpdateBalance);
    });

    test('initial state is idle with empty balances', () {
      expect(notifier.state.status, equals(AsyncStatus.idle));
      expect(notifier.state.balances, isEmpty);
      expect(notifier.state.totalBalance, equals(0.0));
      expect(notifier.state.errorMessage, isNull);
    });

    test('fetchBalances transitions from idle -> loading -> success', () async {
      final states = <AsyncStatus>[];

      // Listen to state changes
      notifier.addListener(() {
        states.add(notifier.state.status);
      });

      // Setup fake data
      fakeGetBalances.mockBalances = [
        Balance(
          id: 'b1',
          accountId: 'acc1',
          accountType: 'savings',
          amount: 1000.0,
          updatedAt: DateTime.now(),
        ),
        Balance(
          id: 'b2',
          accountId: 'acc2',
          accountType: 'checking',
          amount: 500.0,
          updatedAt: DateTime.now(),
        ),
      ];

      // Execute
      await notifier.fetchBalances(userId: 'user1');

      // Verify state transitions: loading -> success
      expect(states, equals([AsyncStatus.loading, AsyncStatus.success]));

      // Verify final state
      expect(notifier.state.status, equals(AsyncStatus.success));
      expect(notifier.state.balances, hasLength(2));
      expect(notifier.state.totalBalance, equals(1500.0));
      expect(notifier.state.errorMessage, isNull);
    });

    test('fetchBalances transitions from idle -> loading -> error on failure',
        () async {
      final states = <AsyncStatus>[];

      notifier.addListener(() {
        states.add(notifier.state.status);
      });

      // Setup fake to throw error
      fakeGetBalances.shouldThrow = true;

      await notifier.fetchBalances(userId: 'user1');

      // Verify state transitions: loading -> error
      expect(states, equals([AsyncStatus.loading, AsyncStatus.error]));

      // Verify final state
      expect(notifier.state.status, equals(AsyncStatus.error));
      expect(notifier.state.balances, isEmpty);
      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.errorMessage, contains('Failed to fetch balances'));
    });

    test('fetchBalances does not trigger if already loading', () async {
      var callCount = 0;

      notifier.addListener(() {
        callCount++;
      });

      // Setup slow fetch
      fakeGetBalances.delayMs = 100;

      // Trigger first fetch (will be loading for 100ms)
      final future1 = notifier.fetchBalances(userId: 'user1');

      // Wait a bit to ensure it's loading
      await Future.delayed(const Duration(milliseconds: 10));

      // Trigger second fetch while first is loading
      await notifier.fetchBalances(userId: 'user1');

      // Wait for first to complete
      await future1;

      // Should only have 2 state changes (loading, success) from first fetch
      // Second fetch should be ignored
      expect(callCount, equals(2));
    });

    test('multiple successful fetches update state correctly', () async {
      // First fetch
      fakeGetBalances.mockBalances = [
        Balance(
          id: 'b1',
          accountId: 'acc1',
          amount: 1000.0,
          updatedAt: DateTime.now(),
        ),
      ];

      await notifier.fetchBalances(userId: 'user1');

      expect(notifier.state.balances, hasLength(1));
      expect(notifier.state.totalBalance, equals(1000.0));
      expect(notifier.state.status, equals(AsyncStatus.success));

      // Second fetch with different data
      fakeGetBalances.mockBalances = [
        Balance(
          id: 'b1',
          accountId: 'acc1',
          amount: 1500.0,
          updatedAt: DateTime.now(),
        ),
        Balance(
          id: 'b2',
          accountId: 'acc2',
          amount: 250.0,
          updatedAt: DateTime.now(),
        ),
      ];

      await notifier.fetchBalances(userId: 'user1');

      expect(notifier.state.balances, hasLength(2));
      expect(notifier.state.totalBalance, equals(1750.0));
      expect(notifier.state.status, equals(AsyncStatus.success));
    });

    test('state only notifies listeners when state changes', () async {
      var notifyCount = 0;

      notifier.addListener(() {
        notifyCount++;
      });

      fakeGetBalances.mockBalances = [
        Balance(
          id: 'b1',
          accountId: 'acc1',
          amount: 100.0,
          updatedAt: DateTime.now(),
        ),
      ];

      await notifier.fetchBalances(userId: 'user1');

      // Should notify exactly 2 times: loading, success
      expect(notifyCount, equals(2));
    });
  });
}

// Fake use cases for testing
class _FakeGetBalancesUseCase implements GetBalancesUseCase {
  List<Balance> mockBalances = [];
  bool shouldThrow = false;
  int delayMs = 0;

  @override
  IBalanceRepository get repository => throw UnimplementedError();

  @override
  Future<List<Balance>> call({required String userId}) async {
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    if (shouldThrow) {
      throw Exception('Simulated error');
    }

    return mockBalances;
  }
}

class _FakeUpdateBalanceUseCase implements UpdateBalanceUseCase {
  @override
  IBalanceRepository get repository => throw UnimplementedError();

  @override
  Future<void> call({
    required String userId,
    required String balanceId,
    required double delta,
    Object? batch,
  }) async {
    // No-op for these tests
  }
}
