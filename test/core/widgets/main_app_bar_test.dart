import 'package:flutter/material.dart';
import 'package:bytebank/core/widgets/main_app_bar.dart';
import 'package:bytebank/features/profile/models/user_profile.dart';
import 'package:bytebank/features/profile/notifers/profile_notifier.dart';
import 'package:bytebank/features/profile/screens/my_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../features/profile/screens/my_profile_screen_test.mocks.dart';

void main() {
  late MockProfileService mockProfileService;
  late ProfileNotifier profileNotifier;

  setUp(() {
    mockProfileService = MockProfileService();
    profileNotifier = ProfileNotifier(mockProfileService);

    final fakeProfile = UserProfile(
      uid: '1',
      name: 'matosJoe',
      email: 'joeltonmatos@ncc.com',
    );

    profileNotifier.setStateForTest(ProfileState(userProfile: fakeProfile));
  });

  Future<void> pumpMainAppBar(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileNotifier>.value(
        value: profileNotifier,
        child: MaterialApp(
          routes: {'/profile': (context) => const MyProfileScreen()},
          home: const Scaffold(appBar: MainAppBar()),
        ),
      ),
    );
  }

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
