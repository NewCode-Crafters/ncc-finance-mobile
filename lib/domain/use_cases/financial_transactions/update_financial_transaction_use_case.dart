import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/domain/repositories/financial_transaction_repository.dart';

class UpdateFinancialTransactionUseCase {
  final IFinancialTransactionRepository repository;

  UpdateFinancialTransactionUseCase(this.repository);

  Future<FinancialTransactionEntity> call(
    FinancialTransactionEntity transaction,
  ) async {
    // Business rules (e.g., only allow certain fields to change) can be enforced here.
    return repository.updateTransaction(transaction);
  }
}
