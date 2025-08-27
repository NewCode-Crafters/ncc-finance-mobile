import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/dashboard/widgets/action_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/core/widgets/main_app_bar.dart';
import 'package:flutter_application_1/features/dashboard/notifiers/balance_notifier.dart';
import 'package:flutter_application_1/features/investments/screens/investments_screen.dart';
import 'package:flutter_application_1/features/profile/notifers/profile_notifier.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceVisible = true;

  Future<void> _refreshData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && mounted) {
      await context.read<BalanceNotifier>().fetchBalances(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileNotifier>().state;
    final balanceState = context.watch<BalanceNotifier>().state;

    // Formatters for date and currency
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final dateFormatter = DateFormat(
      'EEEE, d \'de\' MMMM \'de\' yyyy',
      'pt_BR',
    );

    return Scaffold(
      appBar: const MainAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Ben-vindo de volta',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              profileState.userProfile?.name ?? 'Usuário',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              dateFormatter.format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            // --- Balance Card ---
            Card(
              color: Colors.green.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Saldo'),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            _isBalanceVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isBalanceVisible = !_isBalanceVisible;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (balanceState.isLoading)
                      const CircularProgressIndicator()
                    else
                      Text(
                        _isBalanceVisible
                            ? currencyFormatter.format(
                                balanceState.totalBalance,
                              )
                            : 'R\$ --,--',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Action Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ActionCard(
                  icon: Icons.swap_horiz,
                  label: 'Fazer uma\ntransação',
                  onTap: () {}, // Void for now
                ),
                ActionCard(
                  icon: Icons.bar_chart,
                  label: 'Fazer um\ninvestimento',
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(InvestmentsScreen.routeName);
                  },
                ),
                ActionCard(
                  icon: Icons.receipt_long,
                  label: 'Consultar\ngastos',
                  onTap: () {}, // Void for now
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
