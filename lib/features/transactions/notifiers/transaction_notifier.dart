import 'package:bytebank/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/core/services/metadata_service.dart';
import 'package:bytebank/features/transactions/models/financial_transaction.dart';
import 'package:bytebank/features/transactions/services/financial_transaction_service.dart';

DateTime _startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

class TransactionState {
  final List<FinancialTransaction> transactions;
  final List<TransactionCategory> categories;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final String searchText;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, double> chartData;

  TransactionState({
    this.transactions = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
    DateTime? startDate, // Make nullable for default
    DateTime? endDate,
    this.searchText = '',
    this.chartData = const {},
  }) : startDate = startDate ?? _startOfMonth(DateTime.now()),
       endDate = endDate ?? DateTime.now();

  TransactionState copyWith({
    List<FinancialTransaction>? transactions,
    List<TransactionCategory>? categories,
    bool? isLoading,
    String? error,
    String? successMessage,
    String? searchText,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, double>? chartData,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      searchText: searchText ?? this.searchText,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      chartData: chartData ?? this.chartData,
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

  List<TransactionCategory> _filterAndSort(String type) {
    final filtered = _state.categories
        .where(
          (c) =>
              c.type == type &&
              c.id != 'INVESTMENT' &&
              c.id != 'INVESTMENT_REDEMPTION',
        )
        .toList();
    filtered.sort((a, b) => a.label.compareTo(b.label));
    return filtered;
  }

  List<TransactionCategory> get incomeCategories => _filterAndSort('income');

  List<TransactionCategory> get expenseCategories => _filterAndSort('expense');

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

      // Agrupa valores negativos por categoria, exceto incomes
      final Map<String, double> chartData = {};
      for (final transaction in transactions) {
        if (transaction.category == 'INVESTMENT' ||
            transaction.category == 'INVESTMENT_REDEMPTION' ||
            transaction.amount > 0) continue;
        chartData[transaction.category] =
            (chartData[transaction.category] ?? 0) + transaction.amount.abs();
      }

      _state = _state.copyWith(
        transactions: transactions,
        categories: categories,
        isLoading: false,
        chartData: chartData,
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

      _state = _state.copyWith(
        successMessage: 'Transação excluída com sucesso!',
      );
      notifyListeners();

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
      builder: (BuildContext context, Widget? child) {
      return Theme(
          data: ThemeData(
            primaryColor: AppColors.brandTertiary, // Cor principal (botões e cabeçalho)
            colorScheme: ColorScheme.dark(
              primary: AppColors.brandTertiary, // Cor do botão "OK" e "CANCELAR"
              onPrimary: Colors.white, // Cor do texto nos botões
              onSurface: Colors.white, // Cor do texto no calendário
              secondary: AppColors.lightGreenColor
            ), dialogTheme: DialogThemeData(backgroundColor: AppColors.surfaceDefault), // Cor de fundo do DatePicker
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      _state = _state.copyWith(
        startDate: newRange.start,
        endDate: newRange.end,
      );
      await fetchTransactions(userId);
    }
  }

  Future<void> editTransaction({
    required String userId,
    required String transactionId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _transactionService.editTransaction(
        userId: userId,
        transactionId: transactionId,
        updateData: data,
      );
      await fetchTransactions(userId);
    } catch (e) {
      _state = _state.copyWith(error: "Falha ao editar a transação.");
      notifyListeners();
    }
  }

  void resetFilters() {
    // Create a new default state
    _state = TransactionState();
  }

  void clearSuccessMessage() {
    if (_state.successMessage != null) {
      _state = _state.copyWith(successMessage: null);
    }
  }
}
