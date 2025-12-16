import 'package:bytebank/domain/entities/financial_transaction_entity.dart';
import 'package:bytebank/domain/repositories/i_financial_transaction_repository.dart';

class GetFinancialTransactionsUseCase {
  final IFinancialTransactionRepository repository;

  GetFinancialTransactionsUseCase(this.repository);

  Future<List<FinancialTransactionEntity>> call({
    int limit = 50,
    String? startAfterId,
    String? balanceId,
  }) async {
    return repository.getTransactions(
      limit: limit,
      startAfterId: startAfterId,
      balanceId: balanceId,
    );
  }
}
