import 'package:flutter/material.dart';
import 'package:bytebank/domain/use_cases/transactions/create_transaction_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/get_transactions_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/update_transaction_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/delete_transaction_use_case.dart';
import 'package:bytebank/features/transactions/models/financial_transaction.dart';
import 'package:bytebank/theme/theme.dart';
import 'package:bytebank/core/services/metadata_service.dart';
import 'package:bytebank/domain/entities/financial_transaction_entity.dart';

FinancialTransactionEntity _toEntity(FinancialTransaction t) =>
    FinancialTransactionEntity(
      id: t.id,
      amount: t.amount,
      balanceId: t.balanceId,
      category: t.category,
      date: t.date,
      description: t.description,
    );

FinancialTransaction _fromEntity(FinancialTransactionEntity e) =>
    FinancialTransaction(
      id: e.id,
      amount: e.amount,
      balanceId: e.balanceId,
      category: e.category,
      date: e.date,
      description: e.description,
    );

class TransactionState {
  final List<FinancialTransaction> transactions;
  final List<FinancialTransaction> allTransactions;
  final List<TransactionCategory> categories;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final String searchText;
  final DateTime startDate;
  final DateTime endDate;
  final bool filteredDate;
  final Map<String, double> chartData;

  TransactionState({
    this.allTransactions = const [],
    this.transactions = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
    DateTime? startDate,
    DateTime? endDate,
    this.filteredDate = false,
    this.searchText = '',
    this.chartData = const {},
  }) : startDate =
           startDate ?? DateTime.now().subtract(const Duration(days: 30)),
       endDate = endDate ?? DateTime.now();

  TransactionState copyWith({
    List<FinancialTransaction>? allTransactions,
    List<FinancialTransaction>? transactions,
    List<TransactionCategory>? categories,
    bool? isLoading,
    String? error,
    String? successMessage,
    String? searchText,
    DateTime? startDate,
    DateTime? endDate,
    bool? filteredDate,
    Map<String, double>? chartData,
  }) {
    return TransactionState(
      allTransactions: allTransactions ?? this.allTransactions,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      searchText: searchText ?? this.searchText,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      filteredDate: filteredDate ?? this.filteredDate,
      chartData: chartData ?? this.chartData,
    );
  }
}

class TransactionNotifier extends ChangeNotifier {
  final GetTransactionsUseCase _getUseCase;
  final CreateTransactionUseCase _createUseCase;
  final UpdateTransactionUseCase _updateUseCase;
  final DeleteTransactionUseCase _deleteUseCase;
  final MetadataService _metadataService;

  TransactionState _state = TransactionState();
  TransactionState get state => _state;

  // Pagination state (use last id for cursor)
  String? _lastStartAfterId;
  bool _isFetchingMore = false;
  final int _pageSize = 10;
  bool _hasMore = true;
  DateTime? _lastFetchMoreAt;
  final Duration _fetchMoreThrottle = const Duration(milliseconds: 500);

  TransactionNotifier({
    required GetTransactionsUseCase getUseCase,
    required CreateTransactionUseCase createUseCase,
    required UpdateTransactionUseCase updateUseCase,
    required DeleteTransactionUseCase deleteUseCase,
    required MetadataService metadataService,
  }) : _getUseCase = getUseCase,
       _createUseCase = createUseCase,
       _updateUseCase = updateUseCase,
       _deleteUseCase = deleteUseCase,
       _metadataService = metadataService;

  List<FinancialTransaction> get visibleTransactions {
    final query = _state.searchText.trim().toLowerCase();
    if (query.isEmpty) return _state.transactions;

    final querysemfiltro = _state.searchText.toLowerCase();

    if (querysemfiltro.isEmpty) {
      return _state.transactions;
    }

    return _state.allTransactions.where((t) {
      final descriptionMatch =
          t.description?.toLowerCase().contains(querysemfiltro) ?? false;
      final categoryMatch = getCategoryLabel(
        t.category,
      ).toLowerCase().contains(querysemfiltro);
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
    await fetchFirstPage(userId);
    await fetchAllTransactions(userId);
  }

  Future<void> fetchAllTransactions(String userId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final list = await _getUseCase.call(limit: 1000);
    final allTransactions = list.map(_fromEntity).toList();

    final Map<String, double> chartData = {};
    for (final transaction in allTransactions) {
      if (transaction.category == 'INVESTMENT' ||
          transaction.category == 'INVESTMENT_REDEMPTION' ||
          transaction.amount > 0) {
        continue;
      }
      chartData[transaction.category] =
          (chartData[transaction.category] ?? 0) + transaction.amount.abs();
    }

    _state = _state.copyWith(
      allTransactions: allTransactions,
      isLoading: false,
      chartData: chartData,
    );
    notifyListeners();
  }

  Future<void> fetchFirstPage(String userId) async {
    _state = _state.copyWith(isLoading: true);
    _lastStartAfterId = null;
    _hasMore = true;
    notifyListeners();

    try {
      final list = await _getUseCase.call(limit: _pageSize);

      final categories = _state.categories.isEmpty
          ? await _metadata_service_getCategoriesSafe()
          : _state.categories;

      final transactions = list.map(_fromEntity).toList();

      if (list.length < _pageSize) {
        _lastStartAfterId = null;
        _hasMore = false;
      } else {
        _lastStartAfterId = list.isNotEmpty ? list.last.id : null;
        _hasMore = _lastStartAfterId != null;
      }

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

  Future<List<TransactionCategory>>
  _metadata_service_getCategoriesSafe() async {
    try {
      return await _metadataService.getTransactionCategories();
    } catch (_) {
      return [];
    }
  }

  Future<void> fetchNextPage(String userId) async {
    if (_isFetchingMore) return;
    if (!_hasMore) return;

    final now = DateTime.now();
    if (_lastFetchMoreAt != null &&
        now.difference(_lastFetchMoreAt!) < _fetchMoreThrottle) {
      return;
    }
    _lastFetchMoreAt = now;
    if (_lastStartAfterId == null) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final list = await _getUseCase.call(
        limit: _pageSize,
        startAfterId: _lastStartAfterId,
      );
      final more = list.map(_fromEntity).toList();

      if (list.length < _pageSize) {
        _lastStartAfterId = null;
        _hasMore = false;
      } else {
        _lastStartAfterId = list.isNotEmpty ? list.last.id : null;
        _hasMore = _lastStartAfterId != null;
      }

      final updated = List<FinancialTransaction>.from(_state.transactions)
        ..addAll(more);
      _state = _state.copyWith(transactions: updated);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _isFetchingMore = false;
    notifyListeners();
  }

  bool get isFetchingMore => _isFetchingMore;

  bool get hasMore => _hasMore;

  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) async {
    try {
      await _deleteUseCase.call(transactionId);

      _state = _state.copyWith(
        successMessage: 'Transação excluída com sucesso!',
      );
      notifyListeners();

      await fetchTransactions(userId);
    } catch (e) {
      _state = _state.copyWith(error: 'Failed to delete transaction.');
      notifyListeners();
    }
  }

  String getCategoryLabel(String categoryId) {
    try {
      return _state.categories.firstWhere((c) => c.id == categoryId).label;
    } catch (e) {
      return categoryId;
    }
  }

  void updateSearchText(String text) {
    _state = _state.copyWith(searchText: text);
    notifyListeners();
  }

  // Compatibility: simple loader used by some callers/tests
  Future<void> loadTransactions({int limit = 50}) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final list = await _getUseCase.call(limit: limit);
      final transactions = list.map(_fromEntity).toList();
      _state = _state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }

    notifyListeners();
  }

  Future<void> createTransaction(FinancialTransaction tx) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _createUseCase.call(_toEntity(tx));
      await loadTransactions();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
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
      locale: const Locale('pt', 'BR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: AppColors.brandTertiary,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.brandTertiary,
              onPrimary: Colors.white,
              onSurface: Colors.white,
              secondary: AppColors.lightGreenColor,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surfaceDefault,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      _state = _state.copyWith(
        startDate: newRange.start,
        endDate: newRange.end,
        filteredDate: true,
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
      final entity = FinancialTransactionEntity(
        id: transactionId,
        amount: (data['amount'] ?? 0.0).toDouble(),
        balanceId: data['balanceId'] ?? '',
        category: data['category'] ?? '',
        date: (data['date'] as DateTime?) ?? DateTime.now(),
        description: data['description'],
      );
      await _updateUseCase.call(entity);
      await fetchTransactions(userId);
    } catch (e) {
      _state = _state.copyWith(error: 'Falha ao editar a transação.');
      notifyListeners();
    }
  }

  void resetFilters() {
    _state = TransactionState();
  }

  void clearSuccessMessage() {
    if (_state.successMessage != null) {
      _state = _state.copyWith(successMessage: null);
    }
  }
}
