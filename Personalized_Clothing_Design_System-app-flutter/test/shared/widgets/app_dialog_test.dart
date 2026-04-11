import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personalized_clothing_design_system/app/theme/theme.dart';
import 'package:personalized_clothing_design_system/shared/widgets/dialogs/app_dialog.dart';

Widget _buildTestApp({required Widget child}) {
  return MaterialApp(home: child);
}

void main() {
  group('AppDialog', () {
    testWidgets('应显示标题和内容', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        child: const AppDialog(
          title: '删除确认',
          content: '确定要删除吗�?,
          confirmText: '确定',
          cancelText: '取消',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('删除确认'), findsOneWidget);
      expect(find.text('确定要删除吗�?), findsOneWidget);
    });

    testWidgets('�?content 时不显示内容文本', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        child: const AppDialog(
          title: '提示',
          confirmText: '确定',
          cancelText: '取消',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('提示'), findsOneWidget);
      // 应有两个按钮
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('应显示自定义按钮文本', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        child: const AppDialog(
          title: '测试',
          confirmText: '删除',
          cancelText: '返回',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('删除'), findsOneWidget);
      expect(find.text('返回'), findsOneWidget);
    });

    testWidgets('点击确认按钮应触发回�?, (tester) async {
      var confirmed = false;
      await tester.pumpWidget(_buildTestApp(
        child: AppDialog(
          title: '测试',
          confirmText: '确认',
          cancelText: '取消',
          onConfirm: () => confirmed = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('点击取消按钮应触发回�?, (tester) async {
      var cancelled = false;
      await tester.pumpWidget(_buildTestApp(
        child: AppDialog(
          title: '测试',
          confirmText: '确认',
          cancelText: '取消',
          onCancel: () => cancelled = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(cancelled, isTrue);
    });

    testWidgets('isDestructive 时确认按钮应使用 error 颜色', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        child: const AppDialog(
          title: '删除',
          confirmText: '删除',
          cancelText: '取消',
          isDestructive: true,
        ),
      ));
      await tester.pumpAndSettle();

      final buttons = find.byType(ElevatedButton);
      // 第二个按钮是确认按钮
      final confirmButton = tester.widget<ElevatedButton>(buttons.at(1));
      final bgColor = confirmButton.style!.backgroundColor!.resolve({});

      expect(bgColor, equals(AppColors.error));
    });

    testWidgets('AppDialog.show 应返�?true 当用户确�?, (tester) async {
      bool? result;
      await tester.pumpWidget(_buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await AppDialog.show(
                context,
                title: '确认操作',
                confirmText: '确认',
                cancelText: '取消',
              );
            },
            child: const Text('打开弹窗'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('打开弹窗'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('AppDialog.show 应返�?false 当用户取�?, (tester) async {
      bool? result;
      await tester.pumpWidget(_buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await AppDialog.show(
                context,
                title: '确认操作',
                confirmText: '确认',
                cancelText: '取消',
              );
            },
            child: const Text('打开弹窗'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('打开弹窗'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
