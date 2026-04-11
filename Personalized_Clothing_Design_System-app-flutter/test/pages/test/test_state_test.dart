import 'package:flutter_test/flutter_test.dart';

import 'package:personalized_clothing_design_system/core/network/api/website/model/app_setting.dart';
import 'package:personalized_clothing_design_system/pages/test/test_state.dart';

void main() {
  group('TestState', () {
    test('默认值应全部为初始状�?, () {
      const state = TestState();
      expect(state.appSetting, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.userId, isNull);
      expect(state.userEmail, isNull);
      expect(state.isAuthLoading, isFalse);
      expect(state.authError, isNull);
      expect(state.isSignUpMode, isFalse);
      expect(state.isOtpSent, isFalse);
    });

    test('isSignedIn 应在 userId 非空时返�?true', () {
      const signedOut = TestState();
      expect(signedOut.isSignedIn, isFalse);

      const signedIn = TestState(userId: 'uid-123');
      expect(signedIn.isSignedIn, isTrue);
    });

    group('copyWith', () {
      test('不传参数应返回相同�?, () {
        const original = TestState(
          isLoading: true,
          userId: 'uid',
          userEmail: 'a@b.com',
          isSignUpMode: true,
        );
        final copied = original.copyWith();
        expect(copied.isLoading, isTrue);
        expect(copied.userId, 'uid');
        expect(copied.userEmail, 'a@b.com');
        expect(copied.isSignUpMode, isTrue);
      });

      test('应只覆盖指定字段', () {
        const state = TestState();
        final updated = state.copyWith(isLoading: true, userId: 'abc');
        expect(updated.isLoading, isTrue);
        expect(updated.userId, 'abc');
        expect(updated.isSignUpMode, isFalse); // unchanged
      });

      test('clearError 应将 error 设为 null', () {
        const state = TestState(error: 'some error');
        final cleared = state.copyWith(clearError: true);
        expect(cleared.error, isNull);
      });

      test('clearError 时传入新 error 应仍�?null（clear 优先�?, () {
        const state = TestState(error: 'old');
        final cleared = state.copyWith(clearError: true, error: 'new');
        expect(cleared.error, isNull);
      });

      test('clearUser 应将 userId �?userEmail 设为 null', () {
        const state = TestState(userId: 'uid', userEmail: 'a@b.com');
        final cleared = state.copyWith(clearUser: true);
        expect(cleared.userId, isNull);
        expect(cleared.userEmail, isNull);
      });

      test('clearAuthError 应将 authError 设为 null', () {
        const state = TestState(authError: 'auth err');
        final cleared = state.copyWith(clearAuthError: true);
        expect(cleared.authError, isNull);
      });

      test('clearAppSetting 应将 appSetting 设为 null', () {
        const setting = AppSetting(websiteName: 'test');
        const state = TestState(appSetting: setting);
        final cleared = state.copyWith(clearAppSetting: true);
        expect(cleared.appSetting, isNull);
      });

      test('应能更新 appSetting', () {
        const setting = AppSetting(websiteName: 'PCDS');
        const state = TestState();
        final updated = state.copyWith(appSetting: setting);
        expect(updated.appSetting?.websiteName, 'PCDS');
      });
    });
  });
}
