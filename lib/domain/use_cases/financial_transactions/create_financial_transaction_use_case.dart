import 'package:bytebank/domain/entities/financial_transaction_entity.dart';
import 'package:bytebank/domain/repositories/i_financial_transaction_repository.dart';

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
