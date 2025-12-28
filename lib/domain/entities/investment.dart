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
    required this.name,
    required this.amount,
    required this.category,
    required this.type,
    required this.investedAt,
    required this.balanceId,
  });

  Investment copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
    String? type,
    DateTime? investedAt,
    String? balanceId,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      investedAt: investedAt ?? this.investedAt,
      balanceId: balanceId ?? this.balanceId,
    );
  }

  bool get isPositive => amount > 0;

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
