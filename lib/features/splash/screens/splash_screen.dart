import 'package:flutter/material.dart';
import 'package:bytebank/core/constants/app_assets.dart';
import 'package:bytebank/features/authentication/screens/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _logoOpacity = 0.0;
  double _subtitleOpacity = 0.0;
  final int _logoAnimationDuration = 1500;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _logoOpacity = 1.0;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _subtitleOpacity = 1.0;
        });
      }
    });

    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // Wait for the animation to complete, then navigate
    Future.delayed(Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use your app's theme color for the background
      backgroundColor: const Color(0xFFC6E0AE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _logoOpacity,
              duration: Duration(milliseconds: _logoAnimationDuration),
              curve: Curves.easeIn,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 95),
                    child: Image.asset(
                      AppAssets.byteBankSplashScreenImage,
                      width: 300,
                      height: 300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bytebank',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: _subtitleOpacity,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeIn,
              child: Text(
                'by NCC Finance',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
