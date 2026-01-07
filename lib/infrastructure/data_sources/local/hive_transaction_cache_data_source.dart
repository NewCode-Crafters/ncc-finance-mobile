import 'package:bytebank/core/cache/cache_policy.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local data source for caching financial transactions using Hive.
///
/// Stores transactions as JSON maps (no codegen) with cache metadata per userId.
class HiveTransactionCacheDataSource {
  static const String _boxName = 'transactions_cache';
  
  Box<dynamic>? _box;

  /// Initialize the Hive box (must be called before using other methods).
  Future<void> initialize() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
  }

  /// Get the Hive box instance.
  Box<dynamic> get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
        'HiveTransactionCacheDataSource not initialized. Call initialize() first.',
      );
    }
    return _box!;
  }

  /// Save transactions to cache for a specific userId.
  ///
  /// [userId] - The user ID to associate with cached transactions.
  /// [transactions] - List of transaction maps (JSON format).
  Future<void> saveTransactions({
    required String userId,
    required List<Map<String, dynamic>> transactions,
  }) async {
    final cacheData = {
      'metadata': CacheMetadata.now().toJson(),
      'transactions': transactions,
    };

    await box.put(userId, cacheData);
  }

  /// Get cached transactions for a specific userId.
  ///
  /// Returns null if no cache exists for the userId.
  Future<Map<String, dynamic>?> getCachedData(String userId) async {
    final data = box.get(userId);
    if (data == null) return null;

    // Ensure data is a Map
    if (data is! Map) return null;

    return Map<String, dynamic>.from(data);
  }

  /// Get cached transactions with metadata for a specific userId.
  ///
  /// Returns a tuple: (transactions, metadata) or null if no cache exists.
  Future<({List<Map<String, dynamic>> transactions, CacheMetadata metadata})?> 
      getTransactionsWithMetadata(String userId) async {
    final cachedData = await getCachedData(userId);
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
      // Invalid cache format, return null
      return null;
    }
  }

  /// Clear cache for a specific userId.
  Future<void> clearCache(String userId) async {
    await box.delete(userId);
  }

  /// Clear all cached data.
  Future<void> clearAllCache() async {
    await box.clear();
  }

  /// Check if cache exists for a userId.
  bool hasCache(String userId) {
    return box.containsKey(userId);
  }

  /// Get cache metadata without loading transactions.
  Future<CacheMetadata?> getMetadata(String userId) async {
    final cachedData = await getCachedData(userId);
    if (cachedData == null) return null;

    try {
      final metadataJson = cachedData['metadata'] as Map<String, dynamic>;
      return CacheMetadata.fromJson(metadataJson);
    } catch (e) {
      return null;
    }
  }

  /// Close the Hive box (cleanup).
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
