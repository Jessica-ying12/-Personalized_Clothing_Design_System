import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  await Supabase.initialize(
    url: F.supabaseUrl,
    anonKey: F.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  runApp(ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(StorageService(appBox)),
    ],
    child: const App(),
  ));
}
