import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserProfile equality and copyWith', () {
    final now = DateTime.now();
    final a = UserProfile(
      uid: 'u1',
      name: 'Alice',
      email: 'alice@example.com',
      photoUrl: 'http://photo',
      createdAt: now,
    );

    final b = a.copyWith(name: 'Alice A');

    expect(a == a.copyWith(), isTrue);
    expect(b.name, 'Alice A');
    expect(a.email, 'alice@example.com');
  });

  test('UserProfile map serialization', () {
    final now = DateTime.now();
    final profile = UserProfile(
      uid: 'u2',
      name: 'Bob',
      email: 'bob@example.com',
      photoUrl: null,
      createdAt: now,
    );

    final map = profile.toMap();
    final from = UserProfile.fromMap(map, uid: 'u2');

    expect(from.uid, 'u2');
    expect(from.name, 'Bob');
    expect(from.email, 'bob@example.com');
  });
}
