import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/domain/exceptions/financial_transaction_exception.dart';
import 'package:bytebank/infrastructure/dtos/financial_transaction_dto.dart';

class FirebaseTransactionDataSource {
  FirebaseTransactionDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _transactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  DocumentReference<Map<String, dynamic>> _balance(
    String userId,
    String balanceId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('balances')
        .doc(balanceId);
  }

  Query<Map<String, dynamic>> _buildBaseQuery(
    String userId, {
    String? balanceId,
  }) {
    var query = _transactions(userId).orderBy('date', descending: true);

    if (balanceId != null) {
      query = query.where('balanceId', isEqualTo: balanceId);
    }

    return query;
  }

  Query<Map<String, dynamic>> _applyDateFilters(
    Query<Map<String, dynamic>> query,
    DateTime? startDate,
    DateTime? endDate,
  ) {
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

    return query;
  }

  Future<FinancialTransactionDTO> createTransaction({
    required String userId,
    required FinancialTransactionDTO transaction,
    WriteBatch? batch,
  }) async {
    if (transaction.balanceId.isEmpty) {
      throw const FinancialTransactionValidationException(
        'Balance id cannot be empty.',
      );
    }

    return _wrapFirestoreCall(() async {
      final transactionId = transaction.id.isNotEmpty
          ? transaction.id
          : _transactions(userId).doc().id;
      final transactionRef = _transactions(userId).doc(transactionId);
      final writeBatch = batch ?? _firestore.batch();

      writeBatch.set(transactionRef, transaction.toFirestore());

      _updateBalance(
        batch: writeBatch,
        userId: userId,
        balanceId: transaction.balanceId,
        transactionAmount: transaction.amount,
      );

      if (batch == null) {
        await writeBatch.commit();
      }

      return transaction.copyWith(id: transactionRef.id);
    }, 'Falha ao criar transação.');
  }

  Future<void> updateTransaction({
    required String userId,
    required FinancialTransactionDTO transaction,
  }) async {
    if (transaction.id.isEmpty) {
      throw const FinancialTransactionValidationException(
        'Transaction id cannot be empty.',
      );
    }

    return _wrapFirestoreCall(() async {
      await _transactions(
        userId,
      ).doc(transaction.id).update(transaction.toFirestore());
    }, 'Falha ao atualizar transação.');
  }

  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) {
    return _wrapFirestoreCall(() async {
      final transactionRef = _transactions(userId).doc(transactionId);
      final transactionDoc = await transactionRef.get();
      final transactionData = transactionDoc.data();

      if (transactionData == null) {
        return;
      }

      final batch = _firestore.batch();
      batch.delete(transactionRef);

      final amountToRevert = (transactionData['amount'] ?? 0.0).toDouble();
      final balanceId = transactionData['balanceId'] as String?;

      if (balanceId != null && balanceId.isNotEmpty) {
        _updateBalance(
          batch: batch,
          userId: userId,
          balanceId: balanceId,
          transactionAmount: -amountToRevert,
        );
      }

      await batch.commit();
    }, 'Falha ao excluir transação.');
  }

  Future<FinancialTransactionDTO?> getTransaction({
    required String userId,
    required String transactionId,
  }) {
    return _wrapFirestoreCall(() async {
      final doc = await _transactions(userId).doc(transactionId).get();
      if (!doc.exists) {
        return null;
      }

      return FinancialTransactionDTO.fromFirestore(doc);
    }, 'Falha ao buscar transação.');
  }

  Future<List<FinancialTransactionDTO>> getTransactions({
    required String userId,
    int limit = 50,
    String? startAfterId,
    String? balanceId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _wrapFirestoreCall(() async {
      var query = _buildBaseQuery(userId, balanceId: balanceId);
      query = _applyDateFilters(query, startDate, endDate);

      if (startAfterId != null && startAfterId.isNotEmpty) {
        final cursor = await _startAfterDocument(userId, startAfterId);
        if (cursor != null) {
          query = query.startAfterDocument(cursor);
        }
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map(FinancialTransactionDTO.fromFirestore).toList();
    }, 'Falha ao buscar transações.');
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTransactionsPage({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDoc,
    required int limit,
    String? searchText,
  }) {
    return _wrapFirestoreCall(() async {
      Query<Map<String, dynamic>> query;

      if (searchText != null && searchText.trim().isNotEmpty) {
        final trimmed = searchText.trim();
        final end = '$trimmed\uf8ff';
        query = _transactions(userId)
            .orderBy('description')
            .where('description', isGreaterThanOrEqualTo: trimmed)
            .where('description', isLessThanOrEqualTo: end);
      } else {
        query = _buildBaseQuery(userId);
        query = _applyDateFilters(query, startDate, endDate);
      }

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      return query.limit(limit).get();
    }, 'Falha ao buscar transações paginadas.');
  }

  Stream<List<FinancialTransactionDTO>> watchTransactions({
    required String userId,
    String? balanceId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var query = _buildBaseQuery(userId, balanceId: balanceId);
    query = _applyDateFilters(query, startDate, endDate);

    return query
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(FinancialTransactionDTO.fromFirestore).toList(),
        )
        .handleError((error, _) {
          throw _wrapStreamException(error, 'Falha ao observar transações.');
        });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _startAfterDocument(
    String userId,
    String documentId,
  ) async {
    final doc = await _transactions(userId).doc(documentId).get();
    return doc.exists ? doc : null;
  }

  void _updateBalance({
    required WriteBatch batch,
    required String userId,
    required String balanceId,
    required double transactionAmount,
  }) {
    batch.update(_balance(userId, balanceId), {
      'amount': FieldValue.increment(transactionAmount),
    });
  }

  Future<T> _wrapFirestoreCall<T>(
    Future<T> Function() action,
    String fallbackMessage,
  ) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      throw FinancialTransactionRepositoryException(
        error.message ?? fallbackMessage,
      );
    } catch (_) {
      throw FinancialTransactionRepositoryException(fallbackMessage);
    }
  }

  FinancialTransactionRepositoryException _wrapStreamException(
    Object error,
    String fallbackMessage,
  ) {
    if (error is FirebaseException) {
      return FinancialTransactionRepositoryException(
        error.message ?? fallbackMessage,
      );
    }

    return FinancialTransactionRepositoryException(fallbackMessage);
  }
}
