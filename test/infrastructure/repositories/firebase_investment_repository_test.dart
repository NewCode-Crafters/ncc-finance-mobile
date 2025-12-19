import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/infrastructure/repositories/firebase_investment_repository.dart';
import 'package:bytebank/domain/entities/investment.dart';

void main() {
  test('create/get/delete investment flows', () async {
    final fakeFs = FakeFirebaseFirestore();
    final repo = FirebaseInvestmentRepository(firestore: fakeFs);

    final investment = Investment(
      id: '',
      name: 'Test Inv',
      amount: 100.0,
      category: 'Stocks',
      type: 'Long',
      investedAt: DateTime.utc(2024, 1, 1),
      balanceId: 'b1',
    );

    // Create a balance document so the repository can verify sufficient funds
    await fakeFs
        .collection('users')
        .doc('u1')
        .collection('balances')
        .doc('b1')
        .set({'amount': 1000.0, 'accountType': 'checking', 'currency': 'BRL'});

    final created = await repo.createInvestment(
      userId: 'u1',
      investment: investment,
    );
    expect(created.id, isNotEmpty);

    final fetched = await repo.getInvestmentById(
      userId: 'u1',
      investmentId: created.id,
    );
    expect(fetched.name, 'Test Inv');

    final list = await repo.getInvestments(userId: 'u1');
    expect(list.length, 1);

    await repo.deleteInvestment(userId: 'u1', investmentId: created.id);
    final listAfter = await repo.getInvestments(userId: 'u1');
    expect(listAfter, isEmpty);
  });
}
