import 'package:bytebank/presentation/screens/transactions/expense_control_screen.dart';
import 'package:bytebank/application/notifiers/chart_animation_notifier.dart';
import 'package:bytebank/presentation/screens/transactions/view_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bytebank/infrastructure/services/metadata_service.dart';
import 'package:bytebank/presentation/screens/splash/splash_screen.dart';
import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/application/notifiers/transaction_notifier.dart'
    as app_notifier;
import 'package:bytebank/application/notifiers/transaction_attachments_notifier.dart';
import 'package:bytebank/presentation/screens/transactions/create_transaction_screen.dart';
import 'package:bytebank/presentation/screens/transactions/edit_transaction_screen.dart';
import 'package:bytebank/presentation/screens/transactions/transactions_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bytebank/application/notifiers/auth_notifier.dart';
import 'package:bytebank/presentation/screens/authentication/auth_wrapper.dart';
import 'package:bytebank/presentation/screens/authentication/login_screen.dart';
import 'package:bytebank/presentation/screens/authentication/register_screen.dart';
import 'package:bytebank/presentation/screens/authentication/update_account_screen.dart';
import 'package:bytebank/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:bytebank/application/notifiers/investment_notifier.dart';
import 'package:bytebank/presentation/screens/investments/create_investment_screen.dart';
import 'package:bytebank/presentation/screens/investments/investments_screen.dart';
import 'package:bytebank/application/notifiers/profile_notifier.dart';
import 'package:bytebank/domain/repositories/auth_repository.dart';
import 'package:bytebank/presentation/screens/profile/my_profile_screen.dart';
import 'package:bytebank/presentation/screens/onboarding/onboarding_carousel_screen.dart';
import 'package:bytebank/firebase_options.dart';
import 'package:bytebank/presentation/theme/theme.dart';
import 'core/di/injection_container.dart';
import 'package:bytebank/application/notifiers/balance_notifier.dart'
    as app_balance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();
  await initializeDateFormatting('pt_BR', '');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap our app in Provider wrappers, but the instances come from GetIt.
    // Keep using Provider/ChangeNotifierProvider for widget bindings, but
    // obtain the actual instances from the service locator `sl`.
    return MultiProvider(
      providers: [
        // --- Authentication ---
        ChangeNotifierProvider<AuthNotifier>(create: (_) => sl<AuthNotifier>()),
        Provider<AuthRepository>(create: (_) => sl<AuthRepository>()),
        // --- Profile ---
        ChangeNotifierProvider<ProfileNotifier>(
          create: (_) => sl<ProfileNotifier>(),
        ),
        // --- Balance ---
        ChangeNotifierProvider<app_balance.BalanceNotifier>(
          create: (_) => sl<app_balance.BalanceNotifier>(),
        ),
        // --- Investments ---
        ChangeNotifierProvider<InvestmentNotifier>(
          create: (_) => sl<InvestmentNotifier>(),
        ),
        // --- Transactions ---
        Provider<MetadataService>(create: (_) => sl<MetadataService>()),
        // --- Chart Animation ---
        ChangeNotifierProvider<ChartAnimationNotifier>(
          create: (_) => sl<ChartAnimationNotifier>(),
        ),
        ChangeNotifierProvider<app_notifier.TransactionNotifier>(
          create: (_) => sl<app_notifier.TransactionNotifier>(),
        ),
        // Local attachments selection for transaction creation
        ChangeNotifierProvider<TransactionAttachmentsNotifier>(
          create: (_) => sl<TransactionAttachmentsNotifier>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
          ViewTransactionScreen.routeName: (context) =>
              const ViewTransactionScreen(),
          CreateTransactionScreen.routeName: (context) =>
              const CreateTransactionScreen(),
          ExpenseControlScreen.routeName: (context) =>
              const ExpenseControlScreen(),
          OnboardingCarouselScreen.routeName: (context) =>
              const OnboardingCarouselScreen(),
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
