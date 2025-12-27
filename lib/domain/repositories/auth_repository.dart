import 'package:bytebank/domain/entities/user_profile.dart';

/// Repository interface for authentication-related operations.
///
/// The concrete implementation (for example, a Firebase-backed repository)
/// should implement these methods. Method signatures mirror the
/// services/firebase_auth_service.dart API but are expressed in domain types.
abstract class AuthRepository {
  /// Signs in a user with [email] and [password].
  ///
  /// Throws domain-specific exceptions or generic [Exception] on failure.
  Future<void> login(String email, String password);

  /// Creates a new user with [name], [email] and [password].
  ///
  /// On success the repository should also create and persist a corresponding
  /// `UserProfile` in the persistence layer.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Sends a password reset email to [email].
  Future<void> sendPasswordResetEmail({required String email});

  /// Signs out the current user.
  Future<void> logout();

  /// Updates the user's photo URL stored in the persistence layer.
  Future<void> updateUserPhotoUrl({required String url});

  /// Updates the user's display name stored in the persistence layer.
  Future<void> updateUserName({required String newName});

  /// Retrieves the current authenticated user's profile, or `null` if none.
  Future<UserProfile?> getCurrentUserProfile();
}
