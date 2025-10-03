import 'package:bytebank/core/widgets/app_snackbar.dart';
import 'package:bytebank/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/core/constants/app_assets.dart';
import 'package:bytebank/core/widgets/custom_text_field.dart';
import 'package:bytebank/core/widgets/primary_button.dart';
import 'package:bytebank/features/authentication/notifiers/auth_notifier.dart';
import 'package:bytebank/features/authentication/screens/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authNotifier = context.read<AuthNotifier>();
    final success = await authNotifier.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success) {
      // Close this login screen so the AuthGate (root) can render the Dashboard.
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _handleForgotPassword() {
    showAppSnackBar(
      context,
      'Entre em contato com o suporte para redefinir sua senha.',
      AppMessageType.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use a Consumer to listen for changes in the AuthNotifier.
    final authNotifier = context.watch<AuthNotifier>();

    final height = MediaQuery.of(context).size.height;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final compact = height < 700 || keyboardOpen;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 90),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(image: const AssetImage(AppAssets.byteBankLogo)),
                    const SizedBox(width: 8),
                    Image(image: const AssetImage(AppAssets.byteBankName)),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
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
                          top: compact ? 20 : 40,
                          right: 20,
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: compact ? 24 : 30,
                            color: AppColors.brandTertiary,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: compact ? 8 : 16,
                          left: 24,
                          right: 24,
                          top: compact ? 8 : 1,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: _buildLoginForm(
                            isLoading: authNotifier.state.isLoading,
                            compact: compact,
                          ),
                        ),
                      ),
                      // hide or shrink the decorative image on compact screens
                      if (!compact)
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image(image: const AssetImage(AppAssets.login)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm({required bool isLoading, bool compact = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: compact ? 12 : 40),
        TextField(
          key: Key('login_email_field'),
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
          key: const Key('login_password_field'),
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
          obscureText: true,
          controller: _passwordController,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handleForgotPassword,
            child: const Text(
              "Esqueci a senha?",
              style: TextStyle(
                color: AppColors.brandTertiary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 16),
        isLoading
            ? const CircularProgressIndicator()
            : PrimaryButton(
                key: const Key('login_access_button'),
                onPressed: _handleLogin,
                text: 'Acessar',
              ),
        SizedBox(height: compact ? 8 : 10),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(RegisterScreen.routeName);
          },
          child: const Text(
            "Cadastre-se",
            style: TextStyle(
              color: AppColors.brandTertiary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
