import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/features/dashboard/models/balance.dart';

class BalanceService {
  final FirebaseFirestore _firestore;

  BalanceService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Balance>> getBalances({required String userId}) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('balances')
        .get();

    return snapshot.docs.map((doc) => Balance.fromFirestore(doc)).toList();
  }

  Future<void> updateBalanceOnTransaction({
    required String userId,
    required String balanceId,
    required double transactionAmount,
  }) async {
    final balanceDocRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('balances')
        .doc(balanceId);

    // FieldValue.increment is an atomic operation.
    // It safely adds the given value to the field.
    // Since our expenses are negative, this correctly subtracts.
    await balanceDocRef.update({
      'amount': FieldValue.increment(transactionAmount),
    });
  }
}
