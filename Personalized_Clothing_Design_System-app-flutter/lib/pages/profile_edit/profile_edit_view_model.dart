import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service_providers.dart';
import 'profile_edit_state.dart';

class ProfileEditViewModel extends Notifier<ProfileEditState> {
  @override
  ProfileEditState build() => const ProfileEditState();

  void initialize(String? fullName, String? avatarUrl) {
    state = state.copyWith(
      fullName: fullName ?? '',
      avatarUrl: avatarUrl,
    );
  }

  void setFullName(String fullName) {
    state = state.copyWith(fullName: fullName, errorMessage: null);
  }

  void setAvatarUrl(String avatarUrl) {
    state = state.copyWith(avatarUrl: avatarUrl, errorMessage: null);
  }

  Future<bool> updateProfile() async {
    if (state.fullName.isEmpty) {
      state = state.copyWith(errorMessage: '请输入昵称');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final profileService = ref.read(profileServiceProvider);
      await profileService.updateProfile(
        fullName: state.fullName,
        avatarUrl: state.avatarUrl,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

final profileEditViewModelProvider =
    NotifierProvider<ProfileEditViewModel, ProfileEditState>(
  ProfileEditViewModel.new,
);
