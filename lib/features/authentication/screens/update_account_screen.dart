import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/custom_text_field.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';

/*
- The screen displays a "Name" input field.
- The screen displays an "Email" input field.
- The screen displays a "Save Changes" button.
*/
class UpdateAccountScreen extends StatelessWidget {
  const UpdateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Atualizar Conta")),
      body: Center(child: _buildUpdateForm(context)),
    );
  }

  Widget _buildUpdateForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CustomTextField(
          key: Key("update_account_name_field"),
          label: "Nome",
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          key: Key("update_account_email_field"),
          label: "Email",
        ),
        const SizedBox(height: 24),
        const PrimaryButton(text: "Salvar Alterações", onPressed: null),
      ],
    );
  }
}
