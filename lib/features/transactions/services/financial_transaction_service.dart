import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/features/dashboard/services/balance_service.dart';
import 'package:bytebank/features/transactions/models/financial_transaction.dart';
import 'package:bytebank/features/transactions/services/financial_transaction_exceptions.dart';

class FinancialTransactionService {
  final FirebaseFirestore _firestore;
  final BalanceService _balanceService;

  FinancialTransactionService({
    FirebaseFirestore? firestore,
    BalanceService? balanceService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _balanceService = balanceService ?? BalanceService() {
    // Desabilita o cache local do Firestore para forçar erro de conexão offline
    _firestore.settings = const Settings(persistenceEnabled: false);
  }


  Future<DocumentReference> createTransaction({
    required String userId,
    required Map<String, dynamic> data,
    WriteBatch? batch,
  }) async {
    try {
      final writeBatch = batch ?? _firestore.batch();

      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc();

      final transactionData = Map<String, dynamic>.from(data);
      transactionData['date'] = Timestamp.fromDate(data['date']);
      writeBatch.set(transactionRef, transactionData);

      await _balanceService.updateBalanceOnTransaction(
        userId: userId,
        balanceId: data['balanceId'],
        transactionAmount: data['amount'],
        batch: batch,
      );

      if (batch == null) {
        await writeBatch.commit();
      }

      return transactionRef;
    } catch (e, stackTrace) {
      log(
        'Error creating transaction',
        error: e,
        stackTrace: stackTrace,
        name: 'FinancialTransactionService',
      );
      throw TransactionException('Falha ao criar transação.');
    }
  }

  Future<List<FinancialTransaction>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        final inclusiveEndDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );

        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(inclusiveEndDate),
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FinancialTransaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw TransactionException('Falha ao buscar transações.');
    }
  }

  /// Paginated fetch: returns a QuerySnapshot for a page of transactions
  /// - [startAfterDoc] can be provided to continue from the last fetched document
  /// - [limit] controls page size
  Future<QuerySnapshot> getTransactionsPage({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    DocumentSnapshot? startAfterDoc,
    required int limit,
    String? searchText,
  }) async {
    try {
      Query query;

      if (searchText != null && searchText.trim().isNotEmpty) {
        final trimmed = searchText.trim();
        final end = '$trimmed\uf8ff';
        query = _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .orderBy('description')
            .where('description', isGreaterThanOrEqualTo: trimmed)
            .where('description', isLessThanOrEqualTo: end);
      } else {
        query = _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .orderBy('date', descending: true);

        if (startDate != null) {
          query = query.where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          );
        }
        if (endDate != null) {
          final inclusiveEndDate = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            23,
            59,
            59,
          );
          query = query.where(
            'date',
            isLessThanOrEqualTo: Timestamp.fromDate(inclusiveEndDate),
          );
        }
      }

      if (startAfterDoc != null) query = query.startAfterDocument(startAfterDoc);
      query = query.limit(limit);
      
      final snapshot = await query.get();
      return snapshot;
    } catch (e) {
      throw TransactionException('Falha ao buscar transações paginadas.');
    }
  }

  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) async {
    try {
      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId);

      final transactionDoc = await transactionRef.get();
      final transactionData = transactionDoc.data();

      if (transactionData != null) {
        final batch = _firestore.batch();

        batch.delete(transactionRef);

        final amountToRevert = transactionData['amount'] as double;
        final balanceId = transactionData['balanceId'] as String;

        await _balanceService.updateBalanceOnTransaction(
          userId: userId,
          balanceId: balanceId,
          transactionAmount: -amountToRevert,
          batch: batch,
        );

        await batch.commit();
      }
    } catch (e) {
      throw TransactionException('Falha ao excluir transação.');
    }
  }

  Future<void> editTransaction({
    required String userId,
    required String transactionId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .update(updateData);
    } catch (e) {
      throw TransactionException('Falha ao atualizar transação.');
    }
  }
}
