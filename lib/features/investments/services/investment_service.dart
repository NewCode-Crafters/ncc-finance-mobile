import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/features/investments/models/investment.dart';
import 'package:flutter_application_1/features/investments/services/investment_exceptions.dart';
import 'package:flutter_application_1/features/transactions/services/financial_transaction_service.dart';

class InvestmentService {
  final FirebaseFirestore _firestore;
  final FinancialTransactionService _transactionService;

  InvestmentService({
    FirebaseFirestore? firestore,
    FinancialTransactionService? transactionService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _transactionService =
           transactionService ?? FinancialTransactionService();

  Future<void> createInvestment({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final batch = _firestore.batch();

      final investmentRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('investments')
          .doc();

      final investmentData = Map<String, dynamic>.from(data);
      investmentData['investedAt'] = Timestamp.fromDate(data['investedAt']);
      batch.set(investmentRef, investmentData);

      await _transactionService.createTransaction(
        userId: userId,
        data: {
          'amount': -data['amount'],
          'balanceId': data['balanceId'],
          'category': 'INVESTMENT',
          'date': data['investedAt'],
          'description': data['name'],
          'investmentId': investmentRef.id,
        },
        batch: batch,
      );

      await batch.commit();
    } catch (e) {
      throw InvestmentException('Failed to create investment.');
    }
  }

  Future<void> deleteInvestment({
    required String userId,
    required String investmentId,
  }) async {
    try {
      final investmentRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('investments')
          .doc(investmentId);

      final investmentDoc = await investmentRef.get();
      if (!investmentDoc.exists) {
        return;
      }

      final investmentData = investmentDoc.data()!;

      final batch = _firestore.batch();

      batch.delete(investmentRef);

      await _transactionService.createTransaction(
        userId: userId,
        data: {
          'amount': investmentData['amount'],
          'balanceId': investmentData['balanceId'],
          'category': 'INVESTMENT_REDEMPTION',
          'date': Timestamp.now(),
          'description': 'Redemption of ${investmentData['name']}',
          'investmentId': investmentId,
        },
        batch: batch,
      );

      await batch.commit();
    } catch (e) {
      throw InvestmentException('Failed to delete investment.');
    }
  }

  Future<List<Investment>> getInvestments({required String userId}) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('investments')
        .orderBy('investedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Investment.fromFirestore(doc)).toList();
  }
}
