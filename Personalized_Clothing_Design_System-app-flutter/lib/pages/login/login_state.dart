class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.isLoginMode = true,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool isLoading;
  final bool isLoginMode;
  final String? errorMessage;

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? isLoginMode,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isLoginMode: isLoginMode ?? this.isLoginMode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
