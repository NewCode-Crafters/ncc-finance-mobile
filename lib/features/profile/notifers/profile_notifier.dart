import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/features/profile/models/user_profile.dart';
import 'package:flutter_application_1/features/profile/services/profile_service.dart';

class ProfileState {
  final UserProfile? userProfile;
  final bool isLoading;

  ProfileState({this.userProfile, this.isLoading = false});
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
}
