import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_application_1/features/dashboard/services/balance_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BalanceService balanceService;
  const userId = 'test_user_id';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    balanceService = BalanceService(firestore: fakeFirestore);
  });

  test(
    'getBalances should return a list of balances for a given user',
    () async {
      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .add({
            'accountType': 'CHECKING_ACCOUNT',
            'amount': 1000.50,
            'currency': 'BRL',
          });

      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .add({
            'accountType': 'SAVINGS_ACCOUNT',
            'amount': 500.25,
            'currency': 'BRL',
          });

      final balances = await balanceService.getBalances(userId: userId);

      expect(balances.length, 2);
      expect(balances.first.amount, 1000.50);
      expect(balances.last.accountType, 'SAVINGS_ACCOUNT');
    },
  );

  test(
    'updateBalanceOnTransaction should correctly increment or decrement a balance',
    () async {
      final balanceDocRef = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .add({
            'accountType': 'CHECKING_ACCOUNT',
            'amount': 1000.0,
            'currency': 'BRL',
          });

      await balanceService.updateBalanceOnTransaction(
        userId: userId,
        balanceId: balanceDocRef.id,
        transactionAmount: -50.0,
      );

      final updatedBalanceDoc = await balanceDocRef.get();
      final updatedAmount = updatedBalanceDoc.data()?['amount'];

      // The new balance should be 1000.0 - 50.0 = 950.0
      expect(updatedAmount, 950.0);
    },
  );
}
