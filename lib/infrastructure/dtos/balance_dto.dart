import 'package:cloud_firestore/cloud_firestore.dart';

class BalanceDTO {
  final String id;
  final String accountType;
  final double amount;
  final String currency;
  final Timestamp? updatedAt;

  BalanceDTO({
    required this.id,
    required this.accountType,
    required this.amount,
    required this.currency,
    this.updatedAt,
  });

  factory BalanceDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawAmount = data['amount'] ?? 0.0;
    final amount = rawAmount is double
        ? rawAmount
        : (rawAmount as num).toDouble();
    return BalanceDTO(
      id: doc.id,
      accountType: data['accountType'] ?? '',
      amount: amount,
      currency: data['currency'] ?? 'BRL',
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'accountType': accountType,
      'amount': amount,
      'currency': currency,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  BalanceDTO copyWith({
    String? accountType,
    double? amount,
    String? currency,
    Timestamp? updatedAt,
  }) {
    return BalanceDTO(
      id: id,
      accountType: accountType ?? this.accountType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
