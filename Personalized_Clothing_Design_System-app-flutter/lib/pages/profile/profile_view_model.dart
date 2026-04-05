import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_state.dart';

class ProfileViewModel extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();
}

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);
