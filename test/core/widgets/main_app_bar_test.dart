import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/main_app_bar.dart';
import 'package:flutter_application_1/features/profile/screens/my_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpMainAppBar(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      routes: {'/profile': (context) => const MyProfileScreen()},
      home: const Scaffold(appBar: MainAppBar()),
    ),
  );
}

void main() {
  testWidgets('MainAppBar should display a CircleAvatar', (
    WidgetTester tester,
  ) async {
    await pumpMainAppBar(tester);

    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('tapping avatar should navigate to MyProfileScreen', (
    WidgetTester tester,
  ) async {
    await pumpMainAppBar(tester);

    final avatarFinder = find.byType(CircleAvatar);
    await tester.tap(avatarFinder);

    await tester.pumpAndSettle();

    expect(find.byType(MyProfileScreen), findsOneWidget);
  });
}
