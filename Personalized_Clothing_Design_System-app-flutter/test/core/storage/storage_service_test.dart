import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:personalized_clothing_design_system/core/storage/storage_service.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockBox mockBox;
  late StorageService service;

  setUp(() {
    mockBox = MockBox();
    service = StorageService(mockBox);
  });

  group('StorageService', () {
    group('get', () {
      test('key 存在时应返回对应�?, () {
        when(() => mockBox.get('foo')).thenReturn('bar');
        expect(service.get<String>('foo'), 'bar');
      });

      test('key 不存在时应返�?null', () {
        when(() => mockBox.get('missing')).thenReturn(null);
        expect(service.get<String>('missing'), isNull);
      });
    });

    group('getOrDefault', () {
      test('key 存在时应返回对应�?, () {
        when(() => mockBox.get('count')).thenReturn(42);
        expect(service.getOrDefault<int>('count', 0), 42);
      });

      test('key 不存在时应返回默认�?, () {
        when(() => mockBox.get('count')).thenReturn(null);
        expect(service.getOrDefault<int>('count', 0), 0);
      });
    });

    group('put', () {
      test('应调�?box.put', () async {
        when(() => mockBox.put('key', 'value')).thenAnswer((_) async {});
        await service.put('key', 'value');
        verify(() => mockBox.put('key', 'value')).called(1);
      });
    });

    group('delete', () {
      test('应调�?box.delete', () async {
        when(() => mockBox.delete('key')).thenAnswer((_) async {});
        await service.delete('key');
        verify(() => mockBox.delete('key')).called(1);
      });
    });

    group('containsKey', () {
      test('key 存在时应返回 true', () {
        when(() => mockBox.containsKey('k')).thenReturn(true);
        expect(service.containsKey('k'), isTrue);
      });

      test('key 不存在时应返�?false', () {
        when(() => mockBox.containsKey('nope')).thenReturn(false);
        expect(service.containsKey('nope'), isFalse);
      });
    });

    group('clear', () {
      test('应调�?box.clear 并返回删除数�?, () async {
        when(() => mockBox.clear()).thenAnswer((_) async => 5);
        final count = await service.clear();
        expect(count, 5);
        verify(() => mockBox.clear()).called(1);
      });
    });
  });
}
