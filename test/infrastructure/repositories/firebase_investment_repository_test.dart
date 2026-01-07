import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/infrastructure/repositories/firebase_investment_repository.dart';
import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/infrastructure/repositories/firebase_transaction_repository.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_data_source.dart';
import 'package:bytebank/infrastructure/mappers/financial_transaction_mapper.dart';
import '../../fakes/fake_hive_transaction_cache_data_source.dart';

void main() {
  test('create/get/delete investment flows', () async {
    final fakeFs = FakeFirebaseFirestore();
    final txRepo = FirebaseTransactionRepository(
      dataSource: FirebaseTransactionDataSource(firestore: fakeFs),
      cacheDataSource: FakeHiveTransactionCacheDataSource(),
      mapper: const FinancialTransactionMapper(),
      currentUserId: 'u1',
    );

    final repo = FirebaseInvestmentRepository(
      firestore: fakeFs,
      transactionService: txRepo,
    );

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
