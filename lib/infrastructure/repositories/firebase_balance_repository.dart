import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/domain/entities/balance.dart' as domain;
import 'package:bytebank/domain/repositories/balance_repository.dart';

/// Firestore-backed implementation of [IBalanceRepository].
class FirebaseBalanceRepository implements IBalanceRepository {
  final FirebaseFirestore _firestore;

  FirebaseBalanceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _balancesRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('balances');

  domain.Balance _mapDocToDomain(String id, Map<String, dynamic>? data) {
    final accountType = data?['accountType'] as String? ?? '';
    final rawAmount = data?['amount'] ?? 0.0;
    final amount = rawAmount is double
        ? rawAmount
        : (rawAmount as num).toDouble();
    final currency = data?['currency'] as String? ?? 'BRL';
    final updatedAtData = data?['updatedAt'];
    DateTime updatedAt;
    if (updatedAtData is Timestamp) {
      updatedAt = updatedAtData.toDate();
    } else if (updatedAtData is String) {
      updatedAt = DateTime.tryParse(updatedAtData) ?? DateTime.now();
    } else {
      updatedAt = DateTime.now();
    }

    return domain.Balance(
      id: id,
      accountId: id,
      accountType: accountType,
      amount: amount,
      currency: currency,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<domain.Balance> createBalance({
    required String userId,
    required domain.Balance balance,
  }) async {
    final ref = _balancesRef(userId).doc(balance.id);
    final data = {
      'accountType': balance.accountType,
      'amount': balance.amount,
      'currency': balance.currency,
      'updatedAt': Timestamp.fromDate(balance.updatedAt),
    };
    await ref.set(data);
    return balance;
  }

  @override
  Future<domain.Balance> getBalanceById({
    required String userId,
    required String balanceId,
  }) async {
    final doc = await _balancesRef(userId).doc(balanceId).get();
    return _mapDocToDomain(doc.id, doc.data() as Map<String, dynamic>?);
  }

  @override
  Future<List<domain.Balance>> getBalances({required String userId}) async {
    final snapshot = await _balancesRef(userId).get();
    return snapshot.docs
        .map((d) => _mapDocToDomain(d.id, d.data() as Map<String, dynamic>?))
        .toList();
  }

  @override
  Stream<List<domain.Balance>> listenBalances({required String userId}) {
    return _balancesRef(userId).snapshots().map(
      (snap) => snap.docs
          .map((d) => _mapDocToDomain(d.id, d.data() as Map<String, dynamic>?))
          .toList(),
    );
  }

  @override
  Future<domain.Balance> updateBalance({
    required String userId,
    required domain.Balance balance,
  }) async {
    final ref = _balancesRef(userId).doc(balance.id);
    final data = {
      'accountType': balance.accountType,
      'amount': balance.amount,
      'currency': balance.currency,
      'updatedAt': Timestamp.fromDate(balance.updatedAt),
    };
    await ref.set(data, SetOptions(merge: true));
    return balance;
  }

  @override
  Future<void> updateBalanceByDelta({
    required String userId,
    required String balanceId,
    required double delta,
    Object? batch,
  }) async {
    final ref = _balancesRef(userId).doc(balanceId);
    final writeBatch = (batch != null && batch is WriteBatch)
        ? batch
        : _firestore.batch();

    writeBatch.update(ref, {'amount': FieldValue.increment(delta)});

    // If we created the batch inside this method, commit it now.
    if (batch == null) {
      await writeBatch.commit();
    }
  }
}
