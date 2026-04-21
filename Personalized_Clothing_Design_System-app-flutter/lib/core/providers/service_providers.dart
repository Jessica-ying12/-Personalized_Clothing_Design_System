import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/design_3d_service.dart';
import '../services/design_options_service.dart';
import '../services/flat_design_service.dart';
import '../services/profile_service.dart';

// ── Mock 模式开关 ─────────────────────────────────────────────────
// 已切换到真实后端，mock 模式关闭
const bool kUseMock = false;

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// ── 真实服务 Provider ─────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.read(apiClientProvider)),
);

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.read(apiClientProvider)),
);

final designOptionsServiceProvider = Provider<DesignOptionsService>(
  (ref) => DesignOptionsService(ref.read(apiClientProvider)),
);

final flatDesignServiceProvider = Provider<FlatDesignService>(
  (ref) => FlatDesignService(ref.read(apiClientProvider)),
);

final design3dServiceProvider = Provider<Design3dService>(
  (ref) => Design3dService(ref.read(apiClientProvider)),
);

final chatServiceProvider = Provider<ChatService>(
  (ref) => ChatService(ref.read(apiClientProvider)),
);
