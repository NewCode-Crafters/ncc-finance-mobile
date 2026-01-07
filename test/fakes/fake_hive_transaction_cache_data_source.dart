import 'package:bytebank/core/cache/cache_policy.dart';
import 'package:bytebank/infrastructure/data_sources/local/hive_transaction_cache_data_source.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Fake implementation of HiveTransactionCacheDataSource for testing.
///
/// Uses in-memory Map storage to avoid Hive dependency in tests.
class FakeHiveTransactionCacheDataSource implements HiveTransactionCacheDataSource {
  final Map<String, Map<String, dynamic>> _storage = {};
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Box<dynamic> get box => throw UnimplementedError('box getter not used in tests');

  @override
  Future<void> saveTransactions({
    required String userId,
    required List<Map<String, dynamic>> transactions,
  }) async {
    _ensureInitialized();
    _storage[userId] = {
      'metadata': CacheMetadata.now().toJson(),
      'transactions': transactions,
    };
  }

  @override
  Future<Map<String, dynamic>?> getCachedData(String userId) async {
    _ensureInitialized();
    return _storage[userId];
  }

  @override
  Future<({List<Map<String, dynamic>> transactions, CacheMetadata metadata})?>
      getTransactionsWithMetadata(String userId) async {
    _ensureInitialized();
    final cachedData = _storage[userId];
    if (cachedData == null) return null;

    try {
      final metadataJson = cachedData['metadata'] as Map<String, dynamic>;
      final metadata = CacheMetadata.fromJson(metadataJson);

      final transactionsData = cachedData['transactions'] as List;
      final transactions = transactionsData
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return (transactions: transactions, metadata: metadata);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache(String userId) async {
    _ensureInitialized();
    _storage.remove(userId);
  }

  @override
  Future<void> clearAllCache() async {
    _ensureInitialized();
    _storage.clear();
  }

  @override
  bool hasCache(String userId) {
    _ensureInitialized();
    return _storage.containsKey(userId);
  }

  @override
  Future<CacheMetadata?> getMetadata(String userId) async {
    _ensureInitialized();
    final cachedData = _storage[userId];
    if (cachedData == null) return null;

    try {
      final metadataJson = cachedData['metadata'] as Map<String, dynamic>;
      return CacheMetadata.fromJson(metadataJson);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> close() async {
    _storage.clear();
    _initialized = false;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('FakeHiveTransactionCacheDataSource not initialized');
    }
  }

  // Helper for tests: inject metadata with specific timestamp
  void injectCachedData({
    required String userId,
    required List<Map<String, dynamic>> transactions,
    required DateTime cachedAt,
  }) {
    _ensureInitialized();
    _storage[userId] = {
      'metadata': CacheMetadata(cachedAt: cachedAt).toJson(),
      'transactions': transactions,
    };
  }
}
