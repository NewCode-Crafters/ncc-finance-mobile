import 'package:bytebank/domain/repositories/i_financial_transaction_repository.dart';

class DeleteTransactionUseCase {
  final IFinancialTransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<void> call(String transactionId) async {
    // Business rules (e.g., soft-delete vs hard-delete) can be applied here.
    return repository.deleteTransaction(transactionId);
  }
}
