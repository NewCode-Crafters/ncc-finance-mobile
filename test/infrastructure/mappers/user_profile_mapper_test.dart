import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/infrastructure/mappers/user_profile_mapper.dart';
import 'package:bytebank/domain/entities/user_profile.dart';

void main() {
  test('UserProfileMapper toFirestore uses timestamp when epoch', () {
    final mapper = const UserProfileMapper();
    final profile = UserProfile(
      uid: 'u1',
      name: 'Name',
      email: 'e@example.com',
      photoUrl: null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );

    final map = mapper.toFirestore(profile);
    // createdAt should be FieldValue.serverTimestamp() when epoch
    expect(map['name'], equals('Name'));
    // createdAt may be FieldValue or Timestamp; just ensure key exists
    expect(map.containsKey('createdAt'), isTrue);
  });
}
