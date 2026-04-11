import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/design_3d_model.dart';
import '../../core/models/flat_design_model.dart';
import '../../core/providers/service_providers.dart';
import '../gallery/gallery_state.dart';
import 'history_state.dart';

class HistoryViewModel extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    loadHistory();
    return const HistoryState();
  }

  void setTab(HistoryTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  Future<void> loadHistory({bool loadMore = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final flatService = ref.read(flatDesignServiceProvider);
      final design3dService = ref.read(design3dServiceProvider);

      final page = loadMore ? state.currentPage + 1 : 1;

      final flatResult = await flatService.getHistory(page: page, pageSize: 20);
      final design3dResult = await design3dService.getHistory(page: page, pageSize: 20);

      final flatDesigns = (flatResult['data'] as List<FlatDesignModel>)
          .map((e) => DesignItem(
                id: e.id,
                imageUrl: e.imageUrl ?? '',
                createdAt: e.createdAt ?? DateTime.now(),
                type: DesignType.flat,
              ))
          .toList();

      final design3ds = (design3dResult['data'] as List<Design3dModel>)
          .map((e) => DesignItem(
                id: e.id,
                imageUrl: e.imageUrl ?? '',
                createdAt: e.createdAt ?? DateTime.now(),
                type: DesignType.design3d,
              ))
          .toList();

      if (loadMore) {
        state = state.copyWith(
          isLoading: false,
          flatDesigns: [...state.flatDesigns, ...flatDesigns],
          design3ds: [...state.design3ds, ...design3ds],
          currentPage: page,
          hasMore: flatDesigns.isNotEmpty || design3ds.isNotEmpty,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          flatDesigns: flatDesigns,
          design3ds: design3ds,
          currentPage: page,
          hasMore: flatDesigns.isNotEmpty || design3ds.isNotEmpty,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> saveToGallery(String id, DesignType type) async {
    try {
      if (type == DesignType.flat) {
        final service = ref.read(flatDesignServiceProvider);
        await service.save(id);
      } else {
        final service = ref.read(design3dServiceProvider);
        await service.save(id);
      }
      // 重新加载列表
      await loadHistory();
    } catch (e) {
      // 显示错误
    }
  }

  Future<void> deleteDesign(String id, DesignType type) async {
    try {
      if (type == DesignType.flat) {
        final service = ref.read(flatDesignServiceProvider);
        await service.remove(id);
      } else {
        final service = ref.read(design3dServiceProvider);
        await service.remove(id);
      }
      // 重新加载列表
      await loadHistory();
    } catch (e) {
      // 显示错误
    }
  }

  /// 刷新历史记录（下拉刷新使用）
  Future<void> refresh() async {
    await loadHistory(loadMore: false);
  }
}

final historyViewModelProvider =
    NotifierProvider<HistoryViewModel, HistoryState>(HistoryViewModel.new);
