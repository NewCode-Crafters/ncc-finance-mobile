import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/custom_text_field.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';
import 'package:flutter_application_1/features/profile/notifers/profile_notifier.dart';
import 'package:provider/provider.dart';

class UpdateAccountScreen extends StatefulWidget {
  static const String routeName = '/update-account';
  const UpdateAccountScreen({super.key});

  @override
  State<UpdateAccountScreen> createState() => _UpdateAccountScreenState();
}

class _UpdateAccountScreenState extends State<UpdateAccountScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProfile = context.read<ProfileNotifier>().state.userProfile;
    print(userProfile?.email);
    _nameController = TextEditingController(text: userProfile?.name);
    _emailController = TextEditingController(text: userProfile?.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    setState(() {
      _isLoading = true;
    });

    final authService = context.read<AuthService>();
    final profileNotifier = context.read<ProfileNotifier>();
    final currentUser = context.read<ProfileNotifier>().state.userProfile;

    try {
      await authService.updateUserName(newName: _nameController.text.trim());

      if (currentUser != null) {
        await profileNotifier.fetchUserProfile(
          userId: currentUser.uid,
          forceRefresh: true,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu Cadastro")),
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
        CustomTextField(
          key: Key("update_account_email_field"),
          label: "Email",
          readOnly: true,
          controller: _emailController,
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          PrimaryButton(
            text: "Salvar Alterações",
            onPressed: _handleUpdateProfile,
          ),
      ],
    );
  }
}
