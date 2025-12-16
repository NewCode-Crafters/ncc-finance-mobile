import 'package:bytebank/domain/entities/financial_transaction_entity.dart';
import 'package:bytebank/domain/repositories/i_financial_transaction_repository.dart';

class UpdateTransactionUseCase {
  final IFinancialTransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<FinancialTransactionEntity> call(
    FinancialTransactionEntity transaction,
  ) async {
    // Business rules (e.g., only allow certain fields to change) can be enforced here.
    return repository.updateTransaction(transaction);
  }
}
