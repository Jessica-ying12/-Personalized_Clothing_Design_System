import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_state.dart';

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  void switchTab(int index) {
    if (index == state.selectedIndex) return;
    state = state.copyWith(selectedIndex: index);
  }

  void toggleSidebar() {
    state = state.copyWith(isSidebarOpen: !state.isSidebarOpen);
  }

  void closeSidebar() {
    state = state.copyWith(isSidebarOpen: false);
  }
}

final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
