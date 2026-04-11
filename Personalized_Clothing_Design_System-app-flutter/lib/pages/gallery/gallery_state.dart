class GalleryState {
  const GalleryState({
    this.flatDesigns = const [],
    this.design3ds = const [],
    this.isLoading = false,
    this.selectedTab = GalleryTab.flat,
  });

  final List<DesignItem> flatDesigns;
  final List<DesignItem> design3ds;
  final bool isLoading;
  final GalleryTab selectedTab;

  GalleryState copyWith({
    List<DesignItem>? flatDesigns,
    List<DesignItem>? design3ds,
    bool? isLoading,
    GalleryTab? selectedTab,
  }) {
    return GalleryState(
      flatDesigns: flatDesigns ?? this.flatDesigns,
      design3ds: design3ds ?? this.design3ds,
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

enum GalleryTab {
  flat,
  design3d,
}

enum DesignType {
  flat,
  design3d,
}

class DesignItem {
  const DesignItem({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
    required this.type,
  });

  final String id;
  final String imageUrl;
  final DateTime createdAt;
  final DesignType type;
}
