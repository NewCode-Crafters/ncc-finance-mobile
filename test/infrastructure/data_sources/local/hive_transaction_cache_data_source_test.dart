import 'package:bytebank/core/cache/cache_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../fakes/fake_hive_transaction_cache_data_source.dart';

/// Tests for HiveTransactionCacheDataSource using Fake implementation.
///
/// We use FakeHiveTransactionCacheDataSource to avoid Hive plugin dependencies
/// in unit tests (which require native platform channels).
void main() {
  late FakeHiveTransactionCacheDataSource dataSource;

  setUp(() async {
    dataSource = FakeHiveTransactionCacheDataSource();
    await dataSource.initialize();
  });

  tearDown(() async {
    await dataSource.clearAllCache();
    await dataSource.close();
  });

  group('HiveTransactionCacheDataSource', () {
    test('saveTransactions stores transactions for userId', () async {
      const userId = 'test-user-123';
      final transactions = [
        {
          'id': 'txn1',
          'amount': 100.0,
          'category': 'Food',
          'balanceId': 'bal1',
          'date': '2026-01-05T10:00:00.000',
        },
      ];

      await dataSource.saveTransactions(
        userId: userId,
        transactions: transactions,
      );

      expect(dataSource.hasCache(userId), true);
    });

    test('getTransactionsWithMetadata returns cached data with metadata', () async {
      const userId = 'test-user-456';
      final transactions = [
        {
          'id': 'txn2',
          'amount': 200.0,
          'category': 'Transport',
          'balanceId': 'bal2',
          'date': '2026-01-05T11:00:00.000',
        },
      ];

      await dataSource.saveTransactions(
        userId: userId,
        transactions: transactions,
      );

      final result = await dataSource.getTransactionsWithMetadata(userId);

      expect(result, isNotNull);
      expect(result!.transactions.length, 1);
      expect(result.transactions.first['id'], 'txn2');
      expect(result.metadata.version, 1);
    });

    test('getTransactionsWithMetadata returns null for non-existent userId', () async {
      final result = await dataSource.getTransactionsWithMetadata('non-existent');

      expect(result, isNull);
    });

    test('getMetadata returns metadata without loading transactions', () async {
      const userId = 'test-user-789';
      final transactions = [
        {'id': 'txn3', 'amount': 50.0},
      ];

      await dataSource.saveTransactions(
        userId: userId,
        transactions: transactions,
      );

      final metadata = await dataSource.getMetadata(userId);

      expect(metadata, isNotNull);
      expect(metadata!.version, 1);
    });

    test('clearCache removes cache for specific userId', () async {
      const userId = 'test-user-clear';
      final transactions = [
        {'id': 'txn4', 'amount': 300.0},
      ];

      await dataSource.saveTransactions(
        userId: userId,
        transactions: transactions,
      );
      
      expect(dataSource.hasCache(userId), true);

      await dataSource.clearCache(userId);

      expect(dataSource.hasCache(userId), false);
    });

    test('clearAllCache removes all cached data', () async {
      final transactions = [
        {'id': 'txn5', 'amount': 100.0},
      ];

      await dataSource.saveTransactions(
        userId: 'user1',
        transactions: transactions,
      );
      await dataSource.saveTransactions(
        userId: 'user2',
        transactions: transactions,
      );

      expect(dataSource.hasCache('user1'), true);
      expect(dataSource.hasCache('user2'), true);

      await dataSource.clearAllCache();

      expect(dataSource.hasCache('user1'), false);
      expect(dataSource.hasCache('user2'), false);
    });

    test('hasCache returns true only if cache exists', () async {
      const userId = 'test-user-exists';
      
      expect(dataSource.hasCache(userId), false);

      await dataSource.saveTransactions(
        userId: userId,
        transactions: [{'id': 'txn6'}],
      );

      expect(dataSource.hasCache(userId), true);
    });

    test('cached metadata has fresh timestamp', () async {
      const userId = 'test-user-timestamp';
      final before = DateTime.now();

      await dataSource.saveTransactions(
        userId: userId,
        transactions: [{'id': 'txn7'}],
      );

      final after = DateTime.now();
      final metadata = await dataSource.getMetadata(userId);

      expect(metadata, isNotNull);
      expect(metadata!.cachedAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(metadata.cachedAt.isBefore(after.add(const Duration(seconds: 1))), true);
    });
  });
}
