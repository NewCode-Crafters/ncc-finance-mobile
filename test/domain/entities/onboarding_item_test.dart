import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/onboarding_item.dart';

void main() {
  test('OnboardingItem copyWith and equality', () {
    final item = const OnboardingItem(
      title: 'Welcome',
      subtitle: 'Intro',
      illustrationAsset: 'assets/ill.png',
    );

    final changed = item.copyWith(title: 'Hello');
    expect(changed.title, 'Hello');
    expect(item == item.copyWith(), isTrue);
  });
}
