import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:livhome/app/theme/theme.dart';
import 'package:livhome/shared/widgets/buttons/app_button.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  final String title;
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  /// 快捷调用方法，返回用户是否点击了确认
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.scrim,
      builder: (_) => AppDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedConfirmText =
        confirmText ?? FlutterI18n.translate(context, 'common.confirm');
    final resolvedCancelText =
        cancelText ?? FlutterI18n.translate(context, 'common.cancel');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.titleLg,
              textAlign: TextAlign.center,
            ),
            if (content != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                content!,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      onCancel?.call();
                      Navigator.of(context).pop(false);
                    },
                    backgroundColor: AppColors.grey100,
                    foregroundColor: AppColors.grey700,
                    borderRadius: AppSpacing.radiusMd,
                    height: 44,
                    child: Text(resolvedCancelText),
                  ),
                ),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      onConfirm?.call();
                      Navigator.of(context).pop(true);
                    },
                    backgroundColor:
                        isDestructive ? AppColors.error : null,
                    borderRadius: AppSpacing.radiusMd,
                    height: 44,
                    child: Text(resolvedConfirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
