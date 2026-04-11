abstract class AppConfig {
  // TODO: 替换为实际的 Supabase 项目 URL
  static const String supabaseUrl = 'https://your-project-ref.supabase.co';
  static const String apiBaseUrl = '$supabaseUrl/functions/v1';
  
  // API 端点
  static const String authApi = '/auth-api';
  static const String profileApi = '/profile-api';
  static const String designOptionsApi = '/design-options-api';
  static const String flatDesignApi = '/flat-design-api';
  static const String design3dApi = '/design-3d-api';
  static const String storageApi = '/storage-api';
}
