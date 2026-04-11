import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personalized_clothing_design_system/pages/home/home_state.dart';
import 'package:personalized_clothing_design_system/pages/home/home_view_model.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = createContainer();
  });

  tearDown(() => container.dispose());

  HomeState readState() => container.read(homeViewModelProvider);
  HomeViewModel readVm() => container.read(homeViewModelProvider.notifier);

  group('HomeViewModel', () {
    test('初始状�?selectedIndex 应为 1', () {
      expect(readState().selectedIndex, 1);
    });

    test('初始状�?isSidebarOpen 应为 false', () {
      expect(readState().isSidebarOpen, isFalse);
    });

    group('switchTab', () {
      test('应切换到目标索引', () {
        readVm().switchTab(0);
        expect(readState().selectedIndex, 0);

        readVm().switchTab(2);
        expect(readState().selectedIndex, 2);
      });

      test('切换到当前索引不应触发状态变�?, () {
        // 监听状态变更次�?        var changeCount = 0;
        container.listen(homeViewModelProvider, (_, __) => changeCount++);

        readVm().switchTab(1); // 默认就是 1
        expect(changeCount, 0);
      });
    });

    group('toggleSidebar', () {
      test('应翻�?isSidebarOpen', () {
        expect(readState().isSidebarOpen, isFalse);

        readVm().toggleSidebar();
        expect(readState().isSidebarOpen, isTrue);

        readVm().toggleSidebar();
        expect(readState().isSidebarOpen, isFalse);
      });
    });

    group('closeSidebar', () {
      test('应将 isSidebarOpen 设为 false', () {
        readVm().toggleSidebar(); // open
        expect(readState().isSidebarOpen, isTrue);

        readVm().closeSidebar();
        expect(readState().isSidebarOpen, isFalse);
      });

      test('已关闭状态调�?closeSidebar 应保�?false', () {
        readVm().closeSidebar();
        expect(readState().isSidebarOpen, isFalse);
      });
    });
  });
}
