import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'login_state.dart';
import 'login_view_model.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  // 是否处于注册模式（仅密码模式下有效）
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    final vm = ref.read(loginViewModelProvider.notifier);

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
                  style: AppTextStyles.headingLg.copyWith(color: AppColors.grey800),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── 模式切换 Tab ──────────────────────────────
                _ModeToggle(
                  current: state.loginMode,
                  onChanged: (mode) {
                    setState(() => _isRegisterMode = false);
                    _otpController.clear();
                    vm.switchMode(mode);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── 内容区 ────────────────────────────────────
                if (state.isPasswordMode)
                  _PasswordSection(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isRegister: _isRegisterMode,
                    state: state,
                    vm: vm,
                    onToggleRegister: () => setState(() => _isRegisterMode = !_isRegisterMode),
                    onSuccess: () => context.go(RouteName.main),
                  )
                else
                  _OtpSection(
                    emailController: _emailController,
                    otpController: _otpController,
                    state: state,
                    vm: vm,
                    onSuccess: () => context.go(RouteName.main),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 模式切换 ──────────────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.current, required this.onChanged});

  final LoginMode current;
  final ValueChanged<LoginMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _tab(context, LoginMode.password, '账号密码')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _tab(context, LoginMode.otp, '邮箱验证码')),
      ],
    );
  }

  Widget _tab(BuildContext context, LoginMode mode, String label) {
    final selected = current == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: selected ? Colors.white : AppColors.grey600,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ── 账号密码区 ────────────────────────────────────────────────────
class _PasswordSection extends ConsumerWidget {
  const _PasswordSection({
    required this.emailController,
    required this.passwordController,
    required this.isRegister,
    required this.state,
    required this.vm,
    required this.onToggleRegister,
    required this.onSuccess,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isRegister;
  final LoginState state;
  final LoginViewModel vm;
  final VoidCallback onToggleRegister;
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          onChanged: vm.setEmail,
          decoration: InputDecoration(
            hintText: FlutterI18n.translate(context, 'login.email_hint'),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: passwordController,
          onChanged: vm.setPassword,
          decoration: InputDecoration(
            hintText: FlutterI18n.translate(context, 'login.password_hint'),
          ),
          obscureText: true,
        ),
        _ErrorText(message: state.errorMessage),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () async {
                    final ok = isRegister
                        ? await vm.register()
                        : await vm.loginWithPassword();
                    if (ok && context.mounted) onSuccess();
                  },
            child: state.isLoading
                ? const _LoadingIndicator()
                : Text(isRegister
                    ? FlutterI18n.translate(context, 'login.sign_up')
                    : FlutterI18n.translate(context, 'login.sign_in')),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!isRegister)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showForgotPasswordDialog(context, vm),
              child: Text(
                FlutterI18n.translate(context, 'login.forgot_password'),
                style: AppTextStyles.bodySm.copyWith(color: AppColors.grey600),
              ),
            ),
          ),
        TextButton(
          onPressed: onToggleRegister,
          child: Text(
            isRegister
                ? FlutterI18n.translate(context, 'login.switch_to_sign_in')
                : FlutterI18n.translate(context, 'login.switch_to_sign_up'),
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  void _showForgotPasswordDialog(BuildContext context, LoginViewModel vm) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
              controller: ctrl,
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(FlutterI18n.translate(context, 'common.cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = ctrl.text.trim();
              if (email.isEmpty) return;
              Navigator.of(ctx).pop();
              try {
                await vm.resetPassword(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(FlutterI18n.translate(context, 'login.reset_password_sent')),
                    backgroundColor: Colors.green,
                  ));
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(FlutterI18n.translate(context, 'login.reset_password_failed')),
                    backgroundColor: Colors.red,
                  ));
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

// ── OTP 区 ────────────────────────────────────────────────────────
class _OtpSection extends StatelessWidget {
  const _OtpSection({
    required this.emailController,
    required this.otpController,
    required this.state,
    required this.vm,
    required this.onSuccess,
  });

  final TextEditingController emailController;
  final TextEditingController otpController;
  final LoginState state;
  final LoginViewModel vm;
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) {
    if (!state.isOtpInputStep) {
      // 第一步：输入邮箱
      return Column(
        children: [
          TextField(
            controller: emailController,
            onChanged: vm.setEmail,
            decoration: InputDecoration(
              hintText: FlutterI18n.translate(context, 'login.email_hint'),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          _ErrorText(message: state.errorMessage),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : vm.sendOtp,
              child: state.isLoading
                  ? const _LoadingIndicator()
                  : const Text('发送验证码'),
            ),
          ),
        ],
      );
    }

    // 第二步：输入6位验证码
    return Column(
      children: [
        Text(
          '验证码已发送至 ${state.email}',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.grey600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: otpController,
          onChanged: vm.setOtpCode,
          decoration: const InputDecoration(hintText: '请输入6位验证码'),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textAlign: TextAlign.center,
          style: AppTextStyles.headingLg,
        ),
        _ErrorText(message: state.errorMessage),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () async {
                    final ok = await vm.verifyOtp();
                    if (ok && context.mounted) onSuccess();
                  },
            child: state.isLoading ? const _LoadingIndicator() : const Text('验证登录'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: vm.backToEmailInput,
          child: Text(
            '重新发送',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// ── 公共小组件 ────────────────────────────────────────────────────
class _ErrorText extends StatelessWidget {
  const _ErrorText({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Text(
        message!,
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
