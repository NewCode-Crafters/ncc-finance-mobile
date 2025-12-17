import 'dart:async';

import 'package:bytebank/domain/entities/financial_transaction_entity.dart';
import 'package:bytebank/domain/exceptions/financial_transaction_exception.dart';
import 'package:bytebank/domain/repositories/i_financial_transaction_repository.dart';
import 'package:bytebank/infrastructure/mappers/financial_transaction_mapper.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTransactionRepository implements IFinancialTransactionRepository {
  FirebaseTransactionRepository({
    required FirebaseTransactionDataSource dataSource,
    FinancialTransactionMapper? mapper,
    String? currentUserId,
  }) : _dataSource = dataSource,
       _mapper = mapper ?? const FinancialTransactionMapper(),
       _currentUserId = currentUserId;

  final FirebaseTransactionDataSource _dataSource;
  final FinancialTransactionMapper _mapper;
  final String? _currentUserId;

  String _requireUserId() {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      throw const FinancialTransactionRepositoryException(
        'User id is required to access transactions.',
      );
    }

    return _currentUserId!;
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

    try {
      final dtos = await _dataSource.getTransactions(
        userId: userId,
        limit: limit,
        startAfterId: startAfterId,
        balanceId: balanceId,
        startDate: startDate,
        endDate: endDate,
      );

      return dtos.map(_mapper.toDomain).toList();
    } on FinancialTransactionRepositoryException catch (e) {
      throw FinancialTransactionRepositoryException(e.message);
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
