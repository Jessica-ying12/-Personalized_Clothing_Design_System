import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main_state.dart';

class MainViewModel extends Notifier<MainState> {
  @override
  MainState build() => const MainState();

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

final mainViewModelProvider =
    NotifierProvider<MainViewModel, MainState>(MainViewModel.new);
