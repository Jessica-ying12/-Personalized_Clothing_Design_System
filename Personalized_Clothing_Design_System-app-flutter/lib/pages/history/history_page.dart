import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/utils/download_helper.dart';
import '../../shared/widgets/feedback/empty_state.dart';
import '../gallery/gallery_state.dart';
import 'history_state.dart';
import 'history_view_model.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyViewModelProvider);
    final viewModel = ref.read(historyViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'history.title')),
      ),
      body: Column(
        children: [
          _buildTabBar(context, state, viewModel),
          Expanded(
            child: state.isLoading && state.currentPage == 1
                ? const Center(child: CircularProgressIndicator())
                : state.currentList.isEmpty
                    ? EmptyState(
                        icon: Icons.history,
                        message: FlutterI18n.translate(context, 'history.empty'),
                      )
                    : RefreshIndicator(
                        onRefresh: () => viewModel.refresh(),
                        child: _buildHistoryList(context, state, viewModel),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    HistoryState state,
    HistoryViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _buildTabButton(
            context,
            'history.all_tab',
            state.selectedTab == HistoryTab.all,
            () => viewModel.setTab(HistoryTab.all),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildTabButton(
            context,
            'history.flat_tab',
            state.selectedTab == HistoryTab.flat,
            () => viewModel.setTab(HistoryTab.flat),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildTabButton(
            context,
            'history.3d_tab',
            state.selectedTab == HistoryTab.design3d,
            () => viewModel.setTab(HistoryTab.design3d),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String labelKey,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Center(
            child: Text(
              FlutterI18n.translate(context, labelKey),
              style: AppTextStyles.bodyMd.copyWith(
                color: isSelected ? AppColors.surface : AppColors.grey600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    HistoryState state,
    HistoryViewModel viewModel,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            !state.isLoading &&
            state.hasMore) {
          viewModel.loadHistory(loadMore: true);
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.75,
        ),
        itemCount: state.currentList.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.currentList.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final item = state.currentList[index];
          return _buildHistoryItem(context, item, viewModel);
        },
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    DesignItem item,
    HistoryViewModel viewModel,
  ) {
    return InkWell(
      onTap: () => _showItemDialog(context, item, viewModel),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMd),
                ),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.grey200,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.type == DesignType.flat
                        ? FlutterI18n.translate(context, 'history.flat_design')
                        : FlutterI18n.translate(context, 'history.3d_design'),
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.grey800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDate(item.createdAt),
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDialog(
    BuildContext context,
    DesignItem item,
    HistoryViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 右上角下载按钮
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: IconButton(
                  onPressed: () async {
                    try {
                      final fileName =
                          'design_${item.id}_${DateTime.now().millisecondsSinceEpoch}.png';
                      final path = await DownloadHelper.downloadImage(
                          context, item.imageUrl, fileName);
                      if (path != null && context.mounted) {
                        DownloadHelper.showDownloadSuccess(context, path);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        DownloadHelper.showDownloadError(context, e.toString());
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
            Image.network(
              item.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: AppColors.grey200,
                  child: const Icon(Icons.image_not_supported, size: 48),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await viewModel.saveToGallery(item.id, item.type);
                    },
                    icon: const Icon(Icons.save),
                    label: Text(
                      FlutterI18n.translate(context, 'history.save_to_gallery'),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showDeleteDialog(context, item, viewModel);
                    },
                    icon: const Icon(Icons.delete),
                    label: Text(
                      FlutterI18n.translate(context, 'common.delete'),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    DesignItem item,
    HistoryViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(FlutterI18n.translate(context, 'history.delete_confirm_title')),
        content: Text(FlutterI18n.translate(context, 'history.delete_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterI18n.translate(context, 'common.cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await viewModel.deleteDesign(item.id, item.type);
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
