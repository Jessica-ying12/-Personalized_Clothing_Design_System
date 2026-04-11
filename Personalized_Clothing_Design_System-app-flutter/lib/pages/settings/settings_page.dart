import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'settings_view_model.dart';

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'settings.title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // 语言设置
          _buildSection(
            context,
            'settings.language_section',
            [
              _buildLanguageItem(
                context,
                'settings.chinese',
                'zh_CN',
                state.currentLanguage,
                viewModel.changeLanguage,
              ),
              _buildLanguageItem(
                context,
                'settings.english',
                'en',
                state.currentLanguage,
                viewModel.changeLanguage,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 通知设置
          _buildSection(
            context,
            'settings.notification_section',
            [
              _buildSwitchItem(
                context,
                'settings.enable_notifications',
                state.notificationsEnabled,
                viewModel.toggleNotifications,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 缓存设置
          _buildSection(
            context,
            'settings.cache_section',
            [
              _buildActionItem(
                context,
                'settings.clear_cache',
                Icons.delete_outline,
                () => _showClearCacheDialog(context, viewModel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 关于
          _buildSection(
            context,
            'settings.about_section',
            [
              _buildInfoItem(
                context,
                'settings.version',
                state.appVersion,
              ),
              _buildActionItem(
                context,
                'settings.privacy_policy',
                Icons.privacy_tip_outlined,
                () => _showPrivacyPolicy(context),
              ),
              _buildActionItem(
                context,
                'settings.terms_of_service',
                Icons.description_outlined,
                () => _showTermsOfService(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String titleKey,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text(
            FlutterI18n.translate(context, titleKey),
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildLanguageItem(
    BuildContext context,
    String labelKey,
    String languageCode,
    String currentLanguage,
    Function(String) onChanged,
  ) {
    final isSelected = currentLanguage == languageCode;
    
    return InkWell(
      onTap: () => onChanged(languageCode),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                FlutterI18n.translate(context, labelKey),
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.grey800,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    BuildContext context,
    String labelKey,
    bool value,
    VoidCallback onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              FlutterI18n.translate(context, labelKey),
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.grey800,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) => onChanged(),
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String labelKey,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey600, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                FlutterI18n.translate(context, labelKey),
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.grey800,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String labelKey,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              FlutterI18n.translate(context, labelKey),
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.grey800,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(FlutterI18n.translate(context, 'settings.clear_cache_confirm_title')),
        content: Text(FlutterI18n.translate(context, 'settings.clear_cache_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterI18n.translate(context, 'common.cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await viewModel.clearCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      FlutterI18n.translate(context, 'settings.cache_cleared'),
                    ),
                  ),
                );
              }
            },
            child: Text(FlutterI18n.translate(context, 'common.confirm')),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // TODO: 显示隐私政策
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          FlutterI18n.translate(context, 'settings.coming_soon'),
        ),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    // TODO: 显示服务条款
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          FlutterI18n.translate(context, 'settings.coming_soon'),
        ),
      ),
    );
  }
}
