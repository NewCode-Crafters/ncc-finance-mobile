import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/features/authentication/notifiers/auth_notifier.dart';
import 'package:bytebank/features/authentication/screens/login_screen.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/investments/notifiers/investment_notifier.dart';
import 'package:bytebank/features/profile/notifiers/profile_notifier.dart';
import 'package:bytebank/features/dashboard/screens/dashboard_screen.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_notifier.dart';
import 'package:provider/provider.dart';

/// AuthGate is responsible for routing based on the user's authentication state
/// and for displaying global authentication-related messages (e.g., SnackBar).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late AuthNotifier _authNotifier;
  late ProfileNotifier _profileNotifier;
  late InvestmentNotifier _investmentNotifier;
  late TransactionNotifier _transactionNotifier;

  @override
  void initState() {
    super.initState();
    _authNotifier = context.read<AuthNotifier>();
    _profileNotifier = context.read<ProfileNotifier>();
    _investmentNotifier = context.read<InvestmentNotifier>();
    _transactionNotifier = context.read<TransactionNotifier>();

    // Listen for changes in AuthNotifier's state to display messages
    _authNotifier.addListener(_onAuthMessageChanged);
    _profileNotifier.addListener(_onProfileMessageChanged);
    _investmentNotifier.addListener(_onInvestmentMessageChanged);
    _transactionNotifier.addListener(_onTransactionMessageChanged);
  }

  @override
  void dispose() {
    _authNotifier.removeListener(_onAuthMessageChanged);
    _profileNotifier.removeListener(_onProfileMessageChanged);
    _investmentNotifier.removeListener(_onInvestmentMessageChanged);
    _transactionNotifier.removeListener(_onTransactionMessageChanged);
    super.dispose();
  }

  /// Handles displaying SnackBar messages based on AuthNotifier's state.
  void _onAuthMessageChanged() {
    final errorMessage = _authNotifier.state.errorMessage;
    final successMessage = _authNotifier.state.successMessage;

    if (errorMessage != null) {
      // Clear the message from the state immediately to prevent the listener
      // from firing again for the same message.
      _authNotifier.clearMessages();

      // Schedule the SnackBar to be shown after the current build cycle.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      });
    } else if (successMessage != null) {
      _authNotifier.clearMessages();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMessage)));
        }
      });
    }
  }

  void _onProfileMessageChanged() {
    final errorMessage = _profileNotifier.state.errorMessage;
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      });
    }
  }

  void _onInvestmentMessageChanged() {
    final errorMessage = _investmentNotifier.state.errorMessage;
    if (errorMessage != null) {
      _investmentNotifier.clearError();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      });
    }
  }

  void _onTransactionMessageChanged() {
    final successMessage = _transactionNotifier.state.successMessage;
    final errorMessage = _transactionNotifier.state.error;

    if (successMessage != null) {
      _transactionNotifier.clearSuccessMessage();
      _showSnackBar(successMessage, isError: false);
    } else if (errorMessage != null) {
      // TODO: move your error handling for transactions here if you like
      // _transactionNotifier.clearError();
      // _showSnackBar(errorMessage, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : Colors.green[600],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for the first auth state, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Once the stream is active, check if we have a user.
        if (snapshot.hasData) {
          final user = snapshot.data!;
          context.read<ProfileNotifier>().fetchUserProfile(userId: user.uid);

          context.read<BalanceNotifier>().fetchBalances(userId: user.uid);

          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
