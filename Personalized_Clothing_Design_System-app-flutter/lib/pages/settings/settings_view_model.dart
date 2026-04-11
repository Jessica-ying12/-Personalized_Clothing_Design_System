import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_state.dart';

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    // TODO: 从本地存储加载设�?
    // 可以使用 SharedPreferences �?Hive
  }

  Future<void> changeLanguage(String languageCode) async {
    state = state.copyWith(currentLanguage: languageCode);
    
    // TODO: 保存语言设置到本地存�?
    // TODO: 更新 FlutterI18n 的语言设置
    // 示例：await FlutterI18n.refresh(context, Locale(languageCode));
  }

  Future<void> toggleNotifications() async {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    
    // TODO: 保存通知设置到本地存�?
  }

  Future<void> clearCache() async {
    // TODO: 清除图片缓存
    // 可以使用 CachedNetworkImage �?clearCache 方法
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
