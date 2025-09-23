import 'package:bytebank/core/widgets/main_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/investments/notifiers/investment_notifier.dart';
import 'package:bytebank/features/investments/screens/create_investment_screen.dart';
import 'package:bytebank/features/investments/widgets/investment_list_item.dart';
import 'package:provider/provider.dart';

class InvestmentsScreen extends StatefulWidget {
  static const String routeName = '/investments';

  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  final List<Color> _colors = [
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

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

  Future<bool?> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Deseja realmente resgatar este investimento? A ação criará uma transação de entrada no seu saldo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteInvestment(String investmentId) async {
    if (mounted) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final investmentNotifier = context.read<InvestmentNotifier>();
      final balanceNotifier = context.read<BalanceNotifier>();

      await investmentNotifier.deleteInvestment(
        userId: userId,
        investmentId: investmentId,
      );
      await balanceNotifier.fetchBalances(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use context.watch to listen for changes in the notifier's state.
    final investmentState = context.watch<InvestmentNotifier>().state;

    return Scaffold(
      appBar: MainAppBar(title: 'Investimentos'),
      body: investmentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _fetchData(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildChart(investmentState),
                  const SizedBox(height: 24),
                  _buildSummaryCards(investmentState),
                  const SizedBox(height: 24),
                  _buildInvestmentList(investmentState, _colors),
                ],
              ),
            ),
    );
  }

  Widget _buildChart(InvestmentState state) {
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
                return ListTile(
                  leading: Icon(
                    Icons.circle,
                    color: colors[index % colors.length],
                  ),
                  title: Text(entry.key.replaceAll('_', ' ').toLowerCase(), textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  minVerticalPadding: 0.0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(InvestmentState state) {
    return Row(
      children: [
        // This flexible contains the two original summary cards
        Flexible(
          flex: 2,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Renda Fixa'),
                      Text(
                        'R\$ ${state.totalFixedIncome.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Renda Variável'),
                      Text(
                        'R\$ ${state.totalVariableIncome.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // This is the new card for creating an investment
        Flexible(
          flex: 1,
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(CreateInvestmentScreen.routeName);
              },
              child: Container(
                height: 150, // Adjust height to match cards
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_card, size: 32),
                    SizedBox(height: 8),
                    Text('Fazer um\ninvestimento', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentList(InvestmentState state, List<Color> colors) {
    if (state.investments.isEmpty) {
      return const Center(child: Text('Você ainda não possui investimentos.'));
    }

    final typeToColor = {
      for (var i = 0; i < state.chartData.keys.length; i++)
        state.chartData.keys.elementAt(i): colors[i % colors.length],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meus Investimentos',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        // Use shrinkWrap and physics for ListView inside another scrolling view.
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.investments.length,
          itemBuilder: (context, index) {
            final investment = state.investments[index];
            return InvestmentListItem(
              investment: investment,
              indicatorColor: typeToColor[investment.type] ?? Colors.grey,
              onConfirmDelete: () async {
                final confirmed = await _showDeleteConfirmationDialog();
                if (confirmed == true) {
                  await _deleteInvestment(investment.id);
                  return true; // This will dismiss the item
                }
                return false; // This will not dismiss the item
              },
            );
          },
        ),
      ],
    );
  }
}
