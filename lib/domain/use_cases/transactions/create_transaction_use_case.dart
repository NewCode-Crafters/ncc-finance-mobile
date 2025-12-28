import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/domain/repositories/financial_transaction_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTransactionUseCase {
  final IFinancialTransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<FinancialTransactionEntity> call(
    FinancialTransactionEntity transaction, {
    WriteBatch? batch,
  }) async {
    // Business rules could be applied here (validation, normalization, etc.)
    // Forward optional Firestore batch to repository so balance updates can be
    // included in the same atomic write when needed.
    return repository.createTransaction(transaction, batch: batch);
  }
}
