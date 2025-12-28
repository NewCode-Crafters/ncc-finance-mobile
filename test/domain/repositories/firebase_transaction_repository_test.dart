import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bytebank/infrastructure/repositories/firebase_investment_repository.dart';
import 'package:bytebank/domain/repositories/financial_transaction_repository.dart';
import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/domain/entities/investment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseInvestmentRepository investmentService;
  late _FakeTransactionRepository fakeTransactionRepo;

  const userId = 'test_user_id';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeTransactionRepo = _FakeTransactionRepository();

    investmentService = FirebaseInvestmentRepository(
      firestore: fakeFirestore,
      transactionService: fakeTransactionRepo,
    );
  });

  test(
    'createInvestment should add a new document to the investments sub-collection',
    () async {
      // Configure fake to return a created entity
      fakeTransactionRepo.nextCreated = FinancialTransactionEntity(
        id: 'created_tx',
        amount: -5000.0,
        balanceId: 'test_balance_id',
        category: 'INVESTMENT',
        date: DateTime.now(),
        description: 'Tesouro Selic 2029',
      );

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

      final investment = Investment(
        id: '',
        name: investmentData['name'] as String,
        amount: investmentData['amount'] as double,
        category: investmentData['category'] as String,
        type: investmentData['type'] as String,
        investedAt: investmentData['investedAt'] as DateTime,
        balanceId: investmentData['balanceId'] as String,
      );

      await investmentService.createInvestment(
        userId: userId,
        investment: investment,
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
      fakeTransactionRepo.nextCreated = FinancialTransactionEntity(
        id: 'created_tx',
        amount: -5000.0,
        balanceId: 'test_balance_id',
        category: 'INVESTMENT',
        date: DateTime.now(),
        description: 'Tesouro Selic 2029',
      );

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
      fakeTransactionRepo.nextCreated = FinancialTransactionEntity(
        id: 'created_tx',
        amount: -5000.0,
        balanceId: 'test_balance_id',
        category: 'INVESTMENT',
        date: DateTime.now(),
        description: 'Tesouro Selic 2029',
      );

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

      final investment = Investment(
        id: '',
        name: investmentData['name'] as String,
        amount: investmentData['amount'] as double,
        category: investmentData['category'] as String,
        type: investmentData['type'] as String,
        investedAt: investmentData['investedAt'] as DateTime,
        balanceId: investmentData['balanceId'] as String,
      );

      await investmentService.createInvestment(
        userId: userId,
        investment: investment,
      );

      final created = fakeTransactionRepo.lastCreatedTransaction!;

      expect(created.amount, -5000.0);
      expect(created.category, 'INVESTMENT');
      expect(created.description, 'Tesouro Selic 2029');
    },
  );

  test(
    'deleteInvestment should create a corresponding income transaction',
    () async {
      fakeTransactionRepo.nextCreated = FinancialTransactionEntity(
        id: 'created_tx',
        amount: 5000.0,
        balanceId: 'test_balance_id',
        category: 'INVESTMENT_REDEMPTION',
        date: DateTime.now(),
        description: 'Resgate de Old Investment',
      );

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

      final created = fakeTransactionRepo.lastCreatedTransaction!;

      expect(created.amount, 5000.0);
      expect(created.category, 'INVESTMENT_REDEMPTION');
      expect(created.description, 'Resgate de Old Investment');
    },
  );
}

class _FakeTransactionRepository implements IFinancialTransactionRepository {
  FinancialTransactionEntity? nextCreated;
  Object? lastBatch;
  FinancialTransactionEntity? lastCreatedTransaction;

  @override
  Future<FinancialTransactionEntity> createTransaction(
    FinancialTransactionEntity transaction, {
    WriteBatch? batch,
  }) async {
    // Return the pre-configured entity or echo the input with a fake id
    lastBatch = batch;
    lastCreatedTransaction =
        nextCreated ?? transaction.copyWith(id: 'fake_tx_id');
    return lastCreatedTransaction!;
  }

  @override
  Stream<List<FinancialTransactionEntity>> watchTransactions({
    String? balanceId,
  }) => Stream.value([]);

  @override
  Future<void> deleteTransaction(String transactionId) async {}

  @override
  Future<FinancialTransactionEntity?> getTransaction(
    String transactionId,
  ) async => null;

  @override
  Future<List<FinancialTransactionEntity>> getTransactions({
    int limit = 50,
    String? startAfterId,
    String? balanceId,
    DateTime? startDate,
    DateTime? endDate,
  }) async => [];

  @override
  Future<FinancialTransactionEntity> updateTransaction(
    FinancialTransactionEntity transaction,
  ) async => transaction;
}
