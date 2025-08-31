import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bytebank/core/services/metadata_service.dart';
import 'package:bytebank/features/splash/screens/splash_screen.dart';
import 'package:bytebank/features/transactions/models/financial_transaction.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_notifier.dart';
import 'package:bytebank/features/transactions/screens/create_transaction_screen.dart';
import 'package:bytebank/features/transactions/screens/edit_transaction_screen.dart';
import 'package:bytebank/features/transactions/screens/transactions_screen.dart';
import 'package:bytebank/features/transactions/services/financial_transaction_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bytebank/features/authentication/notifiers/auth_notifier.dart';
import 'package:bytebank/features/authentication/screens/auth_wrapper.dart';
import 'package:bytebank/features/authentication/screens/login_screen.dart';
import 'package:bytebank/features/authentication/screens/register_screen.dart';
import 'package:bytebank/features/authentication/screens/update_account_screen.dart';
import 'package:bytebank/features/authentication/services/auth_service.dart';
import 'package:bytebank/features/authentication/services/firebase_auth_service.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/dashboard/screens/dashboard_screen.dart';
import 'package:bytebank/features/dashboard/services/balance_service.dart';
import 'package:bytebank/features/investments/notifiers/investment_notifier.dart';
import 'package:bytebank/features/investments/screens/create_investment_screen.dart';
import 'package:bytebank/features/investments/screens/investments_screen.dart';
import 'package:bytebank/features/investments/services/investment_service.dart';
import 'package:bytebank/features/profile/notifers/profile_notifier.dart';
import 'package:bytebank/features/profile/screens/my_profile_screen.dart';
import 'package:bytebank/features/profile/services/profile_service.dart';
import 'package:bytebank/firebase_options.dart';
import 'package:bytebank/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pt_BR', '');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap our app in a MultiProvider to make our services and notifiers
    // available to the entire widget tree.
    return MultiProvider(
      providers: [
        // --- Authentication ---
        Provider<AuthService>(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider<AuthNotifier>(
          create: (context) => AuthNotifier(context.read<AuthService>()),
        ),
        // --- Profile ---
        Provider<ProfileService>(create: (_) => ProfileService()),
        ChangeNotifierProvider<ProfileNotifier>(
          create: (context) => ProfileNotifier(context.read<ProfileService>()),
        ),
        // --- Balance ---
        Provider<BalanceService>(create: (_) => BalanceService()),
        ChangeNotifierProvider<BalanceNotifier>(
          create: (context) => BalanceNotifier(context.read<BalanceService>()),
        ),
        // --- Investments ---
        Provider<InvestmentService>(create: (_) => InvestmentService()),
        ChangeNotifierProvider<InvestmentNotifier>(
          create: (context) =>
              InvestmentNotifier(context.read<InvestmentService>()),
        ),
        // --- Transactions ---
        Provider<MetadataService>(create: (_) => MetadataService()),
        Provider<FinancialTransactionService>(
          create: (_) => FinancialTransactionService(),
        ),
        ChangeNotifierProvider<TransactionNotifier>(
          create: (context) => TransactionNotifier(
            context.read<FinancialTransactionService>(),
            context.read<MetadataService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Bytebank',
        theme: appTheme,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        // The AuthGate will decide which screen to show.
        home: const SplashScreen(),
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          RegisterScreen.routeName: (context) => const RegisterScreen(),
          DashboardScreen.routeName: (context) => const DashboardScreen(),
          MyProfileScreen.routeName: (context) => const MyProfileScreen(),
          UpdateAccountScreen.routeName: (context) =>
              const UpdateAccountScreen(),
          InvestmentsScreen.routeName: (context) => const InvestmentsScreen(),
          CreateInvestmentScreen.routeName: (context) =>
              const CreateInvestmentScreen(),
          TransactionsScreen.routeName: (context) => const TransactionsScreen(),
          CreateTransactionScreen.routeName: (context) =>
              const CreateTransactionScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == EditTransactionScreen.routeName) {
            final transaction = settings.arguments as FinancialTransaction;
            return MaterialPageRoute(
              builder: (context) =>
                  EditTransactionScreen(transaction: transaction),
            );
          }
          return MaterialPageRoute(
            builder: (_) => const AuthGate(),
          ); // Fallback
        },
      ),
    );
  }
}
