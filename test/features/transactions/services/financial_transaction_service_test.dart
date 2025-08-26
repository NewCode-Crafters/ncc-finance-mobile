import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_application_1/features/dashboard/services/balance_service.dart';
import 'package:flutter_application_1/features/transactions/services/financial_transaction_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../dashboard/services/notifiers/balance_notifier_test.mocks.dart';

@GenerateMocks([BalanceService])
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockBalanceService mockBalanceService;
  late FinancialTransactionService transactionService;
  const userId = 'test_user_id';
  late String balanceId;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockBalanceService = MockBalanceService();
    transactionService = FinancialTransactionService(
      firestore: fakeFirestore,
      balanceService: mockBalanceService,
    );

    final balanceDoc = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('balances')
        .add({'amount': 1000.0});
    balanceId = balanceDoc.id;
  });

  test(
    'createTransaction should add a new document to the transactions sub-collection',
    () async {
      final transactionData = {
        'amount': -150.0,
        'balanceId': 'test_balance_id',
        'category': 'SHOPPING',
        'date': DateTime.now(),
        'description': 'New headphones',
      };

      await transactionService.createTransaction(
        userId: userId,
        data: transactionData,
      );

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['description'], 'New headphones');
      expect(snapshot.docs.first.data()['amount'], -150.0);
    },
  );

  test(
    'getTransactions should return a list of transactions ordered by date descending',
    () async {
      final now = DateTime.now();
      final transactionsCollection = fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('transactions');

      await transactionsCollection.add({
        'amount': -50.0,
        'date': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      });
      await transactionsCollection.add({
        'amount': -100.0,
        'date': Timestamp.fromDate(now),
      }); // Most recent
      await transactionsCollection.add({
        'amount': -25.0,
        'date': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      });

      final transactions = await transactionService.getTransactions(
        userId: userId,
      );

      expect(transactions.length, 3);
      // The first item in the list should be the one with the most recent date.
      expect(transactions.first.amount, -100.0);
      expect(transactions.last.amount, -50.0);
    },
  );

  test(
    'deleteTransaction should remove the document from the sub-collection',
    () async {
      final docRef = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add({'amount': -50.0, 'date': Timestamp.now()});

      await transactionService.deleteTransaction(
        userId: userId,
        transactionId: docRef.id,
      );

      final snapshot = await docRef.get();
      expect(snapshot.exists, isFalse);
    },
  );

  test(
    'createTransaction should call balanceService to update the balance',
    () async {
      final mockBalanceService = MockBalanceService();

      transactionService = FinancialTransactionService(
        firestore: fakeFirestore,
        balanceService: mockBalanceService,
      );

      // Define the transaction data
      final transactionData = {
        'amount': -150.0,
        'balanceId': balanceId,
        'category': 'SHOPPING',
        'date': DateTime.now(),
        'description': 'New headphones',
      };

      await transactionService.createTransaction(
        userId: userId,
        data: transactionData,
      );

      verify(
        mockBalanceService.updateBalanceOnTransaction(
          userId: userId,
          balanceId: balanceId,
          transactionAmount: -150.0,
          batch: anyNamed('batch'),
        ),
      ).called(1);
    },
  );
}
