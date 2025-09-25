import 'package:bytebank/core/widgets/main_app_bar.dart';
import 'package:bytebank/features/investments/screens/create_investment_screen.dart';
import 'package:bytebank/features/transactions/screens/create_transaction_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/features/investments/notifiers/investment_notifier.dart';
import 'package:provider/provider.dart';

import 'package:bytebank/features/transactions/notifiers/transaction_notifier.dart';
import 'package:bytebank/features/transactions/utils/transaction_helpers.dart';
import 'package:bytebank/features/dashboard/widgets/action_card.dart';

class ExpenseControlScreen extends StatefulWidget {
  static const String routeName = '/expense-control';

  const ExpenseControlScreen({super.key});

  @override
  State<ExpenseControlScreen> createState() => _ExpenseControlScreenState();
}

class _ExpenseControlScreenState extends State<ExpenseControlScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<InvestmentNotifier>().fetchInvestments(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use context.watch to listen for changes in the notifier's state.
    final transactionState = context.watch<TransactionNotifier>().state;

    return Scaffold(
      appBar: MainAppBar(title: 'Controle de Despesas'),
      body: transactionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _fetchData(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildChart(transactionState),
                  const SizedBox(height: 24),
                  _buildSummaryCards(transactionState),
                  const SizedBox(height: 24),
                  _buildTransactionList(transactionState),
                ],
              ),
            ),
    );
  }

  Widget _buildChart(TransactionState state) {
    // Create a list of colors for the chart sections
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.red,
    ];

    final chartData = state.chartData.entries.toList();

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: List.generate(chartData.length, (index) {
                  final entry = chartData[index];
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: entry.value,
                    title: '', // We use the legend instead
                    radius: 50,
                  );
                }),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: chartData.length,
              itemBuilder: (context, index) {
                final entry = chartData[index];
                final label = context
                    .read<TransactionNotifier>()
                    .getCategoryLabel(entry.key);
                final iconData = getIconForCategory(entry.key);
                return ListTile(
                  leading: Icon(iconData, color: colors[index % colors.length]),
                  title: Text(
                    label,
                    textHeightBehavior: TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 0.0,
                  ),
                  minVerticalPadding: 0.0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(TransactionState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ActionCard(
          icon: Icons.swap_horiz,
          label: 'Fazer uma\ntransação',
          onTap: () {
            Navigator.of(context).pushNamed(CreateTransactionScreen.routeName);
          },
        ),
        ActionCard(
          icon: Icons.bar_chart,
          label: 'Fazer um\ninvestimento',
          onTap: () {
            Navigator.of(context).pushNamed(CreateInvestmentScreen.routeName);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionList(TransactionState transactionState) {
    if (transactionState.transactions.isEmpty) {
      return const Center(child: Text('Você ainda não possui transações.'));
    }
    // Agrupa valores por categoria, excluindo depósitos
    final Map<String, double> categoryTotals = {};
    for (final transaction in transactionState.transactions) {
      if (transaction.amount > 0) continue;
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text('Nenhuma transação (exceto investimentos) encontrada.'),
      );
    }
    final entries = categoryTotals.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final label = context.read<TransactionNotifier>().getCategoryLabel(
              entry.key,
            );
            final iconData = getIconForCategory(entry.key);
            final value = entry.value;
            return ActionCard(
              icon: iconData,
              label: '$label\nR\$ ${(value * -1).toStringAsFixed(2)}',
              onTap: () {},
            );
          },
        ),
      ],
    );
  }
}
