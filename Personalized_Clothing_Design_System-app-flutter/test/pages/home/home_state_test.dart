import 'package:flutter_test/flutter_test.dart';

import 'package:personalized_clothing_design_system/pages/home/home_state.dart';

void main() {
  group('HomeState', () {
    test('默认值应�?isSidebarOpen=false, selectedIndex=1', () {
      const state = HomeState();
      expect(state.isSidebarOpen, isFalse);
      expect(state.selectedIndex, 1);
    });

    test('copyWith 不传参数应返回相同值的新实�?, () {
      const state = HomeState(isSidebarOpen: true, selectedIndex: 2);
      final copied = state.copyWith();
      expect(copied.isSidebarOpen, isTrue);
      expect(copied.selectedIndex, 2);
    });

    test('copyWith 应只覆盖指定字段', () {
      const state = HomeState();

      final s1 = state.copyWith(isSidebarOpen: true);
      expect(s1.isSidebarOpen, isTrue);
      expect(s1.selectedIndex, 1);

      final s2 = state.copyWith(selectedIndex: 0);
      expect(s2.isSidebarOpen, isFalse);
      expect(s2.selectedIndex, 0);
    });
  });
}
