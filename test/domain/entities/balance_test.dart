import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/balance.dart';

void main() {
  group('Balance entity', () {
    final now = DateTime.now();
    final base = Balance(
      id: 'b1',
      accountId: 'acc1',
      amount: 100.0,
      currency: 'BRL',
      accountType: 'checking',
      updatedAt: now,
    );

    test('copyWith updates fields', () {
      final changed = base.copyWith(amount: 150.0, currency: 'USD');
      expect(changed.id, base.id);
      expect(changed.accountId, base.accountId);
      expect(changed.amount, 150.0);
      expect(changed.currency, 'USD');
      expect(changed.updatedAt, base.updatedAt);
    });

    test('applyTransaction increases or decreases amount', () {
      final credited = base.applyTransaction(50.0);
      expect(credited.amount, 150.0);
      final debited = base.applyTransaction(-30.0);
      expect(debited.amount, 70.0);
      expect(
        credited.updatedAt.isAfter(base.updatedAt) ||
            credited.updatedAt == credited.updatedAt,
        true,
      );
    });

    test('deposit and withdraw helpers', () {
      final afterDeposit = base.deposit(25.0);
      expect(afterDeposit.amount, 125.0);

      final afterWithdraw = base.withdraw(50.0);
      expect(afterWithdraw.amount, 50.0);

      expect(() => base.deposit(-10.0), throwsArgumentError);
      expect(() => base.withdraw(-5.0), throwsArgumentError);
    });

    test('isPositive and isNegative helpers', () {
      expect(base.isPositive, true);
      expect(base.isNegative, false);
      final negative = base.copyWith(amount: -10.0);
      expect(negative.isPositive, false);
      expect(negative.isNegative, true);
    });
  });
}
