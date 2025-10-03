import 'package:bytebank/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_notifier.dart';
import 'package:bytebank/features/transactions/screens/edit_transaction_screen.dart';
import 'package:bytebank/features/transactions/widgets/transaction_list_item.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class TransactionsScreen extends StatefulWidget {
  static const String routeName = '/transactions';
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  late final TransactionNotifier _transactionNotifier;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _transactionNotifier = context.read<TransactionNotifier>();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _searchController.addListener(() {
      final text = _searchController.text;
      // debounce search input
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 1500), () {
        final notifier = context.read<TransactionNotifier>();
        // avoid triggering a fetch if the search text didn't actually change
        if (notifier.state.searchText == text) return;
        notifier.updateSearchText(text);
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) Future.microtask(() => notifier.fetchFirstPage(userId));
        if (_scrollController.hasClients) {
          try {
            _scrollController.jumpTo(0);
          } catch (_) {}
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() => _fetchData());
    });
  }

  @override
  void dispose() {
  _searchDebounce?.cancel();
  _searchController.dispose();
    _transactionNotifier.resetFilters();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await context.read<TransactionNotifier>().fetchTransactions(userId);
      final total = context.read<TransactionNotifier>().visibleTransactions.length;
      //debugPrint('[transactions] fetchData -> total=$total');
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    try {
      final notifier = context.read<TransactionNotifier>();
  if (notifier.isFetchingMore) return;
  if (!notifier.hasMore) return;
  final pos = _scrollController.position;
      //debugPrint('[transactions] onScroll: extentAfter=${pos.extentAfter}, pixels=${pos.pixels}');
      if (pos.atEdge && pos.pixels != 0) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) Future.microtask(() => notifier.fetchNextPage(userId));
        return;
      }
      if (pos.extentAfter < 300) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) Future.microtask(() => notifier.fetchNextPage(userId));
      }
    } catch (_) {}
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

    final transactions = notifier.visibleTransactions;
    final int total = transactions.length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifier.state.transactions.isEmpty && _searchController.text.isEmpty
                ? const Center(
                    child: Column(
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
                                          color: AppColors.lightGreenColor,
                                          width: 2.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.lightGreenColor,
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
                          itemCount: total + ((notifier.isFetchingMore && notifier.hasMore) ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= total) {
                              // show footer loader only when there are more pages
                              if (notifier.isFetchingMore && notifier.hasMore) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              return const SizedBox.shrink();
                            }

                            if (index == total - 1 && !notifier.isFetchingMore && notifier.hasMore) {
                              Future.microtask(() => notifier.fetchNextPage(userId));
                            }

                            final transaction = transactions[index];
                            final bool isInvestmentTransaction =
                                transaction.category == 'INVESTMENT' ||
                                transaction.category == 'INVESTMENT_REDEMPTION';

                            return TransactionListItem(
                              transaction: transaction,
                              categoryLabel: notifier.getCategoryLabel(
                                transaction.category,
                              ),
                              onDelete: () => _showDeleteConfirmation(context, transaction.id),
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
    );
  }
}

