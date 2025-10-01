import 'package:bytebank/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_notifier.dart';
import 'package:bytebank/features/transactions/screens/edit_transaction_screen.dart';
import 'package:bytebank/features/transactions/widgets/transaction_list_item.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  static const String routeName = '/transactions';
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final TransactionNotifier _transactionNotifier;
  late final ScrollController _scrollController;
  late AnimationController _loadingController;
  final int _itemsPerPage = 5;
  int _currentMax = 5;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

  _transactionNotifier = context.read<TransactionNotifier>();
  _scrollController = ScrollController();
  _scrollController.addListener(_onScroll);

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _searchController.addListener(() {
      context.read<TransactionNotifier>().updateSearchText(
        _searchController.text,
      );
      // reset pagination when searching
      setState(() {
        _currentMax = _itemsPerPage;
      });
      // scroll to top so user sees first page
      if (_scrollController.hasClients) {
        try {
          _scrollController.jumpTo(0);
        } catch (_) {}
      }
    });

    // Schedule initial fetch after first frame in a microtask to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() => _fetchData());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _transactionNotifier.resetFilters();
  _scrollController.removeListener(_onScroll);
  _scrollController.dispose();
  _loadingController.dispose();

    super.dispose();
  }

  Future<void> _fetchData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await context.read<TransactionNotifier>().fetchTransactions(userId);

      // reset pagination after fresh load to first page or available total
      final total = context.read<TransactionNotifier>().visibleTransactions.length;
      debugPrint('[transactions] fetchData -> total=$total');

      if (!mounted) return;
      setState(() {
        _currentMax = total < _itemsPerPage ? total : _itemsPerPage;
      });
    }
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (!_scrollController.hasClients) return;
    try {
      final notifier = context.read<TransactionNotifier>();
      final total = notifier.visibleTransactions.length;
      if (total <= _currentMax) {
        debugPrint('[transactions] onScroll: no more to load (total=$total currentMax=$_currentMax)');
        return;
      }
      final pos = _scrollController.position;
      debugPrint('[transactions] onScroll: extentAfter=${pos.extentAfter}, pixels=${pos.pixels}, currentMax=$_currentMax, total=$total');
      // if at bottom edge (not top), load more
      if (pos.atEdge && pos.pixels != 0) {
        _loadMoreItems();
        return;
      }
      // fallback: when within 300px of bottom
      if (pos.extentAfter < 300) {
        _loadMoreItems();
      }
    } catch (_) {}
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore) return;
    final notifier = context.read<TransactionNotifier>();
    final total = notifier.visibleTransactions.length;
    if (_currentMax >= total) {
      debugPrint('[transactions] loadMore: nothing to load (currentMax=$_currentMax total=$total)');
      return; // nothing to load
    }

    final old = _currentMax;
    final newMax = (_currentMax + _itemsPerPage).clamp(0, total);
    debugPrint('[transactions] loadMore: old=$old new=$newMax total=$total');

    if (!mounted) return;

    // show loading overlay and simulate 3s load when loading more
    setState(() {
      _isLoadingMore = true;
    });
    _loadingController.repeat();

    // artificial delay for UX
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    _loadingController.stop();
    _loadingController.reset();
    setState(() {
      _currentMax = newMax;
      _isLoadingMore = false;
    });
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    String transactionId,
  ) async {
    final notifier = context.read<TransactionNotifier>();
    final balanceNotifier = context.read<BalanceNotifier>();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Você tem certeza que deseja excluir esta transação? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.brandSecondary),),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar', style: TextStyle(color: AppColors.brandSecondary),),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.deleteTransaction(
        userId: userId,
        transactionId: transactionId,
      );
      await balanceNotifier.fetchBalances(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
  final notifier = context.watch<TransactionNotifier>();
  final state = notifier.state;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  // pagination slice: only render up to _currentMax items even if notifier has more
  final int _totalTransactions = notifier.visibleTransactions.length;
  final int _shownCount = _currentMax.clamp(0, _totalTransactions);
  final visibleSlice = notifier.visibleTransactions.take(_shownCount).toList();

    return Scaffold(
      body: Stack(children: [
        RefreshIndicator(
          onRefresh: _fetchData,
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifier.state.transactions.isEmpty
                  ? const Center(
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Você não possui transações.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            'Suas transações e investimentos aparecem aqui.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: TextField(
                                      controller: _searchController,
                                      cursorColor: AppColors.textSubtle,
                                      decoration: const InputDecoration(
                                        hintText: 'Pesquise uma transação',
                                        prefixIcon: Icon(Icons.search),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                          borderSide: BorderSide(
                                            color: AppColors.lightGreenColor, // Set your desired border color for the enabled state
                                            width: 2.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.lightGreenColor, // Set your desired border color for the focused state
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded (
                                    flex: 1,
                                    child: IconButton (
                                      icon: const Icon(
                                        Icons.calendar_today, 
                                        size: 30, 
                                        color: AppColors.lightGreenColor,
                                      ),
                                      onPressed: () =>
                                        notifier.updateDateRange(context, userId),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: _shownCount + (_shownCount < _totalTransactions ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    // loading indicator row
                                    if (index >= _shownCount) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12.0),
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }

                                    // sentinel: when last visible item is built, request more
                                    if (index == _shownCount - 1 && _shownCount < _totalTransactions) {
                                      Future.microtask(() => _loadMoreItems());
                                    }

                                    final transaction = visibleSlice[index];

                              final bool isInvestmentTransaction =
                                  transaction.category == 'INVESTMENT' ||
                                  transaction.category == 'INVESTMENT_REDEMPTION';

                              return TransactionListItem(
                                transaction: transaction,
                                categoryLabel: notifier.getCategoryLabel(
                                  transaction.category,
                                ),
                                onDelete: () =>
                                    _showDeleteConfirmation(context, transaction.id),
                                onEdit: () {
                                  Navigator.of(context).pushNamed(
                                    EditTransactionScreen.routeName,
                                    arguments: transaction,
                                  );
                                },
                                isReadOnly: isInvestmentTransaction,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
        ),          
      ]),
    );
  }
}
