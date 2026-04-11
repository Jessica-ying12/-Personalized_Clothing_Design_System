import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  const SettingsState({
    this.currentLanguage = 'zh_CN',
    this.notificationsEnabled = true,
    this.appVersion = '1.0.0',
  });

  final String currentLanguage;
  final bool notificationsEnabled;
  final String appVersion;

  SettingsState copyWith({
    String? currentLanguage,
    bool? notificationsEnabled,
    String? appVersion,
  }) {
    return SettingsState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void changeLanguage(String languageCode) {
    state = state.copyWith(currentLanguage: languageCode);
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  Future<void> clearCache() async {
    // 清理缓存逻辑
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);
