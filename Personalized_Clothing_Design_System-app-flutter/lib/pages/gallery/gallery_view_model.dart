import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/design_3d_model.dart';
import '../../core/models/flat_design_model.dart';
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
          .cast<FlatDesignModel>()
          .where((e) => e.imageUrl != null && e.imageUrl!.isNotEmpty)
          .map((e) => DesignItem(
                id: e.id,
                imageUrl: e.imageUrl!,
                createdAt: e.createdAt ?? DateTime.now(),
                type: DesignType.flat,
              ))
          .toList();

      final design3dItems = (design3dResult['data'] as List)
          .cast<Design3dModel>()
          .where((e) => e.imageUrl != null && e.imageUrl!.isNotEmpty)
          .map((e) => DesignItem(
                id: e.id,
                imageUrl: e.imageUrl!,
                createdAt: e.createdAt ?? DateTime.now(),
                type: DesignType.design3d,
              ))
          .toList();

      state = state.copyWith(
        flatDesigns: flatItems..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        design3ds: design3dItems..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
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
