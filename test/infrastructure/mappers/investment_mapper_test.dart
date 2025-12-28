import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/infrastructure/dtos/investment_dto.dart';
import 'package:bytebank/infrastructure/mappers/investment_mapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('InvestmentMapper to/from DTO', () {
    final now = Timestamp.fromDate(DateTime.now());
    final dto = InvestmentDTO(
      id: 'i1',
      name: 'Inv',
      amount: 1000.0,
      category: 'CAT',
      type: 'TYPE',
      investedAt: now,
      balanceId: 'b1',
    );

    final mapper = const InvestmentMapper();
    final domain = mapper.toDomain(dto);
    expect(domain.id, equals(dto.id));
    expect(domain.amount, equals(dto.amount));

    final back = mapper.toDTO(domain);
    expect(back.id, equals(dto.id));
    expect(back.amount, equals(dto.amount));
  });
}
