import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/authentication/notifiers/auth_notifier.dart';
import 'package:flutter_application_1/features/authentication/screens/login_screen.dart';
import 'package:flutter_application_1/features/dashboard/notifiers/balance_notifier.dart';
import 'package:flutter_application_1/features/profile/notifers/profile_notifier.dart';
import 'package:flutter_application_1/features/dashboard/screens/dashboard_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _authNotifier = context.read<AuthNotifier>();
    _profileNotifier = context.read<ProfileNotifier>();

    // Listen for changes in AuthNotifier's state to display messages
    _authNotifier.addListener(_onAuthMessageChanged);
    _profileNotifier.addListener(_onProfileMessageChanged);
  }

  @override
  void dispose() {
    _authNotifier.removeListener(_onAuthMessageChanged);
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
