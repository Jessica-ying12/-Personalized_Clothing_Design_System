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
  });

  final String email;
  final String password;
  final String otpCode;
  final bool isLoading;
  final LoginMode loginMode;
  final OtpStep otpStep;
  final String? errorMessage;

  bool get isPasswordMode => loginMode == LoginMode.password;
  bool get isOtpMode => loginMode == LoginMode.otp;
  bool get isOtpInputStep => otpStep == OtpStep.inputCode;

  LoginState copyWith({
    String? email,
    String? password,
    String? otpCode,
    bool? isLoading,
    LoginMode? loginMode,
    OtpStep? otpStep,
    String? errorMessage,
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
    );
  }
}
