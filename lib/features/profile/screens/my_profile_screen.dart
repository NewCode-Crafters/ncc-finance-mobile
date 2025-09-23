import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/core/services/image_picker_service.dart';
import 'package:bytebank/core/widgets/editable_avatar.dart';
import 'package:bytebank/features/authentication/notifiers/auth_notifier.dart';
import 'package:bytebank/features/authentication/screens/update_account_screen.dart';
import 'package:bytebank/features/profile/notifiers/profile_notifier.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the modal
                  _updateAvatar(ImageSourceType.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the modal
                  _updateAvatar(ImageSourceType.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateAvatar(ImageSourceType source) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<ProfileNotifier>().updateUserAvatar(
        userId: user.uid,
        source: source,
      );
    }
  }

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
                        EditableAvatar(
                          radius: 50,
                          photoUrl: userProfile?.photoUrl,
                          userId: userProfile?.uid,
                          onEditPressed: () =>
                              _showImageSourceActionSheet(context),
                        ),
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
