import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livhome/app/theme/theme.dart';
import 'package:livhome/shared/widgets/navigation/app_navigation_bar.dart';

Widget _buildApp({required Widget child, bool withNavigation = true}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: withNavigation
        ? Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
          )
        : child,
  );
}

void main() {
  group('AppNavigationBar', () {
    testWidgets('默认渲染返回按钮和标题', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: Scaffold(appBar: AppNavigationBar(title: '测试页面')),
        ),
      );

      expect(find.text('测试页面'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('showBackButton 为 false 时不显示返回按钮', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: Scaffold(
            appBar: AppNavigationBar(title: '首页', showBackButton: false),
          ),
          withNavigation: false,
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
    });

    testWidgets('传入 leading 时替代返回按钮', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: Scaffold(
            appBar: AppNavigationBar(
              title: '菜单页',
              leading: const Icon(Icons.menu, key: Key('menu_icon')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('menu_icon')), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
    });

    testWidgets('actions 正确渲染', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: Scaffold(
            appBar: AppNavigationBar(
              title: '设置',
              actions: [
                IconButton(
                  key: const Key('action_1'),
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                ),
                IconButton(
                  key: const Key('action_2'),
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('action_1')), findsOneWidget);
      expect(find.byKey(const Key('action_2')), findsOneWidget);
    });

    testWidgets('titleWidget 优先于 title 渲染', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: Scaffold(
            appBar: AppNavigationBar(
              title: '不应显示',
              titleWidget: const Text('自定义标题', key: Key('custom_title')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_title')), findsOneWidget);
      expect(find.text('不应显示'), findsNothing);
    });

    testWidgets('自定义 backgroundColor 生效', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: Scaffold(
            appBar: AppNavigationBar(
              title: '自定义背景',
              backgroundColor: AppColors.primaryLight,
            ),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.primaryLight);
    });

    testWidgets('gradient 模式下 AppBar 背景透明', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: Scaffold(
            appBar: AppNavigationBar(
              title: '渐变导航栏',
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.transparent);
      expect(appBar.elevation, 0);
    });

    testWidgets('gradient 模式下存在渐变容器', (tester) async {
      const testGradient = LinearGradient(
        colors: [AppColors.primary, AppColors.primaryDark],
      );

      await tester.pumpWidget(
        _buildApp(
          child: Scaffold(
            appBar: AppNavigationBar(title: '渐变导航栏', gradient: testGradient),
          ),
        ),
      );

      // 验证存在带 BoxDecoration 的 Container
      final decoratedBoxFinder = find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).gradient != null,
      );
      expect(decoratedBoxFinder, findsOneWidget);
    });

    testWidgets('foregroundColor 传递到 AppBar', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: Scaffold(
            appBar: AppNavigationBar(
              title: '白色前景',
              foregroundColor: AppColors.surface,
            ),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.foregroundColor, AppColors.surface);
    });

    testWidgets('实现 PreferredSizeWidget 接口', (tester) async {
      final bar = AppNavigationBar(title: '测试');
      expect(bar, isA<PreferredSizeWidget>());
      expect(bar.preferredSize.height, kToolbarHeight);
    });

    testWidgets('title 为 null 时不渲染标题文本', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: Scaffold(appBar: AppNavigationBar(showBackButton: false)),
          withNavigation: false,
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isNull);
    });
  });
}
