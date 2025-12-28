import 'dart:async';

import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/infrastructure/dtos/financial_transaction_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/infrastructure/mappers/financial_transaction_mapper.dart';
import 'package:bytebank/infrastructure/repositories/firebase_transaction_repository.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDataSource implements FirebaseTransactionDataSource {
  String? lastCreateUserId;
  FinancialTransactionDTO? lastCreateDto;
  WriteBatch? lastCreateBatch;

  String? lastUpdateUserId;
  FinancialTransactionDTO? lastUpdateDto;

  String? lastDeleteUserId;
  String? lastDeleteId;

  String? lastGetUserId;
  String? lastGetId;

  String? lastGetListUserId;
  int? lastGetListLimit;
  String? lastGetListStartAfterId;
  String? lastGetListBalanceId;
  DateTime? lastGetListStartDate;
  DateTime? lastGetListEndDate;

  String? lastWatchUserId;
  String? lastWatchBalanceId;

  // controlled return values
  FinancialTransactionDTO? createReturn;
  FinancialTransactionDTO? getReturn;
  List<FinancialTransactionDTO>? listReturn;
  Stream<List<FinancialTransactionDTO>>? watchReturn;

  @override
  Future<FinancialTransactionDTO> createTransaction({
    required String userId,
    required FinancialTransactionDTO transaction,
    WriteBatch? batch,
  }) async {
    lastCreateUserId = userId;
    lastCreateDto = transaction;
    lastCreateBatch = batch;
    if (createReturn != null) return createReturn!;
    return transaction.copyWith(
      id: transaction.id.isEmpty ? 'generated' : transaction.id,
    );
  }

  @override
  Future<void> updateTransaction({
    required String userId,
    required FinancialTransactionDTO transaction,
  }) async {
    lastUpdateUserId = userId;
    lastUpdateDto = transaction;
    return;
  }

  @override
  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) async {
    lastDeleteUserId = userId;
    lastDeleteId = transactionId;
    return;
  }

  @override
  Future<FinancialTransactionDTO?> getTransaction({
    required String userId,
    required String transactionId,
  }) async {
    lastGetUserId = userId;
    lastGetId = transactionId;
    return getReturn;
  }

  @override
  Future<List<FinancialTransactionDTO>> getTransactions({
    required String userId,
    int limit = 50,
    String? startAfterId,
    String? balanceId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    lastGetListUserId = userId;
    lastGetListLimit = limit;
    lastGetListStartAfterId = startAfterId;
    lastGetListBalanceId = balanceId;
    lastGetListStartDate = startDate;
    lastGetListEndDate = endDate;
    return listReturn ?? <FinancialTransactionDTO>[];
  }

  @override
  Stream<List<FinancialTransactionDTO>> watchTransactions({
    required String userId,
    String? balanceId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    lastWatchUserId = userId;
    lastWatchBalanceId = balanceId;
    return watchReturn ?? Stream.value(<FinancialTransactionDTO>[]);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getTransactionsPage({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDoc,
    required int limit,
    String? searchText,
  }) async {
    // Not used in these unit tests, provide a stub.
    throw UnimplementedError();
  }
}

class _FakeWriteBatch implements WriteBatch {
  @override
  void set<T>(
    DocumentReference<T> documentRef,
    Object? data, [
    SetOptions? options,
  ]) {}

  @override
  void update(DocumentReference documentRef, Map<String, dynamic> data) {}

  @override
  void delete(DocumentReference documentRef) {}

  @override
  Future<void> commit() async {}
}

void main() {
  const userId = 'user123';
  final mapper = const FinancialTransactionMapper();

  group('FirebaseTransactionRepository', () {
    test('createTransaction forwards userId and maps DTO/entity', () async {
      final fake = _FakeDataSource();
      final repo = FirebaseTransactionRepository(
        dataSource: fake as dynamic,
        mapper: mapper,
        currentUserId: userId,
      );

      final entity = FinancialTransactionEntity(
        id: '',
        amount: 10.5,
        balanceId: 'bal1',
        category: 'food',
        date: DateTime(2020, 1, 2),
        description: 'Lunch',
      );

      final dummyBatch = _FakeWriteBatch();
      final result = await repo.createTransaction(entity, batch: dummyBatch);

      expect(fake.lastCreateUserId, equals(userId));
      final sent = fake.lastCreateDto!;
      expect(sent.amount, equals(entity.amount));
      expect(sent.balanceId, equals(entity.balanceId));
      expect(identical(fake.lastCreateBatch, dummyBatch), isTrue);
      expect(result.id, isNotEmpty);
    });

    test('updateTransaction forwards userId and dto', () async {
      final fake = _FakeDataSource();
      final repo = FirebaseTransactionRepository(
        dataSource: fake as dynamic,
        mapper: mapper,
        currentUserId: userId,
      );

      final entity = FinancialTransactionEntity(
        id: 'tx1',
        amount: 5.0,
        balanceId: 'bal2',
        category: 'misc',
        date: DateTime.now(),
      );

      final updated = await repo.updateTransaction(entity);

      expect(fake.lastUpdateUserId, equals(userId));
      expect(fake.lastUpdateDto!.id, equals(entity.id));
      expect(updated.id, equals(entity.id));
    });

    test('deleteTransaction forwards userId and id', () async {
      final fake = _FakeDataSource();
      final repo = FirebaseTransactionRepository(
        dataSource: fake as dynamic,
        mapper: mapper,
        currentUserId: userId,
      );

      await repo.deleteTransaction('tx-delete');

      expect(fake.lastDeleteUserId, equals(userId));
      expect(fake.lastDeleteId, equals('tx-delete'));
    });

    test('getTransaction maps dto to domain', () async {
      final fake = _FakeDataSource();
      fake.getReturn = FinancialTransactionDTO(
        id: 'tx-get',
        amount: 7.5,
        balanceId: 'balX',
        category: 'cat',
        date: DateTime(2021, 3, 4),
        description: 'desc',
      );

      final repo = FirebaseTransactionRepository(
        dataSource: fake as dynamic,
        mapper: mapper,
        currentUserId: userId,
      );

      final got = await repo.getTransaction('tx-get');

      expect(fake.lastGetUserId, equals(userId));
      expect(fake.lastGetId, equals('tx-get'));
      expect(got, isNotNull);
      expect(got!.id, equals('tx-get'));
      expect(got.amount, equals(7.5));
    });

    test('getTransactions forwards pagination params and maps list', () async {
      final fake = _FakeDataSource();
      fake.listReturn = [
        FinancialTransactionDTO(
          id: 'a',
          amount: 1,
          balanceId: 'b',
          category: 'c',
          date: DateTime(2022, 1, 1),
        ),
      ];

      final repo = FirebaseTransactionRepository(
        dataSource: fake as dynamic,
        mapper: mapper,
        currentUserId: userId,
      );

      final startDate = DateTime(2020, 1, 1);
      final endDate = DateTime(2020, 12, 31);
      final list = await repo.getTransactions(
        limit: 10,
        startAfterId: 'start',
        balanceId: 'bal',
        startDate: startDate,
        endDate: endDate,
      );

      expect(fake.lastGetListUserId, equals(userId));
      expect(fake.lastGetListLimit, equals(10));
      expect(fake.lastGetListStartAfterId, equals('start'));
      expect(fake.lastGetListBalanceId, equals('bal'));
      expect(fake.lastGetListStartDate, equals(startDate));
      expect(fake.lastGetListEndDate, equals(endDate));
      expect(list, hasLength(1));
      expect(list.first.id, equals('a'));
    });

    test('watchTransactions maps stream and forwards params', () async {
      final fake = _FakeDataSource();
      fake.watchReturn = Stream.value([
        FinancialTransactionDTO(
          id: 's1',
          amount: 2,
          balanceId: 'balS',
          category: 'catS',
          date: DateTime(2023, 6, 6),
        ),
      ]);

      final repo = FirebaseTransactionRepository(
        dataSource: fake as dynamic,
        mapper: mapper,
        currentUserId: userId,
      );

      final stream = repo.watchTransactions(balanceId: 'balS');
      final events = await stream.first;

      expect(fake.lastWatchUserId, equals(userId));
      expect(fake.lastWatchBalanceId, equals('balS'));
      expect(events, hasLength(1));
      expect(events.first.id, equals('s1'));
    });
  });
}
