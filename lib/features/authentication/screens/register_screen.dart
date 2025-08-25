import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/custom_text_field.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: _buildRegisterForm(context)));
  }

  Widget _buildRegisterForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Crie uma nova conta",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 32),
        const CustomTextField(key: Key("register_name_field"), label: "Nome"),
        const SizedBox(height: 16),
        const CustomTextField(key: Key("register_email_field"), label: "Email"),
        const SizedBox(height: 16),
        const CustomTextField(
          key: Key("register_password_field"),
          label: "Senha",
          obscureText: true,
        ),
        const SizedBox(height: 24),
        const PrimaryButton(text: "Criar conta", onPressed: null),
      ],
    );
  }
}
