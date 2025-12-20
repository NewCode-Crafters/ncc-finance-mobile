import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/domain/exceptions/investment_exception.dart';
import 'package:bytebank/domain/repositories/i_financial_transaction_repository.dart';
import 'package:bytebank/domain/entities/financial_transaction_entity.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_data_source.dart';
import 'package:bytebank/infrastructure/mappers/financial_transaction_mapper.dart';
import 'package:bytebank/infrastructure/repositories/firebase_transaction_repository.dart';

class InvestmentService {
  final FirebaseFirestore _firestore;
  final IFinancialTransactionRepository _transactionService;

  InvestmentService({
    FirebaseFirestore? firestore,
    IFinancialTransactionRepository? transactionService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _transactionService =
           transactionService ??
           FirebaseTransactionRepository(
             dataSource: FirebaseTransactionDataSource(
               firestore: firestore ?? FirebaseFirestore.instance,
             ),
             mapper: const FinancialTransactionMapper(),
             currentUserId: null,
           );

  // ok
  Future<void> createInvestment({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final investmentAmount = data['amount'] as double;
    final balanceId = data['balanceId'] as String;

    final balanceDocRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('balances')
        .doc(balanceId);

    final balanceSnapshot = await balanceDocRef.get();
    if (!balanceSnapshot.exists) {
      throw Exception('Balance account not found.');
    }

    final currentBalance = (balanceSnapshot.data()!['amount'] as num)
        .toDouble();

    if (currentBalance < investmentAmount) {
      throw InsufficientFundsException(
        'Saldo insuficiente para realizar o investimento.',
      );
    }

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

      final txEntity = FinancialTransactionEntity(
        id: '',
        amount: -data['amount'],
        balanceId: data['balanceId'],
        category: 'INVESTMENT',
        date: data['investedAt'],
        description: data['name'],
      );

      await _transactionService.createTransaction(txEntity, batch: batch);

      await batch.commit();
    } catch (e) {
      if (e is! InsufficientFundsException) {
        throw InvestmentException('Failed to create investment.');
      }
      rethrow;
    }
  }

  // ok
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

      // Delete only the investment document (keep the original transaction)
      batch.delete(investmentRef);

      // Create redemption transaction
      final redemption = FinancialTransactionEntity(
        id: '',
        amount: investmentData['amount'],
        balanceId: investmentData['balanceId'],
        category: 'INVESTMENT_REDEMPTION',
        date: DateTime.now(),
        description: 'Resgate de ${investmentData['name']}',
      );

      await _transactionService.createTransaction(redemption, batch: batch);

      await batch.commit();
    } catch (e, stackTrace) {
      log(
        'Error deleting investment and creating redemption transaction',
        error: e,
        stackTrace: stackTrace,
        name: 'InvestmentService',
      );

      throw InvestmentException(
        'Ocorreu um erro ao resgatar o investimento. Tente novamente.',
      );
    }
  }

  // ok
  Future<List<Investment>> getInvestments({required String userId}) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('investments')
        .orderBy('investedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Investment(
        id: doc.id,
        name: data['name'] ?? '',
        amount: (data['amount'] ?? 0.0).toDouble(),
        category: data['category'] ?? '',
        type: data['type'] ?? '',
        investedAt: (data['investedAt'] as Timestamp).toDate(),
        balanceId: data['balanceId'] ?? '',
      );
    }).toList();
  }
}
