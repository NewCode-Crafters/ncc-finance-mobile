import 'package:bytebank/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/core/services/metadata_service.dart';
import 'package:bytebank/features/transactions/models/financial_transaction.dart';
import 'package:bytebank/features/transactions/services/financial_transaction_service.dart';

class TransactionState {
  final List<FinancialTransaction> transactions;
  final List<FinancialTransaction> allTransactions;
  final List<TransactionCategory> categories;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String? successMessage;
  final String searchText;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, double> chartData;
  final int displayedItemsCount;
  final bool hasMore;

  TransactionState({
    this.allTransactions = const [],
    this.transactions = const [],
    this.categories = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.successMessage,
    DateTime? startDate, // Make nullable for default
    DateTime? endDate,
    this.searchText = '',
    this.chartData = const {},
    this.displayedItemsCount = 3, // Começar com 3 itens
    this.hasMore = true,
  }) : startDate = startDate ?? DateTime.now().subtract(const Duration(days: 30)),
       endDate = endDate ?? DateTime.now();

  TransactionState copyWith({
    List<FinancialTransaction>? allTransactions,
    List<FinancialTransaction>? transactions,
    List<TransactionCategory>? categories,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? successMessage,
    String? searchText,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, double>? chartData,
    int? displayedItemsCount,
    bool? hasMore,
  }) {
    return TransactionState(
      allTransactions: allTransactions ?? this.allTransactions,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      successMessage: successMessage,
      searchText: searchText ?? this.searchText,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      chartData: chartData ?? this.chartData,
      displayedItemsCount: displayedItemsCount ?? this.displayedItemsCount,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class TransactionNotifier extends ChangeNotifier {
  final FinancialTransactionService _transactionService;
  final MetadataService _metadataService;

  TransactionState _state = TransactionState();
  TransactionState get state => _state;

  // Pagination state
  DocumentSnapshot? _lastDocument;
  bool _isFetchingMore = false;
  final int _pageSize = 10;
  bool _hasMore = true;
  // Throttle consecutive fetchNextPage calls
  DateTime? _lastFetchMoreAt;
  final Duration _fetchMoreThrottle = const Duration(milliseconds: 500);

  TransactionNotifier(this._transactionService, this._metadataService);

  List<FinancialTransaction> get visibleTransactions {
    final query = _state.searchText.trim().toLowerCase();
    List<FinancialTransaction> filtered;
    
    if (query.isEmpty) {
      filtered = _state.transactions;
    } else {
      filtered = _state.allTransactions.where((t) {
        final descriptionMatch =
            t.description?.toLowerCase().contains(query) ?? false;
        final categoryMatch = getCategoryLabel(
          t.category,
        ).toLowerCase().contains(query);
        return descriptionMatch || categoryMatch;
      }).toList();
    }

    // Retorna apenas os itens que devem ser exibidos (lazy loading)
    final maxItems = _state.displayedItemsCount;
    if (filtered.length > maxItems) {
      return filtered.take(maxItems).toList();
    }
    return filtered;
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
    // initial load (first page)
    await fetchFirstPage(userId);
  }

  Future<void> fetchFirstPage(String userId) async {
    _state = _state.copyWith(isLoading: true);
  _lastDocument = null;
  _hasMore = true;
    notifyListeners();

    try {
      final snapshot = await _transactionService.getTransactionsPage(
        userId: userId,
        startDate: _state.startDate,
        endDate: _state.endDate,
        startAfterDoc: null,
        limit: _pageSize,
      );

      final allTransactions = await _transactionService.getTransactions(
        userId: userId,
        startDate: _state.startDate,
        endDate: _state.endDate,
      );

      final categories = _state.categories.isEmpty
          ? await _metadataService.getTransactionCategories()
          : _state.categories;

      final transactions = snapshot.docs
          .map((doc) => FinancialTransaction.fromFirestore(doc))
          .toList();

      // save last doc for pagination — if fewer than pageSize results, no more pages
      if (snapshot.docs.length < _pageSize) {
        _lastDocument = null;
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMore = _lastDocument != null;
      }

      // compute chartData across fetched page (you can aggregate across all loaded pages if desired)
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
        transactions: transactions,
        categories: categories,
        isLoading: false,
        chartData: chartData,
        displayedItemsCount: 3, // Reset para 3 itens ao carregar
        hasMore: transactions.length > 3, // Verifica se há mais itens
      );
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchNextPage(String userId) async {
    if (_isFetchingMore) return;
    if (!_hasMore) return; // early return when there are truly no more pages

    // throttle rapid consecutive calls
    final now = DateTime.now();
    if (_lastFetchMoreAt != null && now.difference(_lastFetchMoreAt!) < _fetchMoreThrottle) {
      return;
    }
    _lastFetchMoreAt = now;
    // also guard when lastDocument is null
    if (_lastDocument == null) return; // no more pages

    _isFetchingMore = true;
    notifyListeners();

    try {
      final snapshot = await _transactionService.getTransactionsPage(
        userId: userId,
        startDate: _state.startDate,
        endDate: _state.endDate,
        startAfterDoc: _lastDocument,
        limit: _pageSize,
      );

      final allTransactions = await _transactionService.getTransactions(
        userId: userId,
        startDate: _state.startDate,
        endDate: _state.endDate,
      );


      final more = snapshot.docs
          .map((doc) => FinancialTransaction.fromFirestore(doc))
          .toList();

      // update last doc — determine if there are more pages
      if (snapshot.docs.length < _pageSize) {
        _lastDocument = null;
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMore = _lastDocument != null;
      }

      // append
      final updated = List<FinancialTransaction>.from(_state.transactions)
        ..addAll(more);

      // recompute chartData across all loaded transactions
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
        transactions: updated,
        chartData: chartData,
      );
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
    // Handle special investment categories
    if (categoryId == 'INVESTMENT') {
      return 'Investimento';
    }
    if (categoryId == 'INVESTMENT_REDEMPTION') {
      return 'Resgate de Investimento';
    }
    
    try {
      return _state.categories.firstWhere((c) => c.id == categoryId).label;
    } catch (e) {
      return categoryId; // Fallback to ID if not found
    }
  }

  void updateSearchText(String text) {
    _state = _state.copyWith(
      searchText: text,
      displayedItemsCount: 3, // Reset para 3 itens ao pesquisar
    );
    notifyListeners();
  }

  Future<void> loadMoreTransactions() async {
    if (_state.isLoadingMore || !_state.hasMore) return;

    _state = _state.copyWith(isLoadingMore: true);
    notifyListeners();

    // Simula delay de carregamento
    await Future.delayed(const Duration(milliseconds: 500));

    final currentCount = _state.displayedItemsCount;
    final newCount = currentCount + 3; // Carregar mais 3 itens
    final totalItems = _state.searchText.isEmpty 
        ? _state.transactions.length 
        : _state.allTransactions.where((t) {
            final descriptionMatch = t.description?.toLowerCase().contains(_state.searchText.toLowerCase()) ?? false;
            final categoryMatch = getCategoryLabel(t.category).toLowerCase().contains(_state.searchText.toLowerCase());
            return descriptionMatch || categoryMatch;
          }).length;

    _state = _state.copyWith(
      isLoadingMore: false,
      displayedItemsCount: newCount,
      hasMore: newCount < totalItems,
    );
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
