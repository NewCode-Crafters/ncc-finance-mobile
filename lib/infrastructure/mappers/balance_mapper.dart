import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/domain/entities/balance.dart';
import 'package:bytebank/infrastructure/dtos/balance_dto.dart';

class BalanceMapper {
  static Balance toDomain(BalanceDTO dto) {
    final updatedAt = dto.updatedAt?.toDate() ?? DateTime.now();
    return Balance(
      id: dto.id,
      accountId: dto.id,
      accountType: dto.accountType,
      amount: dto.amount,
      currency: dto.currency,
      updatedAt: updatedAt,
    );
  }

  static BalanceDTO toDTO(Balance domain) {
    return BalanceDTO(
      id: domain.id,
      accountType: domain.accountType,
      amount: domain.amount,
      currency: domain.currency,
      updatedAt: Timestamp.fromDate(domain.updatedAt),
    );
  }
}
