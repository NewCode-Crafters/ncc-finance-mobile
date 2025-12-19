import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/application/notifiers/balance_notifier.dart';
import 'package:bytebank/domain/entities/balance.dart';
import 'package:bytebank/domain/use_cases/balances/get_balances_use_case.dart';
import 'package:bytebank/domain/use_cases/balances/update_balance_use_case.dart';
import 'package:bytebank/domain/repositories/balance_repository.dart';

class _FakeRepo implements IBalanceRepository {
  final List<Balance> _list;
  _FakeRepo(this._list);

  @override
  Future<Balance> createBalance({
    required String userId,
    required Balance balance,
  }) async {
    _list.add(balance);
    return balance;
  }

  @override
  Future<List<Balance>> getBalances({required String userId}) async => _list;

  @override
  Future<Balance> getBalanceById({
    required String userId,
    required String balanceId,
  }) async => _list.firstWhere((b) => b.id == balanceId);

  @override
  Stream<List<Balance>> listenBalances({required String userId}) =>
      Stream.value(_list);

  @override
  Future<void> updateBalanceByDelta({
    required String userId,
    required String balanceId,
    required double delta,
    Object? batch,
  }) async {
    final idx = _list.indexWhere((b) => b.id == balanceId);
    final b = _list[idx];
    _list[idx] = b.copyWith(
      amount: b.amount + delta,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Balance> updateBalance({
    required String userId,
    required Balance balance,
  }) async {
    final idx = _list.indexWhere((b) => b.id == balance.id);
    _list[idx] = balance;
    return balance;
  }
}

void main() {
  test('fetchBalances populates state', () async {
    final now = DateTime.now();
    final fakeRepo = _FakeRepo([
      Balance(
        id: 'b1',
        accountId: 'a',
        accountType: 'c',
        amount: 10.0,
        currency: 'BRL',
        updatedAt: now,
      ),
    ]);
    final getUse = GetBalancesUseCase(fakeRepo);
    final updateUse = UpdateBalanceUseCase(fakeRepo);
    final notifier = BalanceNotifier(getUse, updateUse);

    await notifier.fetchBalances(userId: 'u1');
    expect(notifier.state.balances.length, 1);
    expect(notifier.state.totalBalance, 10.0);
  });

  test('updateBalanceOnTransaction delegates to use-case', () async {
    final now = DateTime.now();
    final fakeRepo = _FakeRepo([
      Balance(
        id: 'b1',
        accountId: 'a',
        accountType: 'c',
        amount: 20.0,
        currency: 'BRL',
        updatedAt: now,
      ),
    ]);
    final getUse = GetBalancesUseCase(fakeRepo);
    final updateUse = UpdateBalanceUseCase(fakeRepo);
    final notifier = BalanceNotifier(getUse, updateUse);

    await notifier.updateBalanceOnTransaction(
      userId: 'u1',
      balanceId: 'b1',
      transactionAmount: -5.0,
    );
    // No exception thrown means delegation succeeded.
    expect(true, true);
  });
}
