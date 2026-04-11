import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'login_view_model.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    final viewModel = ref.read(loginViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  FlutterI18n.translate(context, 'login.title'),
                  style: AppTextStyles.headingLg.copyWith(
                    color: AppColors.grey800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                TextField(
                  controller: _emailController,
                  onChanged: viewModel.setEmail,
                  decoration: InputDecoration(
                    hintText: FlutterI18n.translate(context, 'login.email_hint'),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _passwordController,
                  onChanged: viewModel.setPassword,
                  decoration: InputDecoration(
                    hintText: FlutterI18n.translate(context, 'login.password_hint'),
                  ),
                  obscureText: true,
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    state.errorMessage!,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            final success = state.isLoginMode
                                ? await viewModel.login()
                                : await viewModel.register();
                            if (success && context.mounted) {
                              context.go(RouteName.main);
                            }
                          },
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            FlutterI18n.translate(
                              context,
                              state.isLoginMode ? 'login.sign_in' : 'login.sign_up',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // 忘记密码链接（仅在登录模式显示）
                if (state.isLoginMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(context, viewModel),
                      child: Text(
                        FlutterI18n.translate(context, 'login.forgot_password'),
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: viewModel.toggleMode,
                  child: Text(
                    FlutterI18n.translate(
                      context,
                      state.isLoginMode
                          ? 'login.switch_to_sign_up'
                          : 'login.switch_to_sign_in',
                    ),
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context, LoginViewModel viewModel) {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(FlutterI18n.translate(context, 'login.forgot_password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FlutterI18n.translate(context, 'login.forgot_password_hint'),
              style: AppTextStyles.bodySm.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: FlutterI18n.translate(context, 'login.email'),
                hintText: FlutterI18n.translate(context, 'login.email_hint'),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterI18n.translate(context, 'common.cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(FlutterI18n.translate(context, 'login.email_required')),
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              try {
                await viewModel.resetPassword(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(FlutterI18n.translate(context, 'login.reset_password_sent')),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(FlutterI18n.translate(context, 'login.reset_password_failed')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(FlutterI18n.translate(context, 'login.send_reset_link')),
          ),
        ],
      ),
    );
  }
}
