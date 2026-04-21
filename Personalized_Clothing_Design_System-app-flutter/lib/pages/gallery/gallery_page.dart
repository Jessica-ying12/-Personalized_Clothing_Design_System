import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/utils/download_helper.dart';
import 'gallery_state.dart';
import 'gallery_view_model.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(galleryViewModelProvider);
    final viewModel = ref.read(galleryViewModelProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'gallery.title')),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            onTap: (index) {
              viewModel.setTab(
                index == 0 ? GalleryTab.flat : GalleryTab.design3d,
              );
            },
            tabs: [
              Tab(text: FlutterI18n.translate(context, 'gallery.flat_tab')),
              Tab(text: FlutterI18n.translate(context, 'gallery.3d_tab')),
            ],
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => viewModel.loadDesigns(),
                child: _buildGalleryGrid(context, state, viewModel),
              ),
      ),
    );
  }

  Widget _buildGalleryGrid(
    BuildContext context,
    GalleryState state,
    GalleryViewModel viewModel,
  ) {
    final items = state.selectedTab == GalleryTab.flat
        ? state.flatDesigns
        : state.design3ds;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: AppColors.grey300,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              FlutterI18n.translate(context, 'gallery.empty'),
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.grey400,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGalleryItem(context, item, state, viewModel);
      },
    );
  }

  Widget _buildGalleryItem(
    BuildContext context,
    DesignItem item,
    GalleryState state,
    GalleryViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => _showDetailDialog(context, item, state, viewModel),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.grey100,
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.grey300,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                _formatDate(item.createdAt),
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(
    BuildContext context,
    DesignItem item,
    GalleryState state,
    GalleryViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: Column(
            children: [
              // 右上角下载按钮
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: IconButton(
                    onPressed: () async {
                      final imageUrl = await viewModel.downloadDesign(item.id, item.type);
                      if (imageUrl != null && context.mounted) {
                        try {
                          final fileName =
                              'design_${item.id}_${DateTime.now().millisecondsSinceEpoch}.png';
                          final path = await DownloadHelper.downloadImage(context, imageUrl, fileName);
                          if (path != null && context.mounted) {
                            DownloadHelper.showDownloadSuccess(context, path);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            DownloadHelper.showDownloadError(context, e.toString());
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.download),
                    tooltip: FlutterI18n.translate(context, 'gallery.download'),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.grey100,
                    child: Icon(Icons.image_not_supported, size: 80, color: AppColors.grey300),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        viewModel.regenerateDesign(item.id, item.type);
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: FlutterI18n.translate(context, 'gallery.regenerate'),
                    ),
                    if (item.type == DesignType.flat)
                      IconButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final imageUrl = await viewModel.downloadDesign(item.id, item.type);
                          if (context.mounted) {
                            context.push(RouteName.design3d, extra: {
                              'flatDesignId': item.id,
                              'flatImageUrl': imageUrl,
                            });
                          }
                        },
                        icon: const Icon(Icons.view_in_ar),
                        tooltip: FlutterI18n.translate(context, 'gallery.generate_3d'),
                      ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showDeleteConfirmDialog(context, item, viewModel);
                      },
                      icon: const Icon(Icons.delete),
                      tooltip: FlutterI18n.translate(context, 'common.delete'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    DesignItem item,
    GalleryViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(FlutterI18n.translate(context, 'gallery.delete_confirm_title')),
        content: Text(FlutterI18n.translate(context, 'gallery.delete_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterI18n.translate(context, 'common.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.removeDesign(item.id, item.type);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(FlutterI18n.translate(context, 'common.delete')),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
