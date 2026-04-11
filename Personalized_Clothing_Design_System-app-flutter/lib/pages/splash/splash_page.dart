import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../core/storage/secure_storage.dart';

/// 启动�?- 检查登录状态并导航到相应页�?
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 延迟一小段时间显示启动�?
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      // 检查是否有保存�?token
      final token = await SecureStorage.getToken();
      
      if (token != null && token.isNotEmpty) {
        // �?token，尝试自动登录到主页
        if (mounted) {
          context.go(RouteName.main);
        }
      } else {
        // 没有 token，跳转到登录�?
        if (mounted) {
          context.go(RouteName.login);
        }
      }
    } catch (e) {
      // 出错时跳转到登录�?
      if (mounted) {
        context.go(RouteName.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用图标�?Logo
            Icon(
              Icons.checkroom,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            // 应用名称
            Text(
              '个性化服装设计系统',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            // 加载指示�?
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
