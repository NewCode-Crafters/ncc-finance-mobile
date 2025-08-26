import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/main_app_bar.dart';

class DashboardScreen extends StatelessWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: const Center(child: Text('Welcome to your Dashboard!')),
    );
  }
}
