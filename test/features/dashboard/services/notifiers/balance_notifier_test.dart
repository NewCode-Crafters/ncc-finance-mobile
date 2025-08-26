import 'package:flutter_application_1/features/dashboard/models/balance.dart';
import 'package:flutter_application_1/features/dashboard/notifiers/balance_notifier.dart';
import 'package:flutter_application_1/features/dashboard/services/balance_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'balance_notifier_test.mocks.dart';

@GenerateMocks([BalanceService])
void main() {
  late MockBalanceService mockBalanceService;
  late BalanceNotifier balanceNotifier;

  setUp(() {
    mockBalanceService = MockBalanceService();
    balanceNotifier = BalanceNotifier(mockBalanceService);
  });

  test(
    'fetchBalances should update state with balances and correct total',
    () async {
      final fakeBalances = [
        Balance(
          id: '1',
          accountType: 'CHECKING',
          amount: 1000.0,
          currency: 'BRL',
        ),
        Balance(
          id: '2',
          accountType: 'SAVINGS',
          amount: 250.50,
          currency: 'BRL',
        ),
      ];

      // Tell the mock service to return our fake list when asked.
      when(
        mockBalanceService.getBalances(userId: anyNamed('userId')),
      ).thenAnswer((_) async => fakeBalances);

      await balanceNotifier.fetchBalances(userId: 'test_user');

      expect(balanceNotifier.state.totalBalance, 1250.50);
      expect(balanceNotifier.state.balances.length, 2);
      expect(balanceNotifier.state.isLoading, isFalse);
    },
  );

  test(
    'fetchBalances should handle an empty list of balances correctly',
    () async {
      when(
        mockBalanceService.getBalances(userId: anyNamed('userId')),
      ).thenAnswer((_) async => []);

      await balanceNotifier.fetchBalances(userId: 'new_user');

      expect(balanceNotifier.state.totalBalance, 0.0);
      expect(balanceNotifier.state.balances, isEmpty);
      expect(balanceNotifier.state.isLoading, isFalse);
    },
  );
}
