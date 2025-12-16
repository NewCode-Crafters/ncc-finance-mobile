import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/infrastructure/dtos/financial_transaction_dto.dart';
import 'package:bytebank/infrastructure/mappers/financial_transaction_mapper.dart';

void main() {
  final mapper = FinancialTransactionMapper();

  test('DTO -> Domain and Domain -> DTO', () {
    final dto = FinancialTransactionDTO(
      id: 'tx1',
      amount: 200.0,
      balanceId: 'b1',
      category: 'cat',
      date: DateTime(2025, 2, 2),
      description: 'd',
    );

    final domain = mapper.toDomain(dto);
    expect(domain.id, equals(dto.id));
    expect(domain.amount, equals(dto.amount));

    final backDto = mapper.toDTO(domain);
    expect(backDto.id, equals(dto.id));
    expect(backDto.amount, equals(dto.amount));
  });
}
