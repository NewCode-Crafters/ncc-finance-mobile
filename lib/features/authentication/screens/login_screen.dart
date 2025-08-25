import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_assets.dart';
import 'package:flutter_application_1/core/widgets/custom_text_field.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';
import 'package:flutter_application_1/features/authentication/notifiers/auth_notifier.dart';
import 'package:flutter_application_1/features/authentication/screens/register_screen.dart';
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
    await authNotifier.login(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    // We use a Consumer to listen for changes in the AuthNotifier.
    final authNotifier = context.watch<AuthNotifier>();
    return Scaffold(
      body: Center(
        child: _buildLoginForm(isLoading: authNotifier.state.isLoading),
      ),
    );
  }

  Widget _buildLoginForm({required bool isLoading}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(image: const AssetImage(AppAssets.byteBankLogo)),
        const SizedBox(height: 40),
        CustomTextField(
          key: Key('login_email_field'),
          label: 'Email',
          controller: _emailController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          key: const Key('login_password_field'),
          label: 'Senha',
          obscureText: true,
          controller: _passwordController,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {}, // TODO: Implement forgot password
            child: const Text("Esqueci a senha?"),
          ),
        ),
        const SizedBox(height: 16),
        isLoading
            ? const CircularProgressIndicator()
            : PrimaryButton(
                key: const Key('login_access_button'),
                onPressed: _handleLogin,
                text: 'Acessar',
              ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(RegisterScreen.routeName);
          },
          child: const Text("Cadastre-se"),
        ),
      ],
    );
  }
}
