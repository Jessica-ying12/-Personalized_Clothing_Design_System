import '../../app/flavors.dart';

abstract class AppConfig {
  // 后端 API 基础地址（FastAPI 本地服务）
  static String get apiBaseUrl => F.apiBaseUrl;

  // API 端点（对应后端 module_pcds 路由）
  static const String authApi = '/api/auth';
  static const String profileApi = '/api/profile';
  static const String designOptionsApi = '/api/design-options';
  static const String flatDesignApi = '/api/flat-design';
  static const String design3dApi = '/api/3d-design';
  static const String chatApi = '/api/chat';
}
