import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/metadata_service.dart';
import 'package:flutter_application_1/features/transactions/models/financial_transaction.dart';
import 'package:flutter_application_1/features/transactions/services/financial_transaction_service.dart';

DateTime _startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

class TransactionState {
  final List<FinancialTransaction> transactions;
  final List<TransactionCategory> categories;
  final bool isLoading;
  final String? error;
  final String searchText;
  final DateTime startDate;
  final DateTime endDate;

  TransactionState({
    this.transactions = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    DateTime? startDate, // Make nullable for default
    DateTime? endDate,
    this.searchText = '',
  }) : startDate = startDate ?? _startOfMonth(DateTime.now()),
       endDate = endDate ?? DateTime.now();

  TransactionState copyWith({
    List<FinancialTransaction>? transactions,
    List<TransactionCategory>? categories,
    bool? isLoading,
    String? error,
    String? searchText,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchText: searchText ?? this.searchText,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class TransactionNotifier extends ChangeNotifier {
  final FinancialTransactionService _transactionService;
  final MetadataService _metadataService;

  TransactionState _state = TransactionState();
  TransactionState get state => _state;

  TransactionNotifier(this._transactionService, this._metadataService);

  List<FinancialTransaction> get visibleTransactions {
    final query = _state.searchText.toLowerCase();
    if (query.isEmpty) {
      return _state.transactions;
    }

    return _state.transactions.where((t) {
      final descriptionMatch =
          t.description?.toLowerCase().contains(query) ?? false;
      final categoryMatch = getCategoryLabel(
        t.category,
      ).toLowerCase().contains(query);
      return descriptionMatch || categoryMatch;
    }).toList();
  }

  List<TransactionCategory> get userSelectableCategories {
    final filtered = _state.categories
        .where((c) => c.id != 'INVESTMENT' && c.id != 'INVESTMENT_REDEMPTION')
        .toList();

    filtered.sort((a, b) => a.label.compareTo(b.label));

    return filtered;
  }

  Future<void> fetchTransactions(String userId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final transactions = await _transactionService.getTransactions(
        userId: userId,
        startDate: _state.startDate,
        endDate: _state.endDate,
      );
      final categories = _state.categories.isEmpty
          ? await _metadataService.getTransactionCategories()
          : _state.categories;

      _state = _state.copyWith(
        transactions: transactions,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }
    notifyListeners();
  }

  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) async {
    try {
      await _transactionService.deleteTransaction(
        userId: userId,
        transactionId: transactionId,
      );
      // Refresh the list after deletion
      await fetchTransactions(userId);
    } catch (e) {
      _state = _state.copyWith(error: "Failed to delete transaction.");
      notifyListeners();
    }
  }

  String getCategoryLabel(String categoryId) {
    try {
      return _state.categories.firstWhere((c) => c.id == categoryId).label;
    } catch (e) {
      return categoryId; // Fallback to ID if not found
    }
  }

  void updateSearchText(String text) {
    _state = _state.copyWith(searchText: text);
    notifyListeners();
  }

  Future<void> updateDateRange(BuildContext context, String userId) async {
    final newRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _state.startDate,
        end: _state.endDate,
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'), // Use the locale
    );

    if (newRange != null) {
      _state = _state.copyWith(
        startDate: newRange.start,
        endDate: newRange.end,
      );
      await fetchTransactions(userId);
    }
  }

  void resetFilters() {
    // Create a new default state
    _state = TransactionState();
  }
}
