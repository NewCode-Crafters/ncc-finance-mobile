class TransactionCategory {
  final String id;
  final String label;
  final String type; // 'income' or 'expense'

  TransactionCategory({
    required this.id,
    required this.label,
    required this.type,
  });
}
