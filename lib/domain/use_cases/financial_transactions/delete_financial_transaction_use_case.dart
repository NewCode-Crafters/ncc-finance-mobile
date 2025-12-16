import 'package:bytebank/domain/repositories/i_financial_transaction_repository.dart';

class DeleteFinancialTransactionUseCase {
  final IFinancialTransactionRepository repository;

  DeleteFinancialTransactionUseCase(this.repository);

  Future<void> call(String transactionId) async {
    // Business rules (e.g., soft-delete vs hard-delete) can be applied here.
    return repository.deleteTransaction(transactionId);
  }
}
