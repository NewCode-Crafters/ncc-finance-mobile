import 'package:bytebank/application/notifiers/transaction_notifier.dart';
import 'package:bytebank/domain/entities/financial_transaction_entity.dart';
import 'package:bytebank/domain/use_cases/transactions/create_transaction_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/get_transactions_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/delete_transaction_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/update_transaction_use_case.dart';
import 'package:bytebank/domain/repositories/i_financial_transaction_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/core/services/metadata_service.dart';

class _FakeRepository implements IFinancialTransactionRepository {
  bool createCalled = false;
  bool getCalled = false;
  bool updateCalled = false;
  bool deleteCalled = false;

  @override
  Future<FinancialTransactionEntity> createTransaction(
    FinancialTransactionEntity transaction, {
    WriteBatch? batch,
  }) async {
    createCalled = true;
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    deleteCalled = true;
  }

  @override
  Future<FinancialTransactionEntity?> getTransaction(
    String transactionId,
  ) async {
    return null;
  }

  @override
  Stream<List<FinancialTransactionEntity>> watchTransactions({
    String? balanceId,
  }) {
    return Stream.value([]);
  }

  @override
  Future<List<FinancialTransactionEntity>> getTransactions({
    int limit = 50,
    String? startAfterId,
    String? balanceId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    getCalled = true;
    return <FinancialTransactionEntity>[];
  }

  @override
  Future<FinancialTransactionEntity> updateTransaction(
    FinancialTransactionEntity transaction,
  ) async {
    updateCalled = true;
    return transaction;
  }
}

void main() {
  test('loadTransactions calls getUseCase and updates state', () async {
    final fakeRepo = _FakeRepository();
    final create = CreateTransactionUseCase(fakeRepo);
    final get = GetTransactionsUseCase(fakeRepo);
    final update = UpdateTransactionUseCase(fakeRepo);
    final delete = DeleteTransactionUseCase(fakeRepo);

    final notifier = TransactionNotifier(
      getUseCase: get,
      createUseCase: create,
      updateUseCase: update,
      deleteUseCase: delete,
      metadataService: _FakeMetadata(),
    );

    await notifier.loadTransactions(limit: 10);
    expect(fakeRepo.getCalled, isTrue);
    expect(notifier.state.isLoading, isFalse);
  });
}

class _FakeMetadata implements MetadataService {
  @override
  Future<List<TransactionCategory>> getTransactionCategories() async => [];

  // Constructor satisfies MetadataService signature but we don't need firestore here.
  _FakeMetadata();
}
