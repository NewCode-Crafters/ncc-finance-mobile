import 'package:bytebank/core/widgets/main_app_bar.dart';
import 'package:bytebank/core/notifiers/chart_animation_notifier.dart';
import 'package:bytebank/presentation/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/application/notifiers/investment_notifier.dart';
import 'package:provider/provider.dart';

import 'package:bytebank/application/notifiers/transaction_notifier.dart'
    as app_notifier;
import 'package:bytebank/presentation/utils/transaction_helpers.dart';
import 'package:bytebank/presentation/widgets/dashboard/action_card.dart';

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
    final transactionState = context
        .watch<app_notifier.TransactionNotifier>()
        .state;

    return Scaffold(
      appBar: const MainAppBar(title: 'Controle de Despesas'),
      body: transactionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _fetchData(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildChart(transactionState),
                  transactionState.chartData.isEmpty
                      ? Container()
                      : const SizedBox(height: 24),
                  _buildTransactionList(transactionState),
                ],
              ),
            ),
    );
  }

  Widget _buildChart(app_notifier.TransactionState state) {
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
    if (state.chartData.isEmpty) return const Center();
    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Consumer<ChartAnimationNotifier>(
              builder: (context, chartNotifier, child) {
                final shouldAnimate =
                    chartNotifier.shouldAnimateCharts &&
                    chartNotifier.currentTabIndex == 1;
                final isVisible =
                    chartNotifier.chartsVisible &&
                    chartNotifier.currentTabIndex == 1;
                if (shouldAnimate) {
                  return TweenAnimationBuilder<double>(
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
                              title: '',
                              radius: 30 * animationValue,
                              showTitle: false,
                            );
                          }),
                          sectionsSpace: 1,
                          centerSpaceRadius: 50 * animationValue,
                        ),
                      );
                    },
                  );
                } else if (isVisible) {
                  return PieChart(
                    PieChartData(
                      sections: List.generate(chartData.length, (index) {
                        final entry = chartData[index];
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: entry.value,
                          title: '',
                          radius: 30,
                          showTitle: false,
                        );
                      }),
                      sectionsSpace: 1,
                      centerSpaceRadius: 50,
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: chartData.length,
              itemBuilder: (context, index) {
                final entry = chartData[index];
                final label = context
                    .read<app_notifier.TransactionNotifier>()
                    .getCategoryLabel(entry.key);
                final iconData = getIconForCategory(entry.key);
                return ListTile(
                  leading: Icon(iconData, color: colors[index % colors.length]),
                  title: Text(label),
                  contentPadding: const EdgeInsets.symmetric(
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

  Widget _buildTransactionList(app_notifier.TransactionState transactionState) {
    if (transactionState.allTransactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey),
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
            Icon(Icons.receipt_long, size: 80, color: Colors.grey),
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
            final label = context
                .read<app_notifier.TransactionNotifier>()
                .getCategoryLabel(entry.key);
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
