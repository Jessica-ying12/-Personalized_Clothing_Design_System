import '../../app/flavors.dart';

abstract class AppConfig {
  static String get apiBaseUrl => '${F.apiBaseUrl}/functions/v1';

  // API 端点
  static const String authApi = '/auth-api';
  static const String profileApi = '/profile-api';
  static const String designOptionsApi = '/design-options-api';
  static const String flatDesignApi = '/flat-design-api';
  static const String design3dApi = '/design-3d-api';
  static const String storageApi = '/storage-api';
}
