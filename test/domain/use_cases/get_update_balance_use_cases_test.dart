import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/balance.dart';
import 'package:bytebank/domain/repositories/balance_repository.dart';
import 'package:bytebank/domain/use_cases/balances/get_balances_use_case.dart';
import 'package:bytebank/domain/use_cases/balances/update_balance_use_case.dart';

class _FakeRepo implements IBalanceRepository {
  final Map<String, Balance> store = {};

  @override
  Future<Balance> createBalance({required String userId, required Balance balance}) async {
    store[balance.id] = balance;
    return balance;
  }

  @override
  Future<List<Balance>> getBalances({required String userId}) async {
    return store.values.toList();
  }

  @override
  Future<Balance> getBalanceById({required String userId, required String balanceId}) async {
    return store[balanceId]!;
  }

  @override
  Stream<List<Balance>> listenBalances({required String userId}) => Stream.value(store.values.toList());

  @override
  Future<void> updateBalanceByDelta({required String userId, required String balanceId, required double delta, Object? batch}) async {
    final b = store[balanceId]!;
    store[balanceId] = b.copyWith(amount: b.amount + delta, updatedAt: DateTime.now());
  }

  @override
  Future<Balance> updateBalance({required String userId, required Balance balance}) async {
    store[balance.id] = balance;
    return balance;
  }
}

void main() {
  group('Balance use-cases', () {
    late _FakeRepo repo;
    late GetBalancesUseCase getUseCase;
    late UpdateBalanceUseCase updateUseCase;

    setUp(() {
      repo = _FakeRepo();
      final now = DateTime.now();
      repo.store['b1'] = Balance(id: 'b1', accountId: 'acc', accountType: 'checking', amount: 100.0, currency: 'BRL', updatedAt: now);
      getUseCase = GetBalancesUseCase(repo);
      updateUseCase = UpdateBalanceUseCase(repo);
    });

    test('get balances returns stored balances', () async {
      final list = await getUseCase.call(userId: 'u1');
      expect(list.length, 1);
      expect(list.first.id, 'b1');
    });

    test('update balance by delta changes amount', () async {
      await updateUseCase.call(userId: 'u1', balanceId: 'b1', delta: -20.0, batch: null);
      final list = await getUseCase.call(userId: 'u1');
      expect(list.first.amount, 80.0);
    });
  });
}
