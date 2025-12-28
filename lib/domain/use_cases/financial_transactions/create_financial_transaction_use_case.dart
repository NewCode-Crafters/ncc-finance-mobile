import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/domain/repositories/financial_transaction_repository.dart';

class CreateFinancialTransactionUseCase {
  final IFinancialTransactionRepository repository;

  CreateFinancialTransactionUseCase(this.repository);

  Future<FinancialTransactionEntity> call(
    FinancialTransactionEntity transaction,
  ) async {
    // Business rules could be applied here (validation, normalization, etc.)
    return repository.createTransaction(transaction);
  }
}
