import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/domain/entities/investment.dart';
import '../dtos/investment_dto.dart';

class InvestmentMapper {
  const InvestmentMapper();

  Investment toDomain(InvestmentDTO dto) {
    return dto.toDomain();
  }

  InvestmentDTO toDTO(Investment entity) {
    return InvestmentDTO(
      id: entity.id,
      name: entity.name,
      amount: entity.amount,
      category: entity.category,
      type: entity.type,
      investedAt: Timestamp.fromDate(entity.investedAt),
      balanceId: entity.balanceId,
    );
  }
}
