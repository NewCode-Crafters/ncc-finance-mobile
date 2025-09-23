import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionCategory {
  final String id;
  final String label;
  final String type; // 'income' or 'expense'

  TransactionCategory({
    required this.id,
    required this.label,
    required this.type,
  });

  factory TransactionCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionCategory(
      id: doc.id,
      label: data['label'] ?? '',
      type: data['type'] ?? 'expense',
    );
  }
}

class MetadataService {
  final FirebaseFirestore _firestore;

  MetadataService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<TransactionCategory>> getTransactionCategories() async {
    try {
      final doc = await _firestore
          .collection('metadata')
          .doc('transaction_categories')
          .get();

      if (doc.exists && doc.data()!.containsKey('categories')) {
        final categories = List<Map<String, dynamic>>.from(
          doc.data()!['categories'],
        );

        return categories
            .map(
              (item) => TransactionCategory(
                id: item['id'],
                label: item['label'],
                type: item['type'],
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch transaction categories.');
    }
  }
}
