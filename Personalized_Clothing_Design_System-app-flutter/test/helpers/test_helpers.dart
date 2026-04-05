import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livhome/app/flavors.dart';
import 'package:livhome/logger/logger.dart';

bool _envInitialized = false;

/// 初始化测试环境（Flavor + Logger），幂等调用。
void initTestEnv() {
  if (_envInitialized) return;
  F.appFlavor = Flavor.dev;
  Log.init();
  _envInitialized = true;
}

ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(overrides: overrides);
}
