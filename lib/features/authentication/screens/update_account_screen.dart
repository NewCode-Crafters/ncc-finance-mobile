import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/custom_text_field.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';
import 'package:provider/provider.dart';

class UpdateAccountScreen extends StatefulWidget {
  static const String routeName = '/update-account';
  const UpdateAccountScreen({super.key});

  @override
  State<UpdateAccountScreen> createState() => _UpdateAccountScreenState();
}

class _UpdateAccountScreenState extends State<UpdateAccountScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateName() async {
    final authService = context.read<AuthService>();
    await authService.updateUserName(newName: _nameController.text.trim());
  }

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
        CustomTextField(
          key: Key("update_account_name_field"),
          label: "Nome",
          controller: _nameController,
        ),
        const SizedBox(height: 24),
        const CustomTextField(
          key: Key("update_account_email_field"),
          label: "Email",
        ),
        const SizedBox(height: 24),
        PrimaryButton(text: "Salvar Alterações", onPressed: _handleUpdateName),
      ],
    );
  }
}
