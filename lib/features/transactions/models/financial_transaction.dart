import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialTransaction {
  final String id;
  final double amount;
  final String balanceId;
  final String category;
  final DateTime date;
  final String? description;

  FinancialTransaction({
    required this.id,
    required this.amount,
    required this.balanceId,
    required this.category,
    required this.date,
    this.description,
  });

  factory FinancialTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FinancialTransaction(
      id: doc.id,
      amount: (data['amount'] ?? 0.0).toDouble(),
      balanceId: data['balanceId'] ?? '',
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'],
    );
  }
}
