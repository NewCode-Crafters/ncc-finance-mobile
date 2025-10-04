import 'package:bytebank/core/widgets/main_app_bar.dart';
import 'package:bytebank/theme/theme.dart';
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
                  transactionState.chartData.isEmpty ? Container() : const SizedBox(height: 24),
                  // _buildSummaryCards(transactionState),
                  // const SizedBox(height: 24),
                  _buildTransactionList(transactionState),
                ],
              ),
            ),
    );
  }

  Widget _buildChart(TransactionState state) {
    // Create a list of colors for the chart sections
    final colors = [
      AppColors.chartDarkGreen,
      AppColors.chartGreen,
      AppColors.chartGrayGreen,
      AppColors.chartDarkPurple,
      AppColors.chartPurple,
      AppColors.chartBeige,
      AppColors.chartBlue,
      AppColors.chartYellow,
      AppColors.chartOrange,
    ];

    final chartData = state.chartData.entries.toList();
    if(state.chartData.isEmpty) {
      return const Center(
      );
    }else{
      return SizedBox(
        height: 150,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, animationValue, child) {
                  return PieChart(
                    PieChartData(
                      sections: List.generate(chartData.length, (index) {
                        final entry = chartData[index];
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: entry.value * animationValue,
                          title: '', // We use the legend instead
                          radius: 30 * animationValue,
                          showTitle: false,
                        );
                      }),
                      sectionsSpace: 1,
                      centerSpaceRadius: 50 * animationValue,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: AnimatedList(
                initialItemCount: chartData.length,
                itemBuilder: (context, index, animation) {
                  if (index >= chartData.length) return const SizedBox.shrink();
                  
                  final entry = chartData[index];
                  final label = context
                      .read<TransactionNotifier>()
                      .getCategoryLabel(entry.key);
                  final iconData = getIconForCategory(entry.key);
                  
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuart,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: ListTile(
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTransactionList(TransactionState transactionState) {
    if (transactionState.allTransactions.isEmpty) {
      return const Center(
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
              'Você não possui despesas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Realize uma nova transação do tipo saída para controlar suas despesas.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    // Agrupa valores por categoria, excluindo depósitos
    final Map<String, double> categoryTotals = {};
    for (final transaction in transactionState.allTransactions) {
      if (transaction.category == 'INVESTMENT' ||
          transaction.category == 'INVESTMENT_REDEMPTION' ||
          transaction.amount > 0) {
        continue;
      }
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    if (categoryTotals.isEmpty) {
      return const Center(
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
              'Você não possui despesas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Realize uma nova transação do tipo saída para controlar suas despesas.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
