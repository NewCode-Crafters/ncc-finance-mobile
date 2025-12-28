import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/domain/repositories/financial_transaction_repository.dart';
import 'package:bytebank/domain/use_cases/financial_transactions/create_financial_transaction_use_case.dart';
import 'package:bytebank/domain/use_cases/financial_transactions/get_financial_transactions_use_case.dart';
import 'package:bytebank/domain/use_cases/financial_transactions/update_financial_transaction_use_case.dart';
import 'package:bytebank/domain/use_cases/financial_transactions/delete_financial_transaction_use_case.dart';

class _FakeRepo implements IFinancialTransactionRepository {
  final Map<String, FinancialTransactionEntity> _store = {};

  @override
  Future<FinancialTransactionEntity> createTransaction(
    FinancialTransactionEntity transaction, {
    WriteBatch? batch,
  }) async {
    _store[transaction.id] = transaction;
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    _store.remove(transactionId);
  }

  @override
  Future<FinancialTransactionEntity?> getTransaction(
    String transactionId,
  ) async {
    return _store[transactionId];
  }

  @override
  Future<List<FinancialTransactionEntity>> getTransactions({
    int limit = 50,
    String? startAfterId,
    String? balanceId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _store.values.toList();
  }

  @override
  Future<FinancialTransactionEntity> updateTransaction(
    FinancialTransactionEntity transaction,
  ) async {
    _store[transaction.id] = transaction;
    return transaction;
  }

  @override
  Stream<List<FinancialTransactionEntity>> watchTransactions({
    String? balanceId,
  }) {
    return Stream.value(_store.values.toList());
  }
}

void main() {
  group('FinancialTransaction Use Cases', () {
    final repo = _FakeRepo();
    final create = CreateFinancialTransactionUseCase(repo);
    final get = GetFinancialTransactionsUseCase(repo);
    final update = UpdateFinancialTransactionUseCase(repo);
    final delete = DeleteFinancialTransactionUseCase(repo);

    test('create/get/update/delete flow', () async {
      final tx = FinancialTransactionEntity(
        id: 'tx1',
        amount: 100.0,
        balanceId: 'b1',
        category: 'cat',
        date: DateTime(2025, 1, 1),
        description: 'desc',
      );

      final created = await create(tx);
      expect(created, equals(tx));

      final all = await get();
      expect(all.length, equals(1));

      final updated = await update(tx.copyWith(amount: 150.0));
      expect(updated.amount, equals(150.0));

      await delete('tx1');
      final allAfterDelete = await get();
      expect(allAfterDelete.isEmpty, isTrue);
    });
  });
}
