import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/transaction_category.dart';

void main() {
  test('TransactionCategory equality', () {
    final a = const TransactionCategory(
      id: 'C1',
      label: 'Food',
      type: 'expense',
    );
    final b = const TransactionCategory(
      id: 'C1',
      label: 'Food',
      type: 'expense',
    );

    expect(a, equals(b));
    expect(a.label, 'Food');
  });
}
