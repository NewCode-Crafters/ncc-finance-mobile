import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/features/authentication/notifiers/auth_notifier.dart';
import 'package:flutter_application_1/features/authentication/screens/auth_wrapper.dart';
import 'package:flutter_application_1/features/authentication/screens/login_screen.dart';
import 'package:flutter_application_1/features/authentication/screens/register_screen.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';
import 'package:flutter_application_1/features/authentication/services/firebase_auth_service.dart';
import 'package:flutter_application_1/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_application_1/features/profile/notifers/profile_notifier.dart';
import 'package:flutter_application_1/features/profile/screens/my_profile_screen.dart';
import 'package:flutter_application_1/features/profile/services/profile_service.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap our app in a MultiProvider to make our services and notifiers
    // available to the entire widget tree.
    return MultiProvider(
      providers: [
        // --- Authentication ---
        Provider<AuthService>(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider<AuthNotifier>(
          create: (context) => AuthNotifier(context.read<AuthService>()),
        ),
        // --- Profile ---
        Provider<ProfileService>(create: (_) => ProfileService()),
        ChangeNotifierProvider<ProfileNotifier>(
          create: (context) => ProfileNotifier(context.read<ProfileService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Bytebank',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        // The AuthGate will decide which screen to show.
        home: const AuthGate(),
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          RegisterScreen.routeName: (context) => const RegisterScreen(),
          DashboardScreen.routeName: (context) => const DashboardScreen(),
          MyProfileScreen.routeName: (context) => const MyProfileScreen(),
        },
      ),
    );
  }
}
