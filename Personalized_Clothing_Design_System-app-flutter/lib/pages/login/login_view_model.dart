import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service_providers.dart';
import '../../logger/logger.dart';
import 'login_state.dart';

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void setEmail(String v) => state = state.copyWith(email: v, clearError: true);
  void setPassword(String v) => state = state.copyWith(password: v, clearError: true);
  void setOtpCode(String v) => state = state.copyWith(otpCode: v, clearError: true);

  void switchMode(LoginMode mode) {
    state = LoginState(loginMode: mode);
  }

  // ── 账号密码登录 ──────────────────────────────────────────────
  Future<bool> loginWithPassword() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessageKey: 'login.error_empty_email_password');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    Log.i('[Auth] login email=${state.email}');

    try {
      final authService = ref.read(authServiceProvider);
      await authService.login(email: state.email, password: state.password);
      Log.i('[Auth] login success');
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      Log.e('[Auth] login failed', e, st);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ── 注册 ──────────────────────────────────────────────────────
  Future<bool> register() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessageKey: 'login.error_empty_email_password');
      return false;
    }
    if (state.password.length < 6) {
      state = state.copyWith(errorMessageKey: 'login.error_password_too_short');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    Log.i('[Auth] register email=${state.email}');

    try {
      final authService = ref.read(authServiceProvider);
      await authService.register(email: state.email, password: state.password);
      Log.i('[Auth] register success');
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      Log.e('[Auth] register failed', e, st);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ── OTP：发送验证码 ───────────────────────────────────────────
  Future<void> sendOtp() async {
    if (state.email.isEmpty) {
      state = state.copyWith(errorMessageKey: 'login.error_empty_email');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    Log.i('[Auth] sendOtp email=${state.email}');

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendOtp(email: state.email);
      Log.i('[Auth] sendOtp success');
      state = state.copyWith(isLoading: false, otpStep: OtpStep.inputCode);
    } catch (e, st) {
      Log.e('[Auth] sendOtp failed', e, st);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── OTP：验证验证码 ───────────────────────────────────────────
  Future<bool> verifyOtp() async {
    if (state.otpCode.length != 6) {
      state = state.copyWith(errorMessageKey: 'login.error_invalid_otp');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    Log.i('[Auth] verifyOtp email=${state.email}');

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyOtp(email: state.email, code: state.otpCode);
      Log.i('[Auth] verifyOtp success');
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      Log.e('[Auth] verifyOtp failed', e, st);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void backToEmailInput() {
    state = state.copyWith(otpStep: OtpStep.inputEmail, otpCode: '', clearError: true);
  }

  // ── 重置密码 ──────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    Log.i('[Auth] resetPassword email=$email');
    final authService = ref.read(authServiceProvider);
    await authService.sendOtp(email: email);
    Log.i('[Auth] resetPassword otp sent');
  }
}

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);
