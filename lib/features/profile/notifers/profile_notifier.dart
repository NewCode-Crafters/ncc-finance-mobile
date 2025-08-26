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

  Future<void> fetchUserProfile({required String userId}) async {
    _state = ProfileState(isLoading: true);
    notifyListeners();

    try {
      final profile = await _profileService.getUserProfile(userId: userId);
      _state = ProfileState(userProfile: profile, isLoading: false);
    } catch (e) {
      _state = ProfileState(isLoading: false);
    }

    notifyListeners();
  }

  setStateForTest(ProfileState newState) {
    _state = newState;
  }
}
