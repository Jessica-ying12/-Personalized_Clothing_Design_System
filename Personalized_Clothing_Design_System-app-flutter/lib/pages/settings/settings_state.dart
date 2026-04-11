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
