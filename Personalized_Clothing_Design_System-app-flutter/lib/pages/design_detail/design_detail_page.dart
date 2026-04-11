import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/utils/download_helper.dart';
import '../gallery/gallery_state.dart';

/// 设计详情�?- 查看设计的详细信息和大图
class DesignDetailPage extends ConsumerWidget {
  const DesignDetailPage({
    super.key,
    required this.designItem,
  });

  final DesignItem designItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          designItem.type == DesignType.flat
              ? FlutterI18n.translate(context, 'design_detail.flat_design')
              : FlutterI18n.translate(context, 'design_detail.3d_design'),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadImage(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareImage(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 图片展示区域
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  designItem.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 80,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          FlutterI18n.translate(context, 'design_detail.load_failed'),
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // 信息�?
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      designItem.type == DesignType.flat
                          ? Icons.image
                          : Icons.view_in_ar,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        designItem.type == DesignType.flat
                            ? FlutterI18n.translate(context, 'design_detail.flat_design')
                            : FlutterI18n.translate(context, 'design_detail.3d_design'),
                        style: AppTextStyles.titleMd.copyWith(
                          color: AppColors.grey800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatDate(designItem.createdAt),
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  FlutterI18n.translate(context, 'design_detail.pinch_to_zoom'),
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadImage(BuildContext context) async {
    try {
      final fileName = 'design_${designItem.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = await DownloadHelper.downloadImage(
        context,
        designItem.imageUrl,
        fileName,
      );
      
      if (path != null && context.mounted) {
        DownloadHelper.showDownloadSuccess(context, path);
      }
    } catch (e) {
      if (context.mounted) {
        DownloadHelper.showDownloadError(context, e.toString());
      }
    }
  }

  void _shareImage(BuildContext context) {
    // TODO: 实现图片分享功能
    // 可以使用 share_plus �?
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          FlutterI18n.translate(context, 'design_detail.share_coming_soon'),
        ),
      ),
    );
  }
}
