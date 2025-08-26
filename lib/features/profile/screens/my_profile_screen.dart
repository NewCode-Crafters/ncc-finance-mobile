import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/editable_avatar.dart';
import 'package:flutter_application_1/features/authentication/screens/update_account_screen.dart';

class MyProfileScreen extends StatelessWidget {
  static const String routeName = '/profile';
  final String userName;
  final String userEmail;

  const MyProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EditableAvatar(radius: 50),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(userEmail, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Meu cadastro'),
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(UpdateAccountScreen.routeName);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Encerrar sessão'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
