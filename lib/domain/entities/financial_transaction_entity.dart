import 'package:equatable/equatable.dart';

/// Domain entity for financial transactions.
class FinancialTransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String balanceId;
  final String category;
  final DateTime date;
  final String? description;

  const FinancialTransactionEntity({
    required this.id,
    required this.amount,
    required this.balanceId,
    required this.category,
    required this.date,
    this.description,
  });

  /// Business rule helpers
  bool get isExpense => amount < 0;
  bool get isIncome => amount >= 0;

  FinancialTransactionEntity copyWith({
    String? id,
    double? amount,
    String? balanceId,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return FinancialTransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      balanceId: balanceId ?? this.balanceId,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    balanceId,
    category,
    date,
    description,
  ];
}

// Backwards-compatible alias: many files in the codebase still refer to
// `FinancialTransaction`. Provide a type alias so those references continue
// to work while the code migrates toward domain entities.
typedef FinancialTransaction = FinancialTransactionEntity;
