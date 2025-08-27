import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/editable_avatar.dart';
import 'package:flutter_application_1/features/authentication/notifiers/auth_notifier.dart';
import 'package:flutter_application_1/features/authentication/screens/update_account_screen.dart';
import 'package:flutter_application_1/features/profile/notifers/profile_notifier.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileNotifier>().state;
    final userProfile = profileState.userProfile;
    final isLoading = profileState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
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
                          userProfile?.name ?? 'Usuário...',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userProfile?.email ?? '',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
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
                          onTap: () {
                            context.read<AuthNotifier>().logout();

                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
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
