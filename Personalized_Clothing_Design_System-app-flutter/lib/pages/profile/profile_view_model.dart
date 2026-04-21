import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service_providers.dart';
import '../../core/services/auth_service.dart';
import '../../core/storage/secure_storage.dart';
import 'profile_state.dart';

class ProfileViewModel extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    Future.microtask(() => loadProfile());
    return const ProfileState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.getMe();
      state = state.copyWith(
        isLoading: false,
        email: user.email,
        nickname: user.fullName,
        avatarUrl: user.avatarUrl,
      );
      await _loadStats();
    } catch (e) {
      // Token 可能过期，从本地读取邮箱作为备用
      final email = await SecureStorage.getEmail();
      state = state.copyWith(isLoading: false, email: email ?? '');
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ref.read(profileServiceProvider).getStats();
      state = state.copyWith(stats: stats);
    } catch (_) {}
  }

  void refreshStats() {
    Future.microtask(() => _loadStats());
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
      await ref.read(profileServiceProvider).deleteAccount();
      await SecureStorage.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);
