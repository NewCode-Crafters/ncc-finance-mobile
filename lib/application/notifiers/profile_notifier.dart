import 'package:flutter/foundation.dart';

import 'package:bytebank/domain/entities/user_profile.dart' as domain;
import 'package:bytebank/core/services/image_picker_service.dart';
import 'package:bytebank/domain/use_cases/profile/get_user_profile_use_case.dart';
import 'package:bytebank/domain/use_cases/profile/pick_and_upload_profile_picture_use_case.dart';

class ProfileState {
  final domain.UserProfile? userProfile;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({this.userProfile, this.isLoading = false, this.errorMessage});

  ProfileState copyWith({
    domain.UserProfile? userProfile,
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
  final GetUserProfileUseCase _getUserProfile;
  final PickAndUploadProfilePictureUseCase _pickAndUploadProfilePicture;

  ProfileState _state = ProfileState();

  ProfileState get state => _state;

  ProfileNotifier({
    required GetUserProfileUseCase getUserProfile,
    required PickAndUploadProfilePictureUseCase pickAndUploadProfilePicture,
  }) : _getUserProfile = getUserProfile,
       _pickAndUploadProfilePicture = pickAndUploadProfilePicture;

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

    Future.microtask(() {
      _state = ProfileState(isLoading: true, userProfile: _state.userProfile);
      notifyListeners();
    });

    try {
      final domainProfile = await _getUserProfile.call(userId: userId);
      _state = ProfileState(userProfile: domainProfile, isLoading: false);
    } catch (e) {
      _state = ProfileState(isLoading: false, userProfile: _state.userProfile);
    }

    notifyListeners();
  }

  // Helper used in tests
  void setStateForTest(ProfileState newState) {
    _state = newState;
  }

  Future<void> updateUserAvatar({
    required String userId,
    required ImageSourceType source,
  }) async {
    _state = ProfileState(isLoading: true, userProfile: _state.userProfile);
    notifyListeners();

    try {
      final newPhotoUrl = await _pickAndUploadProfilePicture.call(
        source: source,
      );

      if (newPhotoUrl != null && newPhotoUrl.isNotEmpty) {
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
