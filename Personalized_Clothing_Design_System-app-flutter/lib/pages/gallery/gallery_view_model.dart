import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/design_3d_model.dart';
import '../../core/models/flat_design_model.dart';
import '../../core/providers/service_providers.dart';
import 'gallery_state.dart';

class GalleryViewModel extends Notifier<GalleryState> {
  @override
  GalleryState build() {
    loadDesigns();
    return const GalleryState();
  }

  void setTab(GalleryTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  Future<void> loadDesigns() async {
    state = state.copyWith(isLoading: true);

    try {
      final flatService = ref.read(flatDesignServiceProvider);
      final design3dService = ref.read(design3dServiceProvider);

      final flatResult = await flatService.getList(page: 1, pageSize: 50);
      final design3dResult = await design3dService.getList(page: 1, pageSize: 50);

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

      state = state.copyWith(
        isLoading: false,
        flatDesigns: flatDesigns,
        design3ds: design3ds,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String?> downloadDesign(String id, DesignType type) async {
    try {
      String? imageUrl;
      
      if (type == DesignType.flat) {
        final service = ref.read(flatDesignServiceProvider);
        final design = await service.getDetail(id);
        imageUrl = design.imageUrl;
      } else {
        final service = ref.read(design3dServiceProvider);
        final design = await service.getDetail(id);
        imageUrl = design.imageUrl;
      }
      
      return imageUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> regenerateDesign(String id, DesignType type) async {
    try {
      if (type == DesignType.flat) {
        final service = ref.read(flatDesignServiceProvider);
        await service.regenerate(id);
      } else {
        final service = ref.read(design3dServiceProvider);
        await service.regenerate(id);
      }
      // 重新加载列表
      await loadDesigns();
    } catch (e) {
      // 显示错误
    }
  }

  Future<void> generate3dFromFlat(String flatDesignId) async {
    // 导航�?3D 生成页面，传�?flatDesignId
    // 这个方法会在 gallery_page.dart 中调用，使用 context.push
  }

  Future<void> removeDesign(String id, DesignType type) async {
    try {
      if (type == DesignType.flat) {
        final service = ref.read(flatDesignServiceProvider);
        await service.remove(id);
      } else {
        final service = ref.read(design3dServiceProvider);
        await service.remove(id);
      }
      // 重新加载列表
      await loadDesigns();
    } catch (e) {
      // 显示错误
    }
  }
}

final galleryViewModelProvider =
    NotifierProvider<GalleryViewModel, GalleryState>(GalleryViewModel.new);
