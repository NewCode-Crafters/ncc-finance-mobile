import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/infrastructure/dtos/user_profile_dto.dart';

class UserProfileMapper {
  const UserProfileMapper();

  UserProfile toDomain({required DocumentSnapshot doc}) {
    final dto = UserProfileDTO.fromFirestore(doc);
    return UserProfile(
      uid: doc.id,
      name: dto.name,
      email: dto.email,
      photoUrl: dto.photoUrl,
      createdAt: dto.createdAt.toDate(),
    );
  }

  Map<String, dynamic> toFirestore(UserProfile profile) {
    // If the profile's createdAt is not set (epoch 0 or earlier), use
    // Firestore server timestamp so the database assigns the creation time.
    final createdAtValue =
        profile.createdAt.millisecondsSinceEpoch <= 0
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(profile.createdAt);

    return {
      'name': profile.name,
      'email': profile.email,
      'photoUrl': profile.photoUrl,
      'createdAt': createdAtValue,
    };
  }
}
