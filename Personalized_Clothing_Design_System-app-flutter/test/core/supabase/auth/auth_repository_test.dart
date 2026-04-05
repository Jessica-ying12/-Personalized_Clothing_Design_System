import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:livhome/core/supabase/auth/auth_repository.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late MockAuthRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockAuthRepository();
    container = createContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AuthRepository (via Provider)', () {
    test('provider 应返回注入的 mock 实例', () {
      final repo = container.read(authRepositoryProvider);
      expect(repo, same(mockRepo));
    });

    test('signInWithPassword 应调用底层方法', () async {
      when(() => mockRepo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => FakeAuthResponse());

      await container.read(authRepositoryProvider).signInWithPassword(
            email: 'a@b.com',
            password: '123456',
          );

      verify(() => mockRepo.signInWithPassword(
            email: 'a@b.com',
            password: '123456',
          )).called(1);
    });

    test('signOut 应调用底层方法', () async {
      when(() => mockRepo.signOut()).thenAnswer((_) async {});

      await container.read(authRepositoryProvider).signOut();

      verify(() => mockRepo.signOut()).called(1);
    });

    test('sendOtp 应调用底层方法', () async {
      when(() => mockRepo.sendOtp(email: any(named: 'email')))
          .thenAnswer((_) async {});

      await container.read(authRepositoryProvider).sendOtp(email: 'a@b.com');

      verify(() => mockRepo.sendOtp(email: 'a@b.com')).called(1);
    });

    test('currentUser 应返回 mock 配置的值', () {
      when(() => mockRepo.currentUser).thenReturn(null);
      expect(container.read(authRepositoryProvider).currentUser, isNull);
    });
  });
}
