import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service_providers.dart';
import 'profile_state.dart';

class ProfileViewModel extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    loadProfile();
    return const ProfileState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.getMe();

      state = state.copyWith(
        isLoading: false,
        avatarUrl: user.avatarUrl,
        nickname: user.fullName,
        email: user.email,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> logout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      final profileService = ref.read(profileServiceProvider);
      await profileService.deleteAccount();
      
      final authService = ref.read(authServiceProvider);
      await authService.logout();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);
