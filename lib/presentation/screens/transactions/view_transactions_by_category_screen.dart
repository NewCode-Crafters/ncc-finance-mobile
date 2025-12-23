import 'package:bytebank/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:bytebank/application/notifiers/transaction_notifier.dart' as app_notifier;
import 'package:bytebank/application/notifiers/balance_notifier.dart';
import 'package:bytebank/presentation/widgets/transactions/transaction_list_item.dart';
import 'package:bytebank/presentation/screens/transactions/edit_transaction_screen.dart';

class ViewTransactionsByCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryLabel;

  const ViewTransactionsByCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryLabel,
  });

  @override
  State<ViewTransactionsByCategoryScreen> createState() => _ViewTransactionsByCategoryScreenState();
}

class _ViewTransactionsByCategoryScreenState extends State<ViewTransactionsByCategoryScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  late final ScrollController _scrollController;

  Future<void> _showDeleteConfirmation(BuildContext context, String transactionId) async {
    final notifier = context.read<app_notifier.TransactionNotifier>();
    final balanceNotifier = context.read<BalanceNotifier>();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Você tem certeza que deseja excluir esta transação? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.deleteTransaction(userId: userId, transactionId: transactionId);
      await balanceNotifier.fetchBalances(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<app_notifier.TransactionNotifier>();
    final state = notifier.state;
    // Use allTransactions filtered by category and current search text so
    // the list matches the totals shown in ExpenseControlScreen.
    final query = notifier.state.searchText.trim().toLowerCase();
    final transactions = notifier.state.allTransactions.where((t) {
      if (t.category != widget.categoryId) return false;
      if (query.isEmpty) return true;
      final descMatch = t.description?.toLowerCase().contains(query) ?? false;
      final catMatch = notifier.getCategoryLabel(t.category).toLowerCase().contains(query);
      return descMatch || catMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryLabel)),
      backgroundColor: AppColors.surfaceDefault,
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId != null) await notifier.fetchTransactions(userId);
        },
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifier.state.allTransactions.isEmpty && _searchController.text.isEmpty
                ? notifier.state.filteredDate == false
                    ? const Center(child: Text('Nenhuma transação nesta categoria.'))
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
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
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
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.calendar_today,
                                          size: 30,
                                          color: AppColors.lightGreenColor,
                                        ),
                                        onPressed: () => notifier.updateDateRange(context, FirebaseAuth.instance.currentUser!.uid),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            child: Center(child: Text('Nenhuma transação nesta categoria.')),
                          ),
                        ],
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
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
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
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.calendar_today,
                                      size: 30,
                                      color: AppColors.lightGreenColor,
                                    ),
                                    onPressed: () => notifier.updateDateRange(context, FirebaseAuth.instance.currentUser!.uid),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8.0),
                          itemCount: transactions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            final bool isInvestmentTransaction = transaction.category == 'INVESTMENT' || transaction.category == 'INVESTMENT_REDEMPTION';
                            return TransactionListItem(
                              transaction: transaction,
                              categoryLabel: notifier.getCategoryLabel(transaction.category),
                              onDelete: () => _showDeleteConfirmation(context, transaction.id),
                              onEdit: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditTransactionScreen(transaction: transaction)));
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController.addListener(() {
      final text = _searchController.text;
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 1500), () {
        final notifier = context.read<app_notifier.TransactionNotifier>();
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
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
