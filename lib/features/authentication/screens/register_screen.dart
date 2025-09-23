import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/profile/notifiers/profile_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/core/widgets/custom_text_field.dart';
import 'package:bytebank/core/widgets/primary_button.dart';
import 'package:bytebank/features/authentication/notifiers/auth_notifier.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AuthNotifier _authNotifier;

  @override
  void initState() {
    super.initState();
    _authNotifier = context.read<AuthNotifier>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Capture the navigator before the async call to avoid using BuildContext
    // across an async gap.
    final navigator = Navigator.of(context);
    final balanceNotifier = context.read<BalanceNotifier>();
    final profileNotifier = context.read<ProfileNotifier>();

    final bool success = await _authNotifier.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Fetch both profile and balance to ensure the notifiers are populated
        // before the user lands on the dashboard.
        await profileNotifier.fetchUserProfile(userId: userId);
        await balanceNotifier.fetchBalances(userId: userId);
      }
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthNotifier>().state.isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: Center(child: _buildRegisterForm(isLoading: isLoading)),
    );
  }

  Widget _buildRegisterForm({required bool isLoading}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Crie uma nova conta',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          CustomTextField(
            key: Key("register_name_field"),
            label: "Nome",
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            key: Key("register_email_field"),
            label: "Email",
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            key: Key("register_password_field"),
            label: "Senha",
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          isLoading
              ? const CircularProgressIndicator()
              : PrimaryButton(
                  text: "Criar conta",
                  onPressed: isLoading ? null : _handleSignUp,
                ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Já tem uma conta? Acesse"),
          ),
        ],
      ),
    );
  }
}
