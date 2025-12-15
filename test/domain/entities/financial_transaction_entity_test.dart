import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/financial_transaction_entity.dart';

void main() {
  test('FinancialTransactionEntity equality and copyWith', () {
    final t1 = FinancialTransactionEntity(
      id: '1',
      amount: 1000.0,
      balanceId: 'b1',
      category: 'income',
      date: DateTime(2025, 1, 1),
      description: 'Salary payment',
    );

    final t2 = t1.copyWith(amount: 1200.0);

    expect(t1.isIncome, isTrue);
    expect(t1.isExpense, isFalse);
    expect(t2.amount, equals(1200.0));
    expect(t1 == t2, isFalse);

    final t3 = t1.copyWith();
    expect(t3, equals(t1));
  });
}
