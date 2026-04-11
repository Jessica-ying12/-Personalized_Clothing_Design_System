import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers/service_providers.dart';
import '../../core/supabase/auth/auth_repository.dart';
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
      // 从 Supabase session 直接获取基础信息
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // 从 profile-api 获取 profile 数据（含 full_name / avatar_url）
      final profileService = ref.read(profileServiceProvider);
      // getStats 顺带验证 token 有效性，profile 数据通过 auth-api /me 获取
      // 这里直接用 Supabase user_metadata 作为 fallback
      final meta = user.userMetadata;

      state = state.copyWith(
        isLoading: false,
        email: user.email ?? '',
        nickname: meta?['full_name'] as String?,
        avatarUrl: meta?['avatar_url'] as String?,
      );

      // 异步加载 stats（不阻塞 UI）
      _loadStats(profileService);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadStats(dynamic profileService) async {
    try {
      final stats = await profileService.getStats();
      state = state.copyWith(stats: stats);
    } catch (_) {}
  }

  Future<bool> logout() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      final profileService = ref.read(profileServiceProvider);
      await profileService.deleteAccount();
      // deleteAccount 后端会级联删除，signOut 清理本地 session
      await ref.read(authRepositoryProvider).signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);
