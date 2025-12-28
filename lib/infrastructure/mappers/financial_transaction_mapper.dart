import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/infrastructure/dtos/financial_transaction_dto.dart';

class FinancialTransactionMapper {
  const FinancialTransactionMapper();

  FinancialTransactionEntity toDomain(FinancialTransactionDTO dto) {
    return dto.toDomain();
  }

  FinancialTransactionDTO toDTO(FinancialTransactionEntity entity) {
    return FinancialTransactionDTO(
      id: entity.id,
      amount: entity.amount,
      balanceId: entity.balanceId,
      category: entity.category,
      date: entity.date,
      description: entity.description,
    );
  }
}
