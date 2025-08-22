import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_assets.dart';
import 'package:flutter_application_1/core/widgets/custom_text_field.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: _buildLoginForm()));
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(image: const AssetImage(AppAssets.byteBankLogo)),
        const SizedBox(height: 40),
        const CustomTextField(key: Key('login_email_field'), label: 'Email'),
        const SizedBox(height: 16),
        const CustomTextField(
          key: Key('login_password_field'),
          label: 'Senha',
          obscureText: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text("Esqueci a senha?"),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          key: const Key('login_access_button'),
          onPressed: () {},
          text: 'Acessar',
        ),
      ],
    );
  }
}
