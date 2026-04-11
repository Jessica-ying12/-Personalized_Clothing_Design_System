class ProfileState {
  const ProfileState({
    this.avatarUrl,
    this.nickname,
    this.email,
    this.isLoading = false,
  });

  final String? avatarUrl;
  final String? nickname;
  final String? email;
  final bool isLoading;

  ProfileState copyWith({
    String? avatarUrl,
    String? nickname,
    String? email,
    bool? isLoading,
  }) {
    return ProfileState(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
