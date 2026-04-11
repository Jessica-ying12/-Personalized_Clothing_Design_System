import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service_providers.dart';
import 'gallery_state.dart';

class GalleryViewModel extends Notifier<GalleryState> {
  @override
  GalleryState build() {
    Future.microtask(() => loadDesigns());
    return const GalleryState();
  }

  Future<void> loadDesigns() async {
    state = state.copyWith(isLoading: true);
    try {
      final flatService = ref.read(flatDesignServiceProvider);
      final design3dService = ref.read(design3dServiceProvider);

      final flatResult = await flatService.getList();
      final design3dResult = await design3dService.getList();

      final flatItems = (flatResult['data'] as List)
          .where((e) => e.imageUrl != null)
          .map((e) => DesignItem(
                id: e.id,
                imageUrl: e.imageUrl!,
                createdAt: e.createdAt ?? DateTime.now(),
                type: DesignType.flat,
              ))
          .toList();

      final design3dItems = (design3dResult['data'] as List)
          .where((e) => e.imageUrl != null)
          .map((e) => DesignItem(
                id: e.id,
                imageUrl: e.imageUrl!,
                createdAt: e.createdAt ?? DateTime.now(),
                type: DesignType.design3d,
              ))
          .toList();

      state = state.copyWith(
        flatDesigns: flatItems,
        design3ds: design3dItems,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setTab(GalleryTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  Future<String?> downloadDesign(String id, DesignType type) async {
    try {
      if (type == DesignType.flat) {
        final detail = await ref.read(flatDesignServiceProvider).getDetail(id);
        return detail.imageUrl;
      } else {
        final detail = await ref.read(design3dServiceProvider).getDetail(id);
        return detail.imageUrl;
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> regenerateDesign(String id, DesignType type) async {
    try {
      if (type == DesignType.flat) {
        await ref.read(flatDesignServiceProvider).regenerate(id);
      } else {
        await ref.read(design3dServiceProvider).regenerate(id);
      }
      await loadDesigns();
    } catch (_) {}
  }

  Future<void> removeDesign(String id, DesignType type) async {
    try {
      if (type == DesignType.flat) {
        await ref.read(flatDesignServiceProvider).remove(id);
      } else {
        await ref.read(design3dServiceProvider).remove(id);
      }
      await loadDesigns();
    } catch (_) {}
  }
}

final galleryViewModelProvider =
    NotifierProvider<GalleryViewModel, GalleryState>(GalleryViewModel.new);
