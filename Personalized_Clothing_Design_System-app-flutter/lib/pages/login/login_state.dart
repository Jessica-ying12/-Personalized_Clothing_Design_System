enum LoginMode { password, otp }

enum OtpStep { inputEmail, inputCode }

class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.otpCode = '',
    this.isLoading = false,
    this.loginMode = LoginMode.password,
    this.otpStep = OtpStep.inputEmail,
    this.errorMessage,
    this.errorMessageKey,
  });

  final String email;
  final String password;
  final String otpCode;
  final bool isLoading;
  final LoginMode loginMode;
  final OtpStep otpStep;

  /// 直接显示的错误文本（来自服务端，已是用户语言）
  final String? errorMessage;

  /// i18n key，由 _ErrorText 负责翻译后显示
  final String? errorMessageKey;

  bool get isPasswordMode => loginMode == LoginMode.password;
  bool get isOtpMode => loginMode == LoginMode.otp;
  bool get isOtpInputStep => otpStep == OtpStep.inputCode;
  bool get hasError => errorMessage != null || errorMessageKey != null;

  LoginState copyWith({
    String? email,
    String? password,
    String? otpCode,
    bool? isLoading,
    LoginMode? loginMode,
    OtpStep? otpStep,
    String? errorMessage,
    String? errorMessageKey,
    bool clearError = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      otpCode: otpCode ?? this.otpCode,
      isLoading: isLoading ?? this.isLoading,
      loginMode: loginMode ?? this.loginMode,
      otpStep: otpStep ?? this.otpStep,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorMessageKey: clearError ? null : (errorMessageKey ?? this.errorMessageKey),
    );
  }
}
