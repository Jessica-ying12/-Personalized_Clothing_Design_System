import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/auth/auth_repository.dart';
import 'login_state.dart';

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  void setEmail(String v) => state = state.copyWith(email: v, clearError: true);
  void setPassword(String v) => state = state.copyWith(password: v, clearError: true);
  void setOtpCode(String v) => state = state.copyWith(otpCode: v, clearError: true);

  void switchMode(LoginMode mode) {
    state = LoginState(loginMode: mode);
  }

  // ── 账号密码登录 ──────────────────────────────────────────────
  Future<bool> loginWithPassword() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessage: '请输入邮箱和密码');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _auth.signInWithPassword(email: state.email, password: state.password);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ── 注册 ──────────────────────────────────────────────────────
  Future<bool> register() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessage: '请输入邮箱和密码');
      return false;
    }
    if (state.password.length < 6) {
      state = state.copyWith(errorMessage: '密码至少6个字符');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _auth.signUp(email: state.email, password: state.password);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ── OTP：发送验证码 ───────────────────────────────────────────
  Future<void> sendOtp() async {
    if (state.email.isEmpty) {
      state = state.copyWith(errorMessage: '请输入邮箱');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _auth.sendOtp(email: state.email);
      state = state.copyWith(isLoading: false, otpStep: OtpStep.inputCode);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── OTP：验证验证码 ───────────────────────────────────────────
  Future<bool> verifyOtp() async {
    if (state.otpCode.length != 6) {
      state = state.copyWith(errorMessage: '请输入6位验证码');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _auth.verifyOtp(email: state.email, token: state.otpCode);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void backToEmailInput() {
    state = state.copyWith(otpStep: OtpStep.inputEmail, otpCode: '', clearError: true);
  }

  // ── 重置密码 ──────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    await _auth.sendOtp(email: email);
  }
}

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);
