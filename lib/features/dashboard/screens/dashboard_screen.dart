import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/main_app_bar.dart';
import 'package:flutter_application_1/features/investments/screens/investments_screen.dart';

class DashboardScreen extends StatelessWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to your Dashboard!'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(InvestmentsScreen.routeName);
              },
              child: const Text('Go to Investments'),
            ),
          ],
        ),
      ),
    );
  }
}
