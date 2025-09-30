import 'package:bytebank/core/constants/app_assets.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/profile/notifiers/profile_notifier.dart';
import 'package:bytebank/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    final height = MediaQuery.of(context).size.height;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final compact = height < 700 || keyboardOpen;

    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Card(
                    color: AppColors.lightGreenColor,
                    elevation: 1,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(150),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: compact ? 28 : 50,
                            right: 20,
                          ),
                          child: Text(
                            'Crie uma nova conta',
                            style: TextStyle(
                              fontSize: compact ? 22 : 30,
                              color: AppColors.brandTertiary,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: compact ? 8 : 10,
                            bottom: 10,
                          ),
                          child: Text(
                            'Preencha os campos abaixo para criar sua conta!',
                            style: TextStyle(
                              fontSize: compact ? 12 : 14,
                              color: AppColors.brandTertiary,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 1,
                            left: 24,
                            right: 24,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: _buildRegisterForm(
                              isLoading: isLoading,
                              compact: compact,
                            ),
                          ),
                        ),
                        // hide decorative image on compact screens so content fits
                        if (!compact)
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image(
                                  image: const AssetImage(AppAssets.register),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm({required bool isLoading, bool compact = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 12 : 16, right: 16, left: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            key: const Key("register_name_field"),
            cursorColor: AppColors.brandTertiary,
            style: const TextStyle(color: AppColors.brandTertiary),
            decoration: const InputDecoration(
              labelText: 'Nome',
              labelStyle: TextStyle(color: AppColors.brandTertiary),
              floatingLabelStyle: TextStyle(color: AppColors.brandTertiary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: AppColors.lightGreenColor,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: AppColors.lightGreenColor,
                  width: 2.0,
                ),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            controller: _nameController,
          ),
          SizedBox(height: compact ? 10 : 16),
          TextField(
            key: const Key("register_email_field"),
            cursorColor: AppColors.brandTertiary,
            style: const TextStyle(color: AppColors.brandTertiary),
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: AppColors.brandTertiary),
              floatingLabelStyle: TextStyle(color: AppColors.brandTertiary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: AppColors.lightGreenColor,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: AppColors.lightGreenColor,
                  width: 2.0,
                ),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            controller: _emailController,
          ),
          SizedBox(height: compact ? 10 : 16),
          TextField(
            key: const Key("register_password_field"),
            cursorColor: AppColors.brandTertiary,
            style: const TextStyle(color: AppColors.brandTertiary),
            decoration: const InputDecoration(
              labelText: 'Senha',
              labelStyle: TextStyle(color: AppColors.brandTertiary),
              floatingLabelStyle: TextStyle(color: AppColors.brandTertiary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: AppColors.lightGreenColor,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: AppColors.lightGreenColor,
                  width: 2.0,
                ),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            controller: _passwordController,
            obscureText: true,
          ),
          SizedBox(height: compact ? 16 : 24),
          isLoading
              ? const CircularProgressIndicator()
              : PrimaryButton(
                  text: "Criar conta",
                  onPressed: isLoading ? null : _handleSignUp,
                ),
          SizedBox(height: compact ? 12 : 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Já tem uma conta? Acesse",
              style: TextStyle(
                color: AppColors.brandTertiary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
