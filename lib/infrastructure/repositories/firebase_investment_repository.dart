import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/domain/repositories/investment_repository.dart';
import 'package:bytebank/domain/exceptions/investment_exception.dart';
import 'package:bytebank/domain/repositories/financial_transaction_repository.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_data_source.dart';
import 'package:bytebank/infrastructure/mappers/financial_transaction_mapper.dart';
import 'package:bytebank/infrastructure/repositories/firebase_transaction_repository.dart';
import 'package:bytebank/domain/entities/financial_transaction.dart';

class FirebaseInvestmentRepository implements IInvestmentRepository {
  final FirebaseFirestore _firestore;
  final IFinancialTransactionRepository _transactionService;

  FirebaseInvestmentRepository({
    FirebaseFirestore? firestore,
    IFinancialTransactionRepository? transactionService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _transactionService =
           transactionService ??
           // If no repository provided, construct a default FirebaseTransactionRepository
           // that uses the same firestore instance. This keeps backward compatibility
           // for callers that don't inject the repository.
           FirebaseTransactionRepository(
             dataSource: FirebaseTransactionDataSource(
               firestore: firestore ?? FirebaseFirestore.instance,
             ),
             mapper: const FinancialTransactionMapper(),
             currentUserId: null,
           );

  @override
  Future<Investment> createInvestment({
    required String userId,
    required Investment investment,
  }) async {
    final investmentAmount = investment.amount;
    final balanceId = investment.balanceId;

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

      final investmentData = {
        'name': investment.name,
        'amount': investment.amount,
        'category': investment.category,
        'type': investment.type,
        'investedAt': Timestamp.fromDate(investment.investedAt),
        'balanceId': investment.balanceId,
      };

      batch.set(investmentRef, investmentData);

      final tx = FinancialTransactionEntity(
        id: '',
        amount: -investment.amount,
        balanceId: investment.balanceId,
        category: 'INVESTMENT',
        date: investment.investedAt,
        description: investment.name,
      );

      await _transactionService.createTransaction(tx, batch: batch);

      await batch.commit();

      return investment.copyWith(id: investmentRef.id);
    } catch (e) {
      if (e is! InsufficientFundsException) {
        throw InvestmentException('Failed to create investment.');
      }
      rethrow;
    }
  }

  @override
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
      final redemptionTx = FinancialTransactionEntity(
        id: '',
        amount: investmentData['amount'],
        balanceId: investmentData['balanceId'],
        category: 'INVESTMENT_REDEMPTION',
        date: DateTime.now(),
        description: 'Resgate de ${investmentData['name']}',
      );

      await _transactionService.createTransaction(redemptionTx, batch: batch);

      await batch.commit();
    } catch (e, stackTrace) {
      log(
        'Error deleting investment and creating redemption transaction',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseInvestmentRepository',
      );

      throw InvestmentException(
        'Ocorreu um erro ao resgatar o investimento. Tente novamente.',
      );
    }
  }

  @override
  Future<Investment> getInvestmentById({
    required String userId,
    required String investmentId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('investments')
        .doc(investmentId)
        .get();

    if (!doc.exists) throw Exception('Investment not found');

    final data = doc.data()!;

    return Investment(
      id: doc.id,
      name: data['name'] as String,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
      type: data['type'] as String,
      investedAt: (data['investedAt'] as Timestamp).toDate(),
      balanceId: data['balanceId'] as String,
    );
  }

  @override
  Future<List<Investment>> getInvestments({required String userId}) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('investments')
        .orderBy('investedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      final name = (data['name'] as String?) ?? '';
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final category = (data['category'] as String?) ?? '';
      final type = (data['type'] as String?) ?? '';
      final investedAtTs = data['investedAt'] as Timestamp?;
      final investedAt = investedAtTs != null
          ? investedAtTs.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0);
      final balanceId = (data['balanceId'] as String?) ?? '';

      return Investment(
        id: doc.id,
        name: name,
        amount: amount,
        category: category,
        type: type,
        investedAt: investedAt,
        balanceId: balanceId,
      );
    }).toList();
  }

  @override
  Stream<List<Investment>> listenInvestments({required String userId}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('investments')
        .orderBy('investedAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((doc) {
            final data = doc.data();
            return Investment(
              id: doc.id,
              name: data['name'] as String,
              amount: (data['amount'] as num).toDouble(),
              category: data['category'] as String,
              type: data['type'] as String,
              investedAt: (data['investedAt'] as Timestamp).toDate(),
              balanceId: data['balanceId'] as String,
            );
          }).toList();
        });
  }

  @override
  Future<Investment> updateInvestment({
    required String userId,
    required Investment investment,
  }) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('investments')
        .doc(investment.id);

    final data = {
      'name': investment.name,
      'amount': investment.amount,
      'category': investment.category,
      'type': investment.type,
      'investedAt': Timestamp.fromDate(investment.investedAt),
      'balanceId': investment.balanceId,
    };

    await ref.set(data, SetOptions(merge: true));

    return investment;
  }
}
