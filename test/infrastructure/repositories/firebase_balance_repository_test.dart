import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/infrastructure/repositories/firebase_balance_repository.dart';

void main() {
  group('FirebaseBalanceRepository', () {
    late FakeFirebaseFirestore fakeFs;
    late FirebaseBalanceRepository repo;
    const userId = 'u1';

    setUp(() {
      fakeFs = FakeFirebaseFirestore();
      repo = FirebaseBalanceRepository(firestore: fakeFs);
    });

    test('getBalances returns created balances', () async {
      final doc = fakeFs
          .collection('users')
          .doc(userId)
          .collection('balances')
          .doc('b1');
      await doc.set({
        'accountType': 'checking',
        'amount': 200.0,
        'currency': 'BRL',
      });

      final list = await repo.getBalances(userId: userId);
      expect(list.length, 1);
      expect(list.first.amount, 200.0);
    });

    test('updateBalanceByDelta increments amount atomically', () async {
      final docRef = fakeFs
          .collection('users')
          .doc(userId)
          .collection('balances')
          .doc('b2');
      await docRef.set({
        'accountType': 'savings',
        'amount': 50.0,
        'currency': 'BRL',
      });

      await repo.updateBalanceByDelta(
        userId: userId,
        balanceId: 'b2',
        delta: 25.0,
      );
      final balances = await repo.getBalances(userId: userId);
      final b = balances.firstWhere((x) => x.id == 'b2');
      expect(b.amount, 75.0);
    });
  });
}
