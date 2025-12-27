import 'package:bytebank/domain/entities/balance.dart';
import 'package:bytebank/domain/repositories/balance_repository.dart';
import 'package:bytebank/application/notifiers/balance_notifier.dart';
import 'package:bytebank/domain/use_cases/balances/get_balances_use_case.dart';
import 'package:bytebank/domain/use_cases/balances/update_balance_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

// Small fakes that implement the use-cases directly so tests remain lightweight.
class _DummyBalanceRepository implements IBalanceRepository {
  @override
  Future<Balance> createBalance({
    required String userId,
    required Balance balance,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Balance> getBalanceById({
    required String userId,
    required String balanceId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Balance>> getBalances({required String userId}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Balance>> listenBalances({required String userId}) {
    throw UnimplementedError();
  }

  @override
  Future<Balance> updateBalance({
    required String userId,
    required Balance balance,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateBalanceByDelta({
    required String userId,
    required String balanceId,
    required double delta,
    Object? batch,
  }) {
    throw UnimplementedError();
  }
}

class _FakeGetBalancesUseCase extends GetBalancesUseCase {
  List<Balance> Function({required String userId})? _handler;

  _FakeGetBalancesUseCase()
    : super(
        // Provide a dummy repository implementation for the base class
        // This repository won't be called because we override `call`.
        _DummyBalanceRepository(),
      );

  void whenCall(List<Balance> Function({required String userId}) handler) {
    _handler = handler;
  }

  @override
  Future<List<Balance>> call({required String userId}) async {
    return _handler?.call(userId: userId) ?? [];
  }
}

class _FakeUpdateBalanceUseCase extends UpdateBalanceUseCase {
  bool called = false;
  _FakeUpdateBalanceUseCase() : super(_DummyBalanceRepository());

  @override
  Future<void> call({
    required String userId,
    required String balanceId,
    required double delta,
    Object? batch,
  }) async {
    called = true;
  }
}

void main() {
  late _FakeGetBalancesUseCase mockGet;
  late _FakeUpdateBalanceUseCase mockUpdate;
  late BalanceNotifier balanceNotifier;

  setUp(() {
    mockGet = _FakeGetBalancesUseCase();
    mockUpdate = _FakeUpdateBalanceUseCase();
    balanceNotifier = BalanceNotifier(mockGet, mockUpdate);
  });

  test('fetchBalances populates state and computes total', () async {
    final fakeBalances = [
      Balance(
        id: '1',
        accountId: 'acc_1',
        accountType: 'CHECKING',
        amount: 1000.0,
        currency: 'BRL',
        updatedAt: DateTime.now(),
      ),
      Balance(
        id: '2',
        accountId: 'acc_2',
        accountType: 'SAVINGS',
        amount: 250.50,
        currency: 'BRL',
        updatedAt: DateTime.now(),
      ),
    ];

    mockGet.whenCall(({required String userId}) => fakeBalances);

    await balanceNotifier.fetchBalances(userId: 'test_user');

    expect(balanceNotifier.state.totalBalance, 1250.50);
    expect(balanceNotifier.state.balances.length, 2);
    expect(balanceNotifier.state.isLoading, isFalse);
  });

  test('fetchBalances handles empty list', () async {
    mockGet.whenCall(({required String userId}) => []);

    await balanceNotifier.fetchBalances(userId: 'new_user');

    expect(balanceNotifier.state.totalBalance, 0.0);
    expect(balanceNotifier.state.balances, isEmpty);
    expect(balanceNotifier.state.isLoading, isFalse);
  });

  test('updateBalanceOnTransaction delegates to use-case', () async {
    await balanceNotifier.updateBalanceOnTransaction(
      userId: 'u1',
      balanceId: 'b1',
      transactionAmount: -5.0,
    );

    expect(mockUpdate.called, isTrue);
  });
}
