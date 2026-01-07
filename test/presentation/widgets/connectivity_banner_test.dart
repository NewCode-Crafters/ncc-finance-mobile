import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/presentation/widgets/connectivity_banner.dart';
import '../../fakes/fake_connectivity_service.dart';

void main() {
  group('ConnectivityBanner', () {
    late FakeConnectivityService fakeService;

    setUp(() {
      fakeService = FakeConnectivityService(initialStatus: true);
    });

    tearDown(() {
      fakeService.dispose();
    });

    testWidgets('does NOT show banner when online', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ConnectivityBanner(
            connectivityService: fakeService,
            child: const Scaffold(
              body: Center(child: Text('Content')),
            ),
          ),
        ),
      );

      // Wait for stream to emit
      await tester.pumpAndSettle();

      // Banner should NOT be visible
      expect(find.text('Modo offline, mostrando dados salvos'), findsNothing);
      expect(find.byIcon(Icons.cloud_off), findsNothing);

      // Content should be visible
      expect(find.text('Content'), findsOne);
    });

    testWidgets('shows banner when offline', (tester) async {
      // Start offline
      fakeService = FakeConnectivityService(initialStatus: false);

      await tester.pumpWidget(
        MaterialApp(
          home: ConnectivityBanner(
            connectivityService: fakeService,
            child: const Scaffold(
              body: Center(child: Text('Content')),
            ),
          ),
        ),
      );

      // Wait for stream to emit
      await tester.pumpAndSettle();

      // Banner should be visible
      expect(find.text('Modo offline, mostrando dados salvos'), findsOne);
      expect(find.byIcon(Icons.cloud_off), findsOne);

      // Content should still be visible
      expect(find.text('Content'), findsOne);
    });

    testWidgets('banner appears when connectivity is lost', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ConnectivityBanner(
            connectivityService: fakeService,
            child: const Scaffold(
              body: Center(child: Text('Content')),
            ),
          ),
        ),
      );

      // Initially online - banner hidden
      await tester.pumpAndSettle();
      expect(find.text('Modo offline, mostrando dados salvos'), findsNothing);

      // Lose connectivity
      fakeService.setConnected(false);
      await tester.pumpAndSettle();

      // Banner should appear
      expect(find.text('Modo offline, mostrando dados salvos'), findsOne);
      expect(find.byIcon(Icons.cloud_off), findsOne);
    });

    testWidgets('banner disappears when connectivity is restored',
        (tester) async {
      // Start offline
      fakeService = FakeConnectivityService(initialStatus: false);

      await tester.pumpWidget(
        MaterialApp(
          home: ConnectivityBanner(
            connectivityService: fakeService,
            child: const Scaffold(
              body: Center(child: Text('Content')),
            ),
          ),
        ),
      );

      // Banner visible
      await tester.pumpAndSettle();
      expect(find.text('Modo offline, mostrando dados salvos'), findsOne);

      // Restore connectivity
      fakeService.setConnected(true);
      await tester.pumpAndSettle();

      // Banner should disappear
      expect(find.text('Modo offline, mostrando dados salvos'), findsNothing);
      expect(find.byIcon(Icons.cloud_off), findsNothing);
    });

    testWidgets('banner has correct styling', (tester) async {
      fakeService = FakeConnectivityService(initialStatus: false);

      await tester.pumpWidget(
        MaterialApp(
          home: ConnectivityBanner(
            connectivityService: fakeService,
            child: const Scaffold(
              body: Center(child: Text('Content')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find banner container
      final containerFinder = find.ancestor(
        of: find.text('Modo offline, mostrando dados salvos'),
        matching: find.byType(Container),
      );

      expect(containerFinder, findsAtLeastNWidgets(1));

      // Verify banner has amber background
      final container = tester.widget<Container>(containerFinder.first);
      expect(container.color, equals(Colors.amber));
    });
  });
}
