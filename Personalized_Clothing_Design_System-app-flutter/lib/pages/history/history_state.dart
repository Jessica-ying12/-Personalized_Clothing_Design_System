import '../gallery/gallery_state.dart';

class HistoryState {
  const HistoryState({
    this.flatDesigns = const [],
    this.design3ds = const [],
    this.isLoading = false,
    this.selectedTab = HistoryTab.all,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final List<DesignItem> flatDesigns;
  final List<DesignItem> design3ds;
  final bool isLoading;
  final HistoryTab selectedTab;
  final int currentPage;
  final bool hasMore;

  List<DesignItem> get allDesigns {
    final all = [...flatDesigns, ...design3ds];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  List<DesignItem> get currentList {
    switch (selectedTab) {
      case HistoryTab.all:
        return allDesigns;
      case HistoryTab.flat:
        return flatDesigns;
      case HistoryTab.design3d:
        return design3ds;
    }
  }

  HistoryState copyWith({
    List<DesignItem>? flatDesigns,
    List<DesignItem>? design3ds,
    bool? isLoading,
    HistoryTab? selectedTab,
    int? currentPage,
    bool? hasMore,
  }) {
    return HistoryState(
      flatDesigns: flatDesigns ?? this.flatDesigns,
      design3ds: design3ds ?? this.design3ds,
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

enum HistoryTab {
  all,
  flat,
  design3d,
}
