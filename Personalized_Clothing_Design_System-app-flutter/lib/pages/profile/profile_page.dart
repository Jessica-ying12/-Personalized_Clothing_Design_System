import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'profile_state.dart';
import 'profile_view_model.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);
    final viewModel = ref.read(profileViewModelProvider.notifier);

    // 每次进入页面刷新统计数据（只监听，不主动触发循环）
    ref.listen(profileViewModelProvider, (_, __) {});

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'profile.title')),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildProfileHeader(context, state, viewModel),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMenuItem(
                    context,
                    Icons.history,
                    'profile.history',
                    () => context.push(RouteName.history),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildMenuItem(
                    context,
                    Icons.logout,
                    'profile.logout',
                    () => _showLogoutDialog(context, viewModel),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildMenuItem(
                    context,
                    Icons.delete_forever,
                    'profile.delete_account',
                    () => _showDeleteAccountDialog(context, viewModel),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileState state, ProfileViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: state.avatarUrl != null
                    ? NetworkImage(state.avatarUrl!) : null,
                child: state.avatarUrl == null
                    ? const Icon(Icons.person, size: 40) : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.nickname ?? '',
                      style: AppTextStyles.titleLg.copyWith(color: AppColors.grey800),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      state.email ?? '',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.primary),
                onPressed: () async {
                  final result = await context.push(
                    RouteName.profileEdit,
                    extra: {'fullName': state.nickname, 'avatarUrl': state.avatarUrl},
                  );
                  if (result == true) viewModel.loadProfile();
                },
              ),
            ],
          ),
          if (state.stats != null) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildStatItem(
                  context,
                  '${state.stats!['flat_total'] ?? 0}',
                  FlutterI18n.translate(context, 'profile.stat_flat_total'),
                  Icons.image_outlined,
                ),
                _buildStatDivider(),
                _buildStatItem(
                  context,
                  '${state.stats!['flat_saved'] ?? 0}',
                  FlutterI18n.translate(context, 'profile.stat_flat_saved'),
                  Icons.bookmark_outline,
                ),
                _buildStatDivider(),
                _buildStatItem(
                  context,
                  '${state.stats!['design_3d_total'] ?? 0}',
                  FlutterI18n.translate(context, 'profile.stat_3d_total'),
                  Icons.view_in_ar_outlined,
                ),
                _buildStatDivider(),
                _buildStatItem(
                  context,
                  '${state.stats!['design_3d_saved'] ?? 0}',
                  FlutterI18n.translate(context, 'profile.stat_3d_saved'),
                  Icons.collections_outlined,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.titleMd.copyWith(
              color: AppColors.grey800, fontWeight: AppFontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(color: AppColors.grey500),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: AppColors.grey200);
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String labelKey,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.grey600,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                FlutterI18n.translate(context, labelKey),
                style: AppTextStyles.bodyMd.copyWith(
                  color: isDestructive ? AppColors.error : AppColors.grey800,
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

  void _showLogoutDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(FlutterI18n.translate(context, 'profile.logout_confirm_title')),
        content: Text(FlutterI18n.translate(context, 'profile.logout_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterI18n.translate(context, 'common.cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await viewModel.logout();
              if (success && context.mounted) {
                context.go(RouteName.login);
              }
            },
            child: Text(FlutterI18n.translate(context, 'common.confirm')),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(FlutterI18n.translate(context, 'profile.delete_account_confirm_title')),
        content: Text(FlutterI18n.translate(context, 'profile.delete_account_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterI18n.translate(context, 'common.cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await viewModel.deleteAccount();
              if (success && context.mounted) {
                context.go(RouteName.login);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(FlutterI18n.translate(context, 'common.confirm')),
          ),
        ],
      ),
    );
  }
}
