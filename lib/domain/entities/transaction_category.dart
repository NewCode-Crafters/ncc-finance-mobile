import 'package:equatable/equatable.dart';

class TransactionCategory extends Equatable {
  final String id;
  final String label;
  final String type; // 'income' or 'expense'

  const TransactionCategory({
    required this.id,
    required this.label,
    required this.type,
  });

  @override
  List<Object?> get props => [id, label, type];
}
