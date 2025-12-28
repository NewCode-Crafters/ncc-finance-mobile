import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/domain/entities/investment.dart';

class InvestmentDTO {
  final String id;
  final String name;
  final double amount;
  final String category;
  final String type;
  final Timestamp investedAt;
  final String balanceId;

  InvestmentDTO({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.type,
    required this.investedAt,
    required this.balanceId,
  });

  factory InvestmentDTO.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return InvestmentDTO(
      id: doc.id,
      name: data['name'] as String,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
      type: data['type'] as String,
      investedAt: data['investedAt'] as Timestamp,
      balanceId: data['balanceId'] as String,
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'category': category,
      'type': type,
      'investedAt': investedAt,
      'balanceId': balanceId,
    };
  }

  InvestmentDTO copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
    String? type,
    Timestamp? investedAt,
    String? balanceId,
  }) {
    return InvestmentDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      investedAt: investedAt ?? this.investedAt,
      balanceId: balanceId ?? this.balanceId,
    );
  }

  Investment toDomain() {
    return Investment(
      id: id,
      name: name,
      amount: amount,
      category: category,
      type: type,
      investedAt: investedAt.toDate(),
      balanceId: balanceId,
    );
  }
}
