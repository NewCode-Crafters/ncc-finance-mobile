import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/features/dashboard/services/balance_service.dart';
import 'package:flutter_application_1/features/transactions/models/financial_transaction.dart';

class FinancialTransactionService {
  final FirebaseFirestore _firestore;
  final BalanceService _balanceService;

  FinancialTransactionService({
    FirebaseFirestore? firestore,
    BalanceService? balanceService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _balanceService = balanceService ?? BalanceService();

  Future<void> createTransaction({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final batch = _firestore.batch();

    final transactionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc();

    final transactionData = Map<String, dynamic>.from(data);
    transactionData['date'] = Timestamp.fromDate(data['date']);
    batch.set(transactionRef, transactionData);

    await _balanceService.updateBalanceOnTransaction(
      userId: userId,
      balanceId: data['balanceId'],
      transactionAmount: data['amount'],
      batch: batch,
    );

    await batch.commit();
  }

  Future<List<FinancialTransaction>> getTransactions({
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FinancialTransaction.fromFirestore(doc))
        .toList();
  }

  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }
}
