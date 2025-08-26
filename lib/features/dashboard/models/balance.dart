import 'package:cloud_firestore/cloud_firestore.dart';

class Balance {
  final String id;
  final String accountType;
  final double amount;
  final String currency;

  Balance({
    required this.id,
    required this.accountType,
    required this.amount,
    required this.currency,
  });

  factory Balance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Balance(
      id: doc.id,
      accountType: data['accountType'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'BRL',
    );
  }
}
