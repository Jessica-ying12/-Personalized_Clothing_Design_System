import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme.dart';
import '../../i18n/i18n.dart';
import '../../shared/shared.dart';
import 'test_view_model.dart';

class TestPage extends ConsumerStatefulWidget {
  const TestPage({super.key});

  @override
  ConsumerState<TestPage> createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testViewModelProvider);
    final vm = ref.read(testViewModelProvider.notifier);

    return Scaffold(
      appBar: AppNavigationBar(title: S.of(context, 'test.title')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: [
            FilledButton.icon(
              onPressed: state.isLoading ? null : vm.fetchAppSetting,
              icon: state.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_download_outlined),
              label: Text(S.of(context, 'test.fetch_post')),
            ),
            const SizedBox(height: AppSpacing.smd),
            FilledButton.icon(
              onPressed: () async {
                final confirmed = await AppDialog.show(
                  context,
                  title: S.of(context, 'test_dialog.title'),
                  content: S.of(context, 'test_dialog.content'),
                  confirmText: S.of(context, 'common.delete'),
                  isDestructive: true,
                );
                if (context.mounted && confirmed == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context, 'common.deleted_confirm')),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: Text(S.of(context, 'test_dialog.button')),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: _buildResult()),
            const Divider(height: AppSpacing.xl),
            _buildAuthSection(state, vm),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthSection(state, vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context, 'test.auth_section'),
          style: const TextStyle(fontWeight: AppFontWeight.semiBold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(
              state.isSignedIn
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 16,
              color: state.isSignedIn ? AppColors.success : AppColors.grey400,
            ),
            const SizedBox(width: 6),
            Text(
              state.isSignedIn
                  ? '${S.of(context, 'test.auth_status_signed_in')}  ${state.userEmail ?? state.userId}'
                  : S.of(context, 'test.auth_status_signed_out'),
              style: TextStyle(
                fontSize: AppFontSize.sm,
                color: state.isSignedIn ? AppColors.success : AppColors.grey400,
              ),
            ),
          ],
        ),
        if (state.authError != null) ...[
          const SizedBox(height: 6),
          Text(
            state.authError!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: AppFontSize.xs,
            ),
          ),
        ],
        if (!state.isSignedIn) ...[
          const SizedBox(height: AppSpacing.smd),
          TextField(
            controller: _emailCtrl,
            decoration: InputDecoration(
              hintText: S.of(context, 'test.email_hint'),
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !(state.isSignUpMode && state.isOtpSent),
          ),
          if (!state.isSignUpMode) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _passwordCtrl,
              decoration: InputDecoration(
                hintText: S.of(context, 'test.password_hint'),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
          if (state.isSignUpMode && state.isOtpSent) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _otpCtrl,
              decoration: InputDecoration(
                hintText: S.of(context, 'test.otp_hint'),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: AppSpacing.smd),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isAuthLoading
                  ? null
                  : () {
                      if (state.isSignUpMode) {
                        if (state.isOtpSent) {
                          vm.verifyOtp(
                            _emailCtrl.text.trim(),
                            _otpCtrl.text.trim(),
                          );
                        } else {
                          vm.sendOtp(_emailCtrl.text.trim());
                        }
                      } else {
                        vm.signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
                      }
                    },
              child: state.isAuthLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      S.of(
                        context,
                        state.isSignUpMode
                            ? (state.isOtpSent
                                  ? 'test.verify_otp'
                                  : 'test.send_otp')
                            : 'test.sign_in',
                      ),
                    ),
            ),
          ),
          TextButton(
            onPressed: () {
              vm.toggleMode();
              _otpCtrl.clear();
            },
            child: Text(
              S.of(
                context,
                state.isSignUpMode
                    ? 'test.switch_to_sign_in'
                    : 'test.switch_to_sign_up',
              ),
              style: const TextStyle(fontSize: AppFontSize.sm),
            ),
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.smd),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.isAuthLoading ? null : vm.signOut,
              child: state.isAuthLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(S.of(context, 'test.sign_out')),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResult() {
    final state = ref.watch(testViewModelProvider);

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.sm),
            Text(state.error!, style: const TextStyle(color: AppColors.error)),
          ],
        ),
      );
    }

    final setting = state.appSetting;
    if (setting == null) {
      return Center(
        child: Text(
          S.of(context, 'test.empty_hint'),
          style: const TextStyle(color: AppColors.grey400),
        ),
      );
    }

    return Card(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          Text(setting.websiteName ?? '', style: AppTextStyles.titleLg),
          const Divider(height: AppSpacing.lg),
          _infoRow('URL', setting.websiteUrl),
          _infoRow('ICP', setting.icpNumber),
          _infoRow('Company', setting.companyName),
          _infoRow('Phone', setting.companyPhone),
          _infoRow('Service Email', setting.customerServiceEmail),
          _infoRow('Business Email', setting.businessContactEmail),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.grey400,
                fontSize: AppFontSize.sm,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: AppFontSize.sm),
            ),
          ),
        ],
      ),
    );
  }
}
