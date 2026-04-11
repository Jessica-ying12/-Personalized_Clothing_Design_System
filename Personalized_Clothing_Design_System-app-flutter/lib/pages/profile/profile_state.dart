class ProfileState {
  const ProfileState({
    this.avatarUrl,
    this.nickname,
    this.email,
    this.isLoading = false,
    this.stats,
  });

  final String? avatarUrl;
  final String? nickname;
  final String? email;
  final bool isLoading;
  // { flat_total, flat_saved, design_3d_total, design_3d_saved }
  final Map<String, dynamic>? stats;

  ProfileState copyWith({
    String? avatarUrl,
    String? nickname,
    String? email,
    bool? isLoading,
    Map<String, dynamic>? stats,
  }) {
    return ProfileState(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
    );
  }
}
