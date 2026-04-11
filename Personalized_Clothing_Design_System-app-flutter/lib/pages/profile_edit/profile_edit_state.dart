class ProfileEditState {
  const ProfileEditState({
    this.fullName = '',
    this.avatarUrl,
    this.isLoading = false,
    this.errorMessage,
  });

  final String fullName;
  final String? avatarUrl;
  final bool isLoading;
  final String? errorMessage;

  ProfileEditState copyWith({
    String? fullName,
    String? avatarUrl,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileEditState(
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
