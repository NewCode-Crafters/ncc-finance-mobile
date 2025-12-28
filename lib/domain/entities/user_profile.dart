import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {required String uid}) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: (() {
        final raw = map['createdAt'];
        if (raw is DateTime) {
          if (raw.millisecondsSinceEpoch > 0) return raw;
        }
        return DateTime.now();
      })(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [uid, name, email, photoUrl, createdAt];
}
