class HomeState {
  const HomeState({
    this.isSidebarOpen = false,
    this.selectedIndex = 1,
  });

  final bool isSidebarOpen;
  final int selectedIndex;

  HomeState copyWith({bool? isSidebarOpen, int? selectedIndex}) {
    return HomeState(
      isSidebarOpen: isSidebarOpen ?? this.isSidebarOpen,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
