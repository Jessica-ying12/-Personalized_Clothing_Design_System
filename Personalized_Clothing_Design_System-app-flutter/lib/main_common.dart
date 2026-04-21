import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/flavors.dart';
import 'core/storage/storage.dart';
import 'logger/logger.dart';

Future<void> mainCommon(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = flavor;
  Log.init();

  await Hive.initFlutter();
  final appBox = await Hive.openBox(BoxKeys.app);
  final designsBox = await Hive.openBox(BoxKeys.designs);

  // 清除旧版本的预置数据（版本号变更时自动清空）
  const _dataVersion = 'v3_real_backend';
  final storedVersion = appBox.get('data_version') as String?;
  if (storedVersion != _dataVersion) {
    await designsBox.clear();
    await appBox.put('data_version', _dataVersion);
  }

  // 注意：已切换到自建 FastAPI 后端，不再使用 Supabase
  // 认证通过 JWT Token 存储在 FlutterSecureStorage 中

  runApp(ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(StorageService(appBox)),
      designsStorageProvider.overrideWithValue(StorageService(designsBox)),
    ],
    child: const App(),
  ));
}
