import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/investment.dart';

void main() {
  test('Investment copyWith and equality', () {
    final now = DateTime.now();
    final inv = Investment(
      id: 'i1',
      name: 'Tesouro Direto',
      amount: 1000.0,
      category: 'FIXED_INCOME',
      type: 'TESOURO',
      investedAt: now,
      balanceId: 'b1',
    );

    final inv2 = inv.copyWith(amount: 2000.0);

    expect(inv2.amount, 2000.0);
    expect(inv.id, inv2.id);
    expect(inv == inv2, isFalse);

    final inv3 = inv.copyWith();
    expect(inv3, inv);
  });

  test('isPositive works', () {
    final inv = Investment(
      id: 'i2',
      name: 'Fund',
      amount: 500.0,
      category: 'VARIABLE_INCOME',
      type: 'FUND',
      investedAt: DateTime.now(),
      balanceId: 'b2',
    );

    expect(inv.isPositive, isTrue);
  });
}
