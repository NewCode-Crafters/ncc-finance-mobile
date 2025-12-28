import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/infrastructure/dtos/balance_dto.dart';
import 'package:bytebank/infrastructure/mappers/balance_mapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('BalanceMapper converts DTO <-> Domain', () {
    final now = Timestamp.fromDate(DateTime.now());
    final dto = BalanceDTO(
      id: 'b1',
      accountType: 'checking',
      amount: 100.0,
      currency: 'BRL',
      updatedAt: now,
    );

    final domain = BalanceMapper.toDomain(dto);
    expect(domain.id, equals('b1'));
    expect(domain.amount, equals(100.0));

    final back = BalanceMapper.toDTO(domain);
    expect(back.id, equals(domain.id));
    expect(back.amount, equals(domain.amount));
  });
}
