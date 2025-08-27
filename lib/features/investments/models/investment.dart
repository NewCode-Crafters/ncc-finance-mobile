import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Investment extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String category;
  final String type;
  final DateTime investedAt;
  final String balanceId;

  const Investment({
    required this.id,
    required this.amount,
    required this.name,
    required this.category,
    required this.type,
    required this.balanceId,
    required this.investedAt,
  });

  factory Investment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Investment(
      id: doc.id,
      amount: (data['amount'] ?? 0.0).toDouble(),
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      type: data['type'] ?? '',
      investedAt: (data['investedAt'] as Timestamp).toDate(),
      balanceId: data['balanceId'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    amount,
    category,
    type,
    investedAt,
    balanceId,
  ];
}
