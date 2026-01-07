import 'dart:async';

import 'package:bytebank/core/cache/cache_policy.dart';
import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/domain/exceptions/financial_transaction_exception.dart';
import 'package:bytebank/domain/repositories/financial_transaction_repository.dart';
import 'package:bytebank/infrastructure/mappers/financial_transaction_mapper.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_data_source.dart';
import 'package:bytebank/infrastructure/data_sources/local/hive_transaction_cache_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTransactionRepository implements IFinancialTransactionRepository {
  FirebaseTransactionRepository({
    required FirebaseTransactionDataSource dataSource,
    required HiveTransactionCacheDataSource cacheDataSource,
    FinancialTransactionMapper? mapper,
    CachePolicy? cachePolicy,
    String? currentUserId,
  })  : _dataSource = dataSource,
        _cacheDataSource = cacheDataSource,
        _mapper = mapper ?? const FinancialTransactionMapper(),
        _cachePolicy = cachePolicy ?? const CachePolicy(),
        _currentUserId = currentUserId;

  final FirebaseTransactionDataSource _dataSource;
  final HiveTransactionCacheDataSource _cacheDataSource;
  final FinancialTransactionMapper _mapper;
  final CachePolicy _cachePolicy;
  final String? _currentUserId;

  String _requireUserId() {
    // Prefer an injected currentUserId (useful for tests). If not provided,
    // attempt to read the currently authenticated user from FirebaseAuth.
    if (_currentUserId != null && _currentUserId.isNotEmpty) {
      return _currentUserId;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw const FinancialTransactionRepositoryException(
        'User id is required to access transactions.',
      );
    }

    return uid;
  }

  @override
  Future<FinancialTransactionEntity> createTransaction(
    FinancialTransactionEntity transaction, {
    WriteBatch? batch,
  }) async {
    final userId = _requireUserId();
    final dto = _mapper.toDTO(transaction);

    try {
      final created = await _dataSource.createTransaction(
        userId: userId,
        transaction: dto,
        batch: batch,
      );

      return _mapper.toDomain(created);
    } on FinancialTransactionRepositoryException catch (e) {
      throw FinancialTransactionRepositoryException(e.message);
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    final userId = _requireUserId();

    try {
      await _dataSource.deleteTransaction(
        userId: userId,
        transactionId: transactionId,
      );
    } on FinancialTransactionRepositoryException catch (e) {
      throw FinancialTransactionRepositoryException(e.message);
    }
  }

  @override
  Future<FinancialTransactionEntity?> getTransaction(
    String transactionId,
  ) async {
    final userId = _requireUserId();

    try {
      final dto = await _dataSource.getTransaction(
        userId: userId,
        transactionId: transactionId,
      );

      if (dto == null) return null;
      return _mapper.toDomain(dto);
    } on FinancialTransactionRepositoryException catch (e) {
      throw FinancialTransactionRepositoryException(e.message);
    }
  }

  @override
  Future<List<FinancialTransactionEntity>> getTransactions({
    int limit = 50,
    String? startAfterId,
    String? balanceId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = _requireUserId();

    // 1. Try cache first (cache-first strategy)
    try {
      final cachedResult = await _cacheDataSource.getTransactionsWithMetadata(userId);
      
      if (cachedResult != null) {
        final isExpired = _cachePolicy.isExpired(cachedResult.metadata.cachedAt);
        
        // If cache is fresh, return it immediately
        if (!isExpired) {
          return cachedResult.transactions
              .map((json) => _mapper.toDomain(_mapper.fromJson(json)))
              .toList();
        }
      }
    } catch (e) {
      // Cache read error, continue to remote fetch
    }

    // 2. Fetch from remote (cache expired or not available)
    try {
      final dtos = await _dataSource.getTransactions(
        userId: userId,
        limit: limit,
        startAfterId: startAfterId,
        balanceId: balanceId,
        startDate: startDate,
        endDate: endDate,
      );

      // 3. Update cache with fresh data
      try {
        final transactionMaps = dtos.map((dto) => dto.toMap()).toList();
        await _cacheDataSource.saveTransactions(
          userId: userId,
          transactions: transactionMaps,
        );
      } catch (e) {
        // Cache write error, non-critical (just log in production)
      }

      return dtos.map(_mapper.toDomain).toList();
    } catch (e) {
      // 4. Remote fetch failed - fallback to stale cache if available
      try {
        final cachedResult = await _cacheDataSource.getTransactionsWithMetadata(userId);
        
        if (cachedResult != null) {
          // Return stale cache as fallback
          return cachedResult.transactions
              .map((json) => _mapper.toDomain(_mapper.fromJson(json)))
              .toList();
        }
      } catch (cacheError) {
        // Cache also failed, rethrow original error
      }

      // No cache available, rethrow the original remote error
      if (e is FinancialTransactionRepositoryException) {
        rethrow;
      }
      throw FinancialTransactionRepositoryException(e.toString());
    }
  }

  @override
  Stream<List<FinancialTransactionEntity>> watchTransactions({
    String? balanceId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final userId = _requireUserId();

    return _dataSource
        .watchTransactions(
          userId: userId,
          balanceId: balanceId,
          startDate: startDate,
          endDate: endDate,
        )
        .map((dtos) => dtos.map(_mapper.toDomain).toList())
        .handleError((error) {
          if (error is FinancialTransactionRepositoryException) {
            throw FinancialTransactionRepositoryException(error.message);
          }

          throw const FinancialTransactionRepositoryException(
            'Unknown error while watching transactions.',
          );
        });
  }

  @override
  Future<FinancialTransactionEntity> updateTransaction(
    FinancialTransactionEntity transaction,
  ) async {
    final userId = _requireUserId();
    final dto = _mapper.toDTO(transaction);

    try {
      await _dataSource.updateTransaction(userId: userId, transaction: dto);
      return transaction;
    } on FinancialTransactionRepositoryException catch (e) {
      throw FinancialTransactionRepositoryException(e.message);
    }
  }
}
