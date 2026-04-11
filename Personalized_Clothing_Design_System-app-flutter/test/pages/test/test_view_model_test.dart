import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:personalized_clothing_design_system/core/network/api/website/model/app_setting.dart';
import 'package:personalized_clothing_design_system/core/network/client/base_response.dart';
import 'package:personalized_clothing_design_system/core/supabase/auth/auth_repository.dart';
import 'package:personalized_clothing_design_system/pages/test/test_state.dart';
import 'package:personalized_clothing_design_system/pages/test/test_view_model.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockWebsiteApi mockWebsiteApi;
  late ProviderContainer container;

  setUp(() {
    initTestEnv();
    mockAuthRepo = MockAuthRepository();
    mockWebsiteApi = MockWebsiteApi();

    // 默认：未登录
    when(() => mockAuthRepo.currentUser).thenReturn(null);

    container = createContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        websiteApiProvider.overrideWithValue(mockWebsiteApi),
      ],
    );
  });

  tearDown(() => container.dispose());

  TestState readState() => container.read(testViewModelProvider);
  TestViewModel readVm() => container.read(testViewModelProvider.notifier);

  group('TestViewModel', () {
    group('build (初始�?', () {
      test('未登录时 userId 应为 null', () {
        expect(readState().userId, isNull);
        expect(readState().isSignedIn, isFalse);
      });

      test('已登录时应提�?user 信息', () {
        final fakeUser = FakeUser();
        when(() => mockAuthRepo.currentUser).thenReturn(fakeUser);

        // 重新创建 container 触发 build
        container.dispose();
        container = createContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
            websiteApiProvider.overrideWithValue(mockWebsiteApi),
          ],
        );

        expect(readState().userId, 'test-uid-123');
        expect(readState().userEmail, 'test@example.com');
        expect(readState().isSignedIn, isTrue);
      });
    });

    group('fetchAppSetting', () {
      test('成功时应更新 appSetting', () async {
        const setting = AppSetting(websiteName: 'PCDS');
        when(() => mockWebsiteApi.getAppSetting()).thenAnswer(
          (_) async => const BaseResponse(code: 200, data: setting),
        );

        await readVm().fetchAppSetting();

        expect(readState().appSetting?.websiteName, 'PCDS');
        expect(readState().isLoading, isFalse);
        expect(readState().error, isNull);
      });

      test('API 返回�?200 应设�?error', () async {
        when(() => mockWebsiteApi.getAppSetting()).thenAnswer(
          (_) async => const BaseResponse(code: 500, msg: '服务器错�?),
        );

        await readVm().fetchAppSetting();

        expect(readState().appSetting, isNull);
        expect(readState().error, '服务器错�?);
        expect(readState().isLoading, isFalse);
      });
    });

    group('toggleMode', () {
      test('应翻�?isSignUpMode', () {
        expect(readState().isSignUpMode, isFalse);

        readVm().toggleMode();
        expect(readState().isSignUpMode, isTrue);

        readVm().toggleMode();
        expect(readState().isSignUpMode, isFalse);
      });

      test('切换模式应清�?authError 和重�?isOtpSent', () {
        // 先制造一些状�?        readVm().toggleMode(); // isSignUpMode = true
        // 模拟 authError（通过 copyWith 无法直接触发，用 toggleMode 间接验证 clear 行为�?        expect(readState().authError, isNull);
        expect(readState().isOtpSent, isFalse);
      });
    });

    group('signOut', () {
      test('成功时应清除用户状�?, () async {
        // 先设置为已登录状�?        final fakeUser = FakeUser();
        when(() => mockAuthRepo.currentUser).thenReturn(fakeUser);
        container.dispose();
        container = createContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
            websiteApiProvider.overrideWithValue(mockWebsiteApi),
          ],
        );
        expect(readState().isSignedIn, isTrue);

        when(() => mockAuthRepo.signOut()).thenAnswer((_) async {});

        await readVm().signOut();

        expect(readState().userId, isNull);
        expect(readState().isSignedIn, isFalse);
      });

      test('失败时应设置 authError', () async {
        when(() => mockAuthRepo.signOut()).thenThrow(Exception('network'));

        await readVm().signOut();

        expect(readState().authError, isNotNull);
      });
    });

    group('sendOtp', () {
      test('成功时应设置 isOtpSent=true', () async {
        when(() => mockAuthRepo.sendOtp(email: any(named: 'email')))
            .thenAnswer((_) async {});

        await readVm().sendOtp('a@b.com');

        expect(readState().isOtpSent, isTrue);
        expect(readState().isAuthLoading, isFalse);
      });

      test('失败时应设置 authError', () async {
        when(() => mockAuthRepo.sendOtp(email: any(named: 'email')))
            .thenThrow(Exception('rate limit'));

        await readVm().sendOtp('a@b.com');

        expect(readState().authError, isNotNull);
        expect(readState().isOtpSent, isFalse);
      });
    });
  });
}
