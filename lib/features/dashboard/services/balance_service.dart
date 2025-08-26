import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/features/dashboard/models/balance.dart';

class BalanceService {
  final FirebaseFirestore _firestore;

  BalanceService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Balance>> getBalances({required String userId}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .get();

      return snapshot.docs.map((doc) => Balance.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch balances.');
    }
  }

  Future<void> updateBalanceOnTransaction({
    required String userId,
    required String balanceId,
    required double transactionAmount,
    WriteBatch? batch,
  }) async {
    try {
      final balanceDocRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('balances')
          .doc(balanceId);

      final writeBatch = batch ?? _firestore.batch();

      writeBatch.update(balanceDocRef, {
        // FieldValue.increment is an atomic operation.
        // It safely adds the given value to the field.
        // Since our expenses are negative, this correctly subtracts.
        'amount': FieldValue.increment(transactionAmount),
      });

      // Only commit the write if we created the batch inside this method.
      if (batch == null) {
        await writeBatch.commit();
      }
    } catch (e) {
      throw Exception('Failed to update balance.');
    }
  }
}
