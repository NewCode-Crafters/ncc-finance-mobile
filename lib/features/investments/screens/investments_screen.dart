import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/investments/notifiers/investment_notifier.dart';
import 'package:flutter_application_1/features/investments/screens/create_investment_screen.dart';
import 'package:provider/provider.dart';

class InvestmentsScreen extends StatefulWidget {
  static const String routeName = '/investments';

  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print('🎉 Current User ID: $userId');
    if (userId != null) {
      context.read<InvestmentNotifier>().fetchInvestments(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use context.watch to listen for changes in the notifier's state.
    final investmentState = context.watch<InvestmentNotifier>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Investimentos')),
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
                  _buildInvestmentList(investmentState),
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
                  title: Text(entry.key.replaceAll('_', ' ').toLowerCase()),
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

  Widget _buildInvestmentList(InvestmentState state) {
    if (state.investments.isEmpty) {
      return const Center(child: Text('Você ainda não possui investimentos.'));
    }

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
            return Card(
              child: ListTile(
                title: Text(investment.name),
                subtitle: Text(
                  investment.investedAt.toLocal().toString().split(' ')[0],
                ),
                trailing: Text('R\$ ${investment.amount.toStringAsFixed(2)}'),
              ),
            );
          },
        ),
      ],
    );
  }
}
