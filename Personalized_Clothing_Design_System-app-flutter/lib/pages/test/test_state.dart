import '../../core/network/api/website/model/app_setting.dart';

class TestState {
  const TestState({
    this.appSetting,
    this.isLoading = false,
    this.error,
    this.userId,
    this.userEmail,
    this.isAuthLoading = false,
    this.authError,
    this.isSignUpMode = false,
    this.isOtpSent = false,
  });

  final AppSetting? appSetting;
  final bool isLoading;
  final String? error;

  final String? userId;
  final String? userEmail;
  final bool isAuthLoading;
  final String? authError;
  final bool isSignUpMode;
  final bool isOtpSent;

  bool get isSignedIn => userId != null;

  TestState copyWith({
    AppSetting? appSetting,
    bool? isLoading,
    String? error,
    bool clearAppSetting = false,
    bool clearError = false,
    String? userId,
    String? userEmail,
    bool? isAuthLoading,
    String? authError,
    bool clearUser = false,
    bool clearAuthError = false,
    bool? isSignUpMode,
    bool? isOtpSent,
  }) {
    return TestState(
      appSetting: clearAppSetting ? null : (appSetting ?? this.appSetting),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      userId: clearUser ? null : (userId ?? this.userId),
      userEmail: clearUser ? null : (userEmail ?? this.userEmail),
      isAuthLoading: isAuthLoading ?? this.isAuthLoading,
      authError: clearAuthError ? null : (authError ?? this.authError),
      isSignUpMode: isSignUpMode ?? this.isSignUpMode,
      isOtpSent: isOtpSent ?? this.isOtpSent,
    );
  }
}
