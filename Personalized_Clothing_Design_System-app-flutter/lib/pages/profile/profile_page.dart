import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme.dart';
import '../../i18n/i18n.dart';
import 'profile_view_model.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          S.of(context, 'nav.profile'),
          style: AppTextStyles.titleLg.copyWith(color: AppColors.grey400),
        ),
      ),
    );
  }
}
