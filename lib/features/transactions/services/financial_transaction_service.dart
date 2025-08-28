import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/features/dashboard/services/balance_service.dart';
import 'package:flutter_application_1/features/transactions/models/financial_transaction.dart';
import 'package:flutter_application_1/features/transactions/services/financial_transaction_exceptions.dart';

class FinancialTransactionService {
  final FirebaseFirestore _firestore;
  final BalanceService _balanceService;

  FinancialTransactionService({
    FirebaseFirestore? firestore,
    BalanceService? balanceService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _balanceService = balanceService ?? BalanceService();

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
      throw TransactionException('Failed to create transaction.');
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
      throw TransactionException('Failed to fetch transactions.');
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
      throw TransactionException('Failed to delete transaction.');
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
      throw TransactionException('Failed to update transaction.');
    }
  }
}
