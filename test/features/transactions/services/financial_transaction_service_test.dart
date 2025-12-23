import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bytebank/domain/repositories/i_financial_transaction_repository.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_data_source.dart';
import 'package:bytebank/infrastructure/mappers/financial_transaction_mapper.dart';
import 'package:bytebank/infrastructure/repositories/firebase_transaction_repository.dart';
import 'package:bytebank/domain/entities/financial_transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late IFinancialTransactionRepository transactionService;
  const userId = 'test_user_id';
  late String balanceId;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    // Provide a thin repository implementation that delegates to the
    // FakeFirebaseFirestore and performs balance updates in the data source.
    final dataSource = FirebaseTransactionDataSource(firestore: fakeFirestore);
    transactionService = FirebaseTransactionRepository(
      dataSource: dataSource,
      mapper: const FinancialTransactionMapper(),
      currentUserId: userId,
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
        'balanceId': balanceId,
        'category': 'SHOPPING',
        'date': DateTime.now(),
        'description': 'New headphones',
      };

      final entity = FinancialTransactionEntity(
        id: '',
        amount: transactionData['amount'] as double,
        balanceId: transactionData['balanceId'] as String,
        category: transactionData['category'] as String,
        date: transactionData['date'] as DateTime,
        description: transactionData['description'] as String?,
      );

      await transactionService.createTransaction(entity);

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

      final transactions = await transactionService.getTransactions();

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
          .add({
            'amount': -50.0,
            'date': Timestamp.now(),
            'balanceId': balanceId,
          });

      await transactionService.deleteTransaction(docRef.id);

      final snapshot = await docRef.get();
      expect(snapshot.exists, isFalse);
    },
  );

  test(
    'createTransaction should call balanceService to update the balance',
    () async {
      // create repository pointing to fake firestore
      transactionService = FirebaseTransactionRepository(
        dataSource: FirebaseTransactionDataSource(firestore: fakeFirestore),
        mapper: const FinancialTransactionMapper(),
        currentUserId: userId,
      );
      // Define the transaction data
      final transactionData = {
        'amount': -150.0,
        'balanceId': balanceId,
        'category': 'SHOPPING',
        'date': DateTime.now(),
        'description': 'New headphones',
      };

      final entity = FinancialTransactionEntity(
        id: '',
        amount: transactionData['amount'] as double,
        balanceId: transactionData['balanceId'] as String,
        category: transactionData['category'] as String,
        date: transactionData['date'] as DateTime,
      );

      await transactionService.createTransaction(entity);

      final balanceSnap = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .doc(balanceId)
          .get();

      expect(balanceSnap.data()?['amount'], 850.0);
    },
  );

  test(
    'createTransaction should call balanceService with a POSITIVE amount for income',
    () async {
      // create repository pointing to fake firestore
      transactionService = FirebaseTransactionRepository(
        dataSource: FirebaseTransactionDataSource(firestore: fakeFirestore),
        mapper: const FinancialTransactionMapper(),
        currentUserId: userId,
      );

      final balanceDoc = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .add({'amount': 1000.0});
      final balanceId = balanceDoc.id;

      final transactionData = {
        'amount': 500.0,
        'balanceId': balanceId,
        'category': 'SALARY',
        'date': DateTime.now(),
      };

      final entity = FinancialTransactionEntity(
        id: '',
        amount: transactionData['amount'] as double,
        balanceId: transactionData['balanceId'] as String,
        category: transactionData['category'] as String,
        date: transactionData['date'] as DateTime,
      );

      await transactionService.createTransaction(entity);

      final balanceSnap = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .doc(balanceId)
          .get();

      expect(balanceSnap.data()?['amount'], 1500.0);
    },
  );

  test(
    'deleteTransaction should call balanceService to revert the balance',
    () async {
      // create repository pointing to fake firestore
      transactionService = FirebaseTransactionRepository(
        dataSource: FirebaseTransactionDataSource(firestore: fakeFirestore),
        mapper: const FinancialTransactionMapper(),
        currentUserId: userId,
      );

      final transactionAmount = -50.0;
      final transactionDocRef = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add({
            'amount': transactionAmount,
            'balanceId': balanceId,
            'date': Timestamp.now(),
          });

      await transactionService.deleteTransaction(transactionDocRef.id);

      final balanceSnap = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .doc(balanceId)
          .get();

      expect(balanceSnap.data()?['amount'], 1050.0);
    },
  );

  test(
    'editTransaction should update the fields of an existing document',
    () async {
      final docRef = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add({
            'description': 'Old description',
            'category': 'OLD_CATEGORY',
            'amount': -50.0,
            'date': Timestamp.now(),
          });

      final updateData = {
        'description': 'New shiny description',
        'category': 'NEW_CATEGORY',
      };

      final doc = await docRef.get();
      final d = doc.data()!;
      final existing = FinancialTransactionEntity(
        id: docRef.id,
        amount: (d['amount'] as num).toDouble(),
        balanceId: d['balanceId'] as String? ?? '',
        category: d['category'] as String? ?? '',
        date: (d['date'] as Timestamp).toDate(),
        description: d['description'] as String?,
      );

      final updatedEntity = existing.copyWith(
        description: updateData['description'],
        category: updateData['category'],
      );

      await transactionService.updateTransaction(updatedEntity);

      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()?['description'], 'New shiny description');
      expect(updatedDoc.data()?['category'], 'NEW_CATEGORY');
      expect(updatedDoc.data()?['amount'], -50.0);
    },
  );
}
