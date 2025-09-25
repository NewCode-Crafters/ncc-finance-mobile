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

  @override
  Widget build(BuildContext context) {
    // We use a Consumer to listen for changes in the AuthNotifier.
    final authNotifier = context.watch<AuthNotifier>();
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, 
              children: [ 
                Card(
                  color: AppColors.lightGreenColor,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(150)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40, right: 20),
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 30, color: AppColors.brandTertiary, fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1, left: 24, right: 24, top: 1),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: 400,
                          child: _buildLoginForm(isLoading: authNotifier.state.isLoading),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end, 
                          children: [
                            Image(image: const AssetImage(AppAssets.login),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] 
      ),
    );
  }

  Widget _buildLoginForm({required bool isLoading}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        TextField(
          key: Key('login_email_field'),
          cursorColor: AppColors.brandTertiary,
          style: const TextStyle(
            color: AppColors.brandTertiary,
          ),
          decoration: const InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
              color: AppColors.brandTertiary, 
            ),
            floatingLabelStyle: TextStyle(
              color: AppColors.brandTertiary, 
            ),
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
        const SizedBox(height: 16),
        TextField(
          key: const Key('login_password_field'),
          style: const TextStyle(
            color: AppColors.brandTertiary,
          ),
          decoration: const InputDecoration(
            labelText: 'Senha',
            labelStyle: TextStyle(
              color: AppColors.brandTertiary, 
            ),
            floatingLabelStyle: TextStyle(
              color: AppColors.brandTertiary, 
            ),
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
            onPressed: () {}, // TODO: Implement forgot password
            child: const Text(
              "Esqueci a senha?", 
              style: TextStyle(color: AppColors.brandTertiary, fontWeight: FontWeight.w800),
            ),
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
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(RegisterScreen.routeName);
          },
          child: const Text(
            "Cadastre-se", 
            style: TextStyle(color: AppColors.brandTertiary, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
