import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bytebank/features/dashboard/services/balance_service.dart';
import 'package:bytebank/features/investments/services/investment_service.dart';
import 'package:bytebank/features/transactions/services/financial_transaction_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'investment_service_test.mocks.dart';

@GenerateMocks([BalanceService, FinancialTransactionService, DocumentReference])
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late InvestmentService investmentService;
  late MockFinancialTransactionService mockTransactionService;

  const userId = 'test_user_id';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockTransactionService = MockFinancialTransactionService();

    investmentService = InvestmentService(
      firestore: fakeFirestore,
      transactionService: mockTransactionService,
    );
  });

  test(
    'createInvestment should add a new document to the investments sub-collection',
    () async {
      when(
        mockTransactionService.createTransaction(
          userId: anyNamed('userId'),
          data: anyNamed('data'),
          batch: anyNamed('batch'),
        ),
      ).thenAnswer((_) async => MockDocumentReference());

      final investmentData = {
        'name': 'Tesouro Selic 2029',
        'amount': 5000.0,
        'category': 'FIXED_INCOME',
        'type': 'GOVERNMENT_BOND',
        'investedAt': DateTime.now(),
        'balanceId': 'test_balance_id',
      };

      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .doc('test_balance_id')
          .set({'amount': 10000.0});

      await investmentService.createInvestment(
        userId: userId,
        data: investmentData,
      );

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('investments')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['name'], 'Tesouro Selic 2029');
    },
  );

  test(
    'deleteInvestment should remove the document from the sub-collection',
    () async {
      when(
        mockTransactionService.createTransaction(
          userId: anyNamed('userId'),
          data: anyNamed('data'),
          batch: anyNamed('batch'),
        ),
      ).thenAnswer((_) async => MockDocumentReference());

      final docRef = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('investments')
          .add({
            'name': 'Tesouro Selic 2029',
            'amount': 5000.0,
            'balanceId': 'test_balance_id',
          });

      await investmentService.deleteInvestment(
        userId: userId,
        investmentId: docRef.id,
      );

      final snapshot = await docRef.get();
      expect(snapshot.exists, isFalse);
    },
  );

  test(
    'getInvestments should return a list of investments ordered by date descending',
    () async {
      final now = DateTime.now();
      final investmentsCollection = fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('investments');

      await investmentsCollection.add({
        'amount': 500.0,
        'investedAt': Timestamp.fromDate(
          now.subtract(const Duration(days: 10)),
        ),
      });

      await investmentsCollection.add({
        'amount': 1000.0,
        'investedAt': Timestamp.fromDate(now),
      }); // Most recent

      await investmentsCollection.add({
        'amount': 250.0,
        'investedAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
      });

      final investments = await investmentService.getInvestments(
        userId: userId,
      );

      expect(investments.length, 3);
      expect(
        investments.first.amount,
        1000.0,
      ); // The most recent should be first.
    },
  );

  test(
    'createInvestment should create a corresponding expense transaction',
    () async {
      when(
        mockTransactionService.createTransaction(
          userId: anyNamed('userId'),
          data: anyNamed('data'),
          batch: anyNamed('batch'),
        ),
      ).thenAnswer((_) async => MockDocumentReference());

      final investmentData = {
        'name': 'Tesouro Selic 2029',
        'amount': 5000.0,
        'balanceId': 'test_balance_id',
        'investedAt': DateTime.now(),
        'category': 'FIXED_INCOME',
        'type': 'GOVERNMENT_BOND',
      };

      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .doc('test_balance_id')
          .set({'amount': 10000.0});

      await investmentService.createInvestment(
        userId: userId,
        data: investmentData,
      );

      final captured = verify(
        mockTransactionService.createTransaction(
          userId: userId,
          data: captureAnyNamed('data'),
          batch: anyNamed('batch'),
        ),
      ).captured;

      expect(
        captured.first['amount'],
        -5000.0,
      ); // It must be a negative amount.
      expect(captured.first['category'], 'INVESTMENT');
      expect(captured.first['description'], 'Tesouro Selic 2029');
    },
  );

  test(
    'deleteInvestment should create a corresponding income transaction',
    () async {
      when(
        mockTransactionService.createTransaction(
          userId: anyNamed('userId'),
          data: anyNamed('data'),
          batch: anyNamed('batch'),
        ),
      ).thenAnswer((_) async => MockDocumentReference());

      final investmentAmount = 5000.0;
      final investmentDocRef = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('investments')
          .add({
            'name': 'Old Investment',
            'amount': investmentAmount,
            'balanceId': 'test_balance_id',
            'investedAt': Timestamp.now(),
          });

      await investmentService.deleteInvestment(
        userId: userId,
        investmentId: investmentDocRef.id,
      );

      final captured = verify(
        mockTransactionService.createTransaction(
          userId: userId,
          data: captureAnyNamed('data'),
          batch: anyNamed('batch'),
        ),
      ).captured;

      expect(captured.first['amount'], 5000.0);
      expect(captured.first['category'], 'INVESTMENT_REDEMPTION');
      expect(captured.first['description'], 'Resgate de Old Investment');
    },
  );
}
