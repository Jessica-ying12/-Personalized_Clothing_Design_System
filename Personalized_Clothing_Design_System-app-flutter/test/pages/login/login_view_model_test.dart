import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personalized_clothing_design_system/pages/login/login_state.dart';
import 'package:personalized_clothing_design_system/pages/login/login_view_model.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => initTestEnv());

  group('LoginState', () {
    test('默认值正确', () {
      const state = LoginState();
      expect(state.email, '');
      expect(state.password, '');
      expect(state.isLoading, false);
      expect(state.loginMode, LoginMode.password);
      expect(state.hasError, false);
    });

    test('copyWith 正确更新字段', () {
      const state = LoginState();
      final updated = state.copyWith(email: 'test@example.com', isLoading: true);
      expect(updated.email, 'test@example.com');
      expect(updated.isLoading, true);
      expect(updated.password, '');
    });

    test('clearError 清除错误信息', () {
      const state = LoginState(errorMessage: '登录失败');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.hasError, false);
      expect(cleared.errorMessage, null);
    });

    test('isPasswordMode 和 isOtpMode 互斥', () {
      const pwState = LoginState(loginMode: LoginMode.password);
      expect(pwState.isPasswordMode, true);
      expect(pwState.isOtpMode, false);

      const otpState = LoginState(loginMode: LoginMode.otp);
      expect(otpState.isPasswordMode, false);
      expect(otpState.isOtpMode, true);
    });
  });

  group('LoginViewModel (Mock 模式)', () {
    late ProviderContainer container;

    setUp(() {
      container = createContainer();
    });

    tearDown(() => container.dispose());

    test('setEmail 更新 email 并清除错误', () {
      final vm = container.read(loginViewModelProvider.notifier);
      // 先设置一个错误
      container.read(loginViewModelProvider.notifier)
          .state = const LoginState(errorMessage: '旧错误');

      vm.setEmail('new@example.com');
      final state = container.read(loginViewModelProvider);
      expect(state.email, 'new@example.com');
      expect(state.hasError, false);
    });

    test('setPassword 更新 password', () {
      final vm = container.read(loginViewModelProvider.notifier);
      vm.setPassword('123456');
      expect(container.read(loginViewModelProvider).password, '123456');
    });

    test('switchMode 切换登录模式并重置状态', () {
      final vm = container.read(loginViewModelProvider.notifier);
      vm.setEmail('test@example.com');
      vm.switchMode(LoginMode.otp);
      final state = container.read(loginViewModelProvider);
      expect(state.loginMode, LoginMode.otp);
      expect(state.email, ''); // 切换模式后重置
    });

    test('loginWithPassword 空邮箱时返回 false 并设置错误', () async {
      final vm = container.read(loginViewModelProvider.notifier);
      final result = await vm.loginWithPassword();
      expect(result, false);
      expect(container.read(loginViewModelProvider).hasError, true);
    });

    test('loginWithPassword Mock 模式任意账号登录成功', () async {
      final vm = container.read(loginViewModelProvider.notifier);
      vm.setEmail('demo@test.com');
      vm.setPassword('123456');
      final result = await vm.loginWithPassword();
      expect(result, true);
      expect(container.read(loginViewModelProvider).isLoading, false);
      expect(container.read(loginViewModelProvider).hasError, false);
    });

    test('register 密码少于6位时返回 false', () async {
      final vm = container.read(loginViewModelProvider.notifier);
      vm.setEmail('test@example.com');
      vm.setPassword('123');
      final result = await vm.register();
      expect(result, false);
      expect(container.read(loginViewModelProvider).hasError, true);
    });

    test('register Mock 模式成功注册', () async {
      final vm = container.read(loginViewModelProvider.notifier);
      vm.setEmail('new@example.com');
      vm.setPassword('password123');
      final result = await vm.register();
      expect(result, true);
    });

    test('sendOtp 空邮箱时设置错误', () async {
      final vm = container.read(loginViewModelProvider.notifier);
      await vm.sendOtp();
      expect(container.read(loginViewModelProvider).hasError, true);
    });

    test('sendOtp Mock 模式成功发送后进入验证码步骤', () async {
      final vm = container.read(loginViewModelProvider.notifier);
      vm.setEmail('test@example.com');
      await vm.sendOtp();
      expect(container.read(loginViewModelProvider).otpStep, OtpStep.inputCode);
    });

    test('verifyOtp 验证码不足6位时返回 false', () async {
      final vm = container.read(loginViewModelProvider.notifier);
      vm.setOtpCode('123');
      final result = await vm.verifyOtp();
      expect(result, false);
    });

    test('verifyOtp Mock 模式任意6位验证码通过', () async {
      final vm = container.read(loginViewModelProvider.notifier);
      vm.setEmail('test@example.com');
      vm.setOtpCode('123456');
      final result = await vm.verifyOtp();
      expect(result, true);
    });

    test('backToEmailInput 返回邮箱输入步骤', () {
      final vm = container.read(loginViewModelProvider.notifier);
      vm.state = const LoginState(otpStep: OtpStep.inputCode, otpCode: '123456');
      vm.backToEmailInput();
      final state = container.read(loginViewModelProvider);
      expect(state.otpStep, OtpStep.inputEmail);
      expect(state.otpCode, '');
    });
  });
}
