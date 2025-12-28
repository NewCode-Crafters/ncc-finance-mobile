import 'package:equatable/equatable.dart';

/// Domain entity for account balances.
class Balance extends Equatable {
  final String id;
  final String accountId;
  final String accountType;
  final double amount;
  final String currency;
  final DateTime updatedAt;

  const Balance({
    required this.id,
    required this.accountId,
    this.accountType = 'checking',
    required this.amount,
    this.currency = 'BRL',
    required this.updatedAt,
  });

  /// Business helpers
  bool get isPositive => amount >= 0;
  bool get isNegative => amount < 0;

  /// Returns a new Balance after applying a transaction amount (positive for credit, negative for debit).
  Balance applyTransaction(double transactionAmount) {
    return copyWith(
      amount: amount + transactionAmount,
      updatedAt: DateTime.now(),
    );
  }

  /// Deposit increases balance by [value]. Returns a new Balance.
  Balance deposit(double value) {
    if (value < 0) {
      throw ArgumentError.value(
        value,
        'value',
        'Deposit value must be positive',
      );
    }
    return applyTransaction(value);
  }

  /// Withdraw decreases balance by [value]. If overdraft is not allowed, it will still produce a negative amount.
  Balance withdraw(double value) {
    if (value < 0) {
      throw ArgumentError.value(
        value,
        'value',
        'Withdraw value must be positive',
      );
    }
    return applyTransaction(-value);
  }

  Balance copyWith({
    String? id,
    String? accountId,
    String? accountType,
    double? amount,
    String? currency,
    DateTime? updatedAt,
  }) {
    return Balance(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountType: accountType ?? this.accountType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    accountId,
    accountType,
    amount,
    currency,
    updatedAt,
  ];
}
