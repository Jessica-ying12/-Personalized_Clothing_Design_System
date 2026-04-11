import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'profile_edit_view_model.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({
    super.key,
    this.fullName,
    this.avatarUrl,
  });

  final String? fullName;
  final String? avatarUrl;

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _fullNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(profileEditViewModelProvider.notifier);
      viewModel.initialize(widget.fullName, widget.avatarUrl);
      
      _fullNameController.text = widget.fullName ?? '';
      _avatarUrlController.text = widget.avatarUrl ?? '';
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileEditViewModelProvider);
    final viewModel = ref.read(profileEditViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'profile_edit.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 头像预览
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.grey200,
                    backgroundImage: state.avatarUrl != null && state.avatarUrl!.isNotEmpty
                        ? NetworkImage(state.avatarUrl!)
                        : null,
                    child: state.avatarUrl == null || state.avatarUrl!.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.grey400,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () {
                          // TODO: 实现图片选择功能
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 昵称输入
            Text(
              FlutterI18n.translate(context, 'profile_edit.full_name'),
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, 'profile_edit.full_name_hint'),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: viewModel.setFullName,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 头像 URL 输入
            Text(
              FlutterI18n.translate(context, 'profile_edit.avatar_url'),
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _avatarUrlController,
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, 'profile_edit.avatar_url_hint'),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: viewModel.setAvatarUrl,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              FlutterI18n.translate(context, 'profile_edit.avatar_url_note'),
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.grey500,
              ),
            ),

            if (state.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  state.errorMessage!,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // 保存按钮
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final success = await viewModel.updateProfile();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              FlutterI18n.translate(context, 'profile_edit.update_success'),
                            ),
                          ),
                        );
                        context.pop(true); // 返回 true 表示更新成功
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(FlutterI18n.translate(context, 'common.save')),
            ),
          ],
        ),
      ),
    );
  }
}
