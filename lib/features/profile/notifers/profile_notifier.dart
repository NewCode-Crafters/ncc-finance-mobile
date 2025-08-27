import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/core/services/image_picker_service.dart';
import 'package:flutter_application_1/features/profile/models/user_profile.dart';
import 'package:flutter_application_1/features/profile/services/profile_service.dart';

class ProfileState {
  final UserProfile? userProfile;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({this.userProfile, this.isLoading = false, this.errorMessage});

  ProfileState copyWith({
    UserProfile? userProfile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileNotifier extends ChangeNotifier {
  final ProfileService _profileService;
  ProfileState _state = ProfileState();

  ProfileState get state => _state;

  ProfileNotifier(this._profileService);

  Future<void> fetchUserProfile({
    required String userId,
    bool forceRefresh = false,
  }) async {
    if (_state.isLoading ||
        (!forceRefresh &&
            _state.userProfile != null &&
            _state.userProfile!.uid == userId)) {
      return;
    }

    // Use Future.microtask to avoid "setState called during build" errors.
    Future.microtask(() {
      _state = ProfileState(isLoading: true, userProfile: _state.userProfile);
      notifyListeners();
    });

    try {
      final profile = await _profileService.getUserProfile(userId: userId);
      _state = ProfileState(userProfile: profile, isLoading: false);
    } catch (e) {
      _state = ProfileState(isLoading: false, userProfile: _state.userProfile);
    }

    notifyListeners();
  }

  setStateForTest(ProfileState newState) {
    _state = newState;
  }

  Future<void> updateUserAvatar({
    required String userId,
    required ImageSourceType source,
  }) async {
    _state = ProfileState(isLoading: true, userProfile: _state.userProfile);
    notifyListeners();

    try {
      final newPhotoUrl = await _profileService.pickAndUploadAvatar(
        source: source,
      );

      if (newPhotoUrl != null) {
        final updatedProfile = _state.userProfile?.copyWith(
          photoUrl: newPhotoUrl,
        );
        _state = _state.copyWith(isLoading: false, userProfile: updatedProfile);
      } else {
        _state = _state.copyWith(isLoading: false);
      }
    } catch (e) {
      _state = ProfileState(
        isLoading: false,
        userProfile: _state.userProfile,
        errorMessage: 'Failed to upload avatar. Please try again.',
      );
    }
    notifyListeners();
  }
}
