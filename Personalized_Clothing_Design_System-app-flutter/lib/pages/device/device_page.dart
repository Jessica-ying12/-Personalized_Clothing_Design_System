import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme.dart';
import '../../i18n/i18n.dart';
import 'device_view_model.dart';

class DevicePage extends ConsumerStatefulWidget {
  const DevicePage({super.key});

  @override
  ConsumerState<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends ConsumerState<DevicePage> {
  @override
  Widget build(BuildContext context) {
    ref.watch(deviceViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          S.of(context, 'nav.device'),
          style: AppTextStyles.titleLg.copyWith(color: AppColors.grey400),
        ),
      ),
    );
  }
}
