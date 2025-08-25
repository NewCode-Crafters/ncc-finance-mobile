import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/authentication/notifiers/auth_notifier.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthNotifier>().logout();
            },
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to your Dashboard!')),
    );
  }
}
