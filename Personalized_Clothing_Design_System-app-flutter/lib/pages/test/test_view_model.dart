import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api/website/website_api.dart';
import '../../core/network/client/dio_client.dart';
import '../../core/network/client/result.dart';
import '../../core/supabase/supabase.dart';
import '../../logger/logger.dart';
import 'test_state.dart';

final websiteApiProvider = Provider<WebsiteApi>((ref) {
  return WebsiteApi(ref.watch(dioProvider));
});

class TestViewModel extends Notifier<TestState> {
  @override
  TestState build() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) Log.i('[Auth] 已登录 uid=${user.id} email=${user.email}');
    return TestState(userId: user?.id, userEmail: user?.email);
  }

  Future<void> fetchAppSetting() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final api = ref.read(websiteApiProvider);
    final result = await apiCall(() => api.getAppSetting());

    switch (result) {
      case Success(:final data):
        if (data.isSuccess && data.data != null) {
          state = state.copyWith(appSetting: data.data, isLoading: false);
        } else {
          state = state.copyWith(error: data.msg ?? '请求失败', isLoading: false);
        }
      case Failure(:final exception):
        state = state.copyWith(error: exception.message, isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    Log.d('[Auth] signIn → email=$email');
    state = state.copyWith(isAuthLoading: true, clearAuthError: true);
    try {
      final res = await ref.read(authRepositoryProvider).signInWithPassword(
            email: email,
            password: password,
          );
      final user = res.user;
      Log.i('[Auth] signIn success uid=${user?.id} email=${user?.email}');
      state = state.copyWith(
        userId: user?.id,
        userEmail: user?.email,
        isAuthLoading: false,
      );
    } catch (e, st) {
      Log.e('[Auth] signIn failed', e, st);
      state = state.copyWith(authError: e.toString(), isAuthLoading: false);
    }
  }

  Future<void> signOut() async {
    Log.d('[Auth] signOut →');
    state = state.copyWith(isAuthLoading: true, clearAuthError: true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      Log.i('[Auth] signOut success');
      state = state.copyWith(isAuthLoading: false, clearUser: true);
    } catch (e, st) {
      Log.e('[Auth] signOut failed', e, st);
      state = state.copyWith(authError: e.toString(), isAuthLoading: false);
    }
  }

  Future<void> sendOtp(String email) async {
    Log.d('[Auth] sendOtp → email=$email');
    state = state.copyWith(isAuthLoading: true, clearAuthError: true);
    try {
      await ref.read(authRepositoryProvider).sendOtp(email: email);
      Log.i('[Auth] OTP sent to $email');
      state = state.copyWith(isAuthLoading: false, isOtpSent: true);
    } catch (e, st) {
      Log.e('[Auth] sendOtp failed', e, st);
      state = state.copyWith(authError: e.toString(), isAuthLoading: false);
    }
  }

  Future<void> verifyOtp(String email, String token) async {
    Log.d('[Auth] verifyOtp → email=$email');
    state = state.copyWith(isAuthLoading: true, clearAuthError: true);
    try {
      final res = await ref.read(authRepositoryProvider).verifyOtp(
            email: email,
            token: token,
          );
      final user = res.user;
      Log.i('[Auth] verifyOtp success uid=${user?.id} email=${user?.email}');
      state = state.copyWith(
        userId: user?.id,
        userEmail: user?.email,
        isAuthLoading: false,
        isOtpSent: false,
      );
    } catch (e, st) {
      Log.e('[Auth] verifyOtp failed', e, st);
      state = state.copyWith(authError: e.toString(), isAuthLoading: false);
    }
  }

  void toggleMode() => state = state.copyWith(
        isSignUpMode: !state.isSignUpMode,
        clearAuthError: true,
        isOtpSent: false,
      );
}

final testViewModelProvider =
    NotifierProvider<TestViewModel, TestState>(TestViewModel.new);
