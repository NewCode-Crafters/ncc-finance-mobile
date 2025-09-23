import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_notifier.dart';
import 'package:bytebank/features/transactions/screens/edit_transaction_screen.dart';
import 'package:bytebank/features/transactions/widgets/transaction_list_item.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  static const String routeName = '/transactions';
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  late final TransactionNotifier _transactionNotifier;
  int selectedTab = 0;


  @override
  void initState() {
    super.initState();

    _transactionNotifier = context.read<TransactionNotifier>();

    _searchController.addListener(() {
      context.read<TransactionNotifier>().updateSearchText(
        _searchController.text,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _transactionNotifier.resetFilters();

    super.dispose();
  }

  Future<void> _fetchData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await context.read<TransactionNotifier>().fetchTransactions(userId);
    }
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
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Pesquisar por descrição ou categoria...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          '${DateFormat('dd/MM/yy').format(state.startDate)} - ${DateFormat('dd/MM/yy').format(state.endDate)}',
                        ),
                        onPressed: () =>
                            notifier.updateDateRange(context, userId),
                      ),
                      const Spacer(),
                      // Card(
                      //   child: InkWell(
                      //     onTap: () {
                      //       Navigator.of(
                      //         context,
                      //       ).pushNamed(CreateTransactionScreen.routeName);
                      //     },
                      //     child: const Padding(
                      //       padding: EdgeInsets.symmetric(
                      //         horizontal: 12.0,
                      //         vertical: 8.0,
                      //       ),
                      //       child: Row(
                      //         children: [
                      //           Icon(Icons.add),
                      //           SizedBox(width: 8),
                      //           Text('Nova Transação'),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifier.visibleTransactions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhuma transação encontrada',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            'Tente ajustar o filtro de data ou a sua busca.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: notifier.visibleTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = notifier.visibleTransactions[index];

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

    );
  }
}
