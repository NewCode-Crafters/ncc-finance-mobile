import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/domain/entities/financial_transaction.dart';

class FinancialTransactionDTO {
  final String id;
  final double amount;
  final String balanceId;
  final String category;
  final DateTime date;
  final String? description;

  FinancialTransactionDTO({
    required this.id,
    required this.amount,
    required this.balanceId,
    required this.category,
    required this.date,
    this.description,
  });

  FinancialTransactionEntity toDomain() {
    return FinancialTransactionEntity(
      id: id,
      amount: amount,
      balanceId: balanceId,
      category: category,
      date: date,
      description: description,
    );
  }

  factory FinancialTransactionDTO.fromMap(String id, Map<String, dynamic> map) {
    return FinancialTransactionDTO(
      id: id,
      amount: ((map['amount'] ?? 0.0) as num).toDouble(),
      balanceId: map['balanceId'] ?? '',
      category: map['category'] ?? '',
      date: (map['date'] is Timestamp)
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date'].toString()),
      description: map['description'],
    );
  }

  factory FinancialTransactionDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialTransactionDTO.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'balanceId': balanceId,
      'category': category,
      'date': date.toIso8601String(), // Use ISO string for cache (not Timestamp)
      'description': description,
    };
  }

  /// Returns a map suitable for Firestore `set`/`update` operations.
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'balanceId': balanceId,
      'category': category,
      'date': Timestamp.fromDate(date),
      'description': description,
    };
  }

  FinancialTransactionDTO copyWith({
    String? id,
    double? amount,
    String? balanceId,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return FinancialTransactionDTO(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      balanceId: balanceId ?? this.balanceId,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
