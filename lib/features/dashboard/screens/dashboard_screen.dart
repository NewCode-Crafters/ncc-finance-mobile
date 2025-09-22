import 'package:bytebank/core/widgets/nav_bar.dart';
import 'package:bytebank/features/pokemons/screens/pokemons_screen.dart';
import 'package:bytebank/core/models/nav_model.dart';
import 'package:bytebank/features/transactions/screens/create_transaction_screen.dart';
import 'package:bytebank/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/features/dashboard/widgets/action_card.dart';
import 'package:bytebank/features/transactions/screens/transactions_screen.dart';
import 'package:intl/intl.dart';
import 'package:bytebank/core/widgets/main_app_bar.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/investments/screens/investments_screen.dart';
import 'package:bytebank/features/profile/notifiers/profile_notifier.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceVisible = true;
  final homeNavKey = GlobalKey<NavigatorState>();
  final searchNavKey = GlobalKey<NavigatorState>();
  final notificationNavKey = GlobalKey<NavigatorState>();
  final profileNavKey = GlobalKey<NavigatorState>();
  int selectedTab = 0;
  List<NavModel> items = [];

  @override
  void initState() {
    super.initState();
    items = [
      NavModel(page: const DashboardScreen(), navKey: homeNavKey),
      NavModel(page: const InvestmentsScreen(), navKey: searchNavKey),
      NavModel(page: const TabPage(tab: 3), navKey: notificationNavKey),
      NavModel(page: const TabPage(tab: 4), navKey: profileNavKey),
    ];
  }

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

    final List<Widget> tabBodies = [
      // Tab 0: Dashboard principal
      RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Bem-vindo de volta',
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
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.cardSaldoGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Saldo', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.neutral100)),
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
                            style: IconButton.styleFrom(
                              foregroundColor: AppColors.darkPurpleColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.darkPurpleColor, thickness: 1),
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
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutral100),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ActionCard(
                  icon: Icons.swap_horiz,
                  label: 'Fazer uma\ntransação',
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(CreateTransactionScreen.routeName);
                  },
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
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 400,
              child: TransactionsScreen(),
            ),
          ],
        ),
      ),
      // Tab 1: Investimentos
      const InvestmentsScreen(),
      // Tab 2: Notificações (exemplo)
      const TabPage(tab: 3),
      // Tab 3: Perfil (exemplo)
      const TabPage(tab: 4),
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceDefault,
      appBar: const MainAppBar(),
      body: IndexedStack(
        index: selectedTab,
        children: tabBodies,
      ),
      bottomNavigationBar: NavBar(
        pageIndex: selectedTab,
        onTap: (index) {
          setState(() {
            selectedTab = index;
          });
        },
      ),
    );
  }
}

 class TabPage extends StatelessWidget {
   final int tab;

   const TabPage({Key? key, required this.tab}) : super(key: key);

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       //appBar: AppBar(title: Text('Tab $tab')),
       body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Text('Tab $tab'),
             ElevatedButton(
               onPressed: () {
                 Navigator.of(
                   context,
                 ).push(MaterialPageRoute(builder: (context) => NavBar(pageIndex: tab, onTap: (int p1) {  },)));
               },
               child: const Text('Go to page'),
             ),
           ],
         ),
       ),
     );
   }
 }

 class Page extends StatelessWidget {
   final int tab;

   const Page({super.key, required this.tab});

  @override
   Widget build(BuildContext context) {
     return tab == 1 ? InvestmentsScreen() : Scaffold(
       appBar: AppBar(title: Text('Page Tab $tab')),
       body: Center(child: tab != 1 ? Text('Tab $tab') : InvestmentsScreen()),
     );
   }
 }
