import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_state.dart';

class DeviceViewModel extends Notifier<DeviceState> {
  @override
  DeviceState build() => const DeviceState();
}

final deviceViewModelProvider =
    NotifierProvider<DeviceViewModel, DeviceState>(DeviceViewModel.new);
