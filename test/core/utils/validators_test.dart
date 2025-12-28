import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/core/utils/validators.dart';

void main() {
  test('valid emails pass', () {
    expect(Validators.isValidEmail('user@example.com'), isTrue);
    expect(Validators.isValidEmail('firstname.lastname@domain.co'), isTrue);
    expect(Validators.isValidEmail('user+tag@sub.domain.org'), isTrue);
  });

  test('invalid emails fail', () {
    expect(Validators.isValidEmail('plainAddress'), isFalse);
    expect(Validators.isValidEmail('missing@tld'), isFalse);
    expect(Validators.isValidEmail('@missingUser.com'), isFalse);
  });
}
