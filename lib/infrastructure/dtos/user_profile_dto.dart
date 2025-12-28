import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileDTO {
  final String name;
  final String email;
  final String? photoUrl;
  final Timestamp createdAt;

  const UserProfileDTO({
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserProfileDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileDTO(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] is Timestamp)
          ? data['createdAt'] as Timestamp
          : Timestamp.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }
}
