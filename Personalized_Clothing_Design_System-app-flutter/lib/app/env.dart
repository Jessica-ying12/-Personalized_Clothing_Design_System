import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class EnvDev {
  @EnviedField(varName: 'APP_NAME')
  static const String appName = _EnvDev.appName;
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _EnvDev.apiBaseUrl;
  @EnviedField(varName: 'ENABLE_LOG')
  static const bool enableLog = _EnvDev.enableLog;
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _EnvDev.supabaseUrl;
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static const String supabaseAnonKey = _EnvDev.supabaseAnonKey;
}

@Envied(path: '.env.preview')
abstract class EnvPreview {
  @EnviedField(varName: 'APP_NAME')
  static const String appName = _EnvPreview.appName;
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _EnvPreview.apiBaseUrl;
  @EnviedField(varName: 'ENABLE_LOG')
  static const bool enableLog = _EnvPreview.enableLog;
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _EnvPreview.supabaseUrl;
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static const String supabaseAnonKey = _EnvPreview.supabaseAnonKey;
}

@Envied(path: '.env.prod')
abstract class EnvProd {
  @EnviedField(varName: 'APP_NAME')
  static const String appName = _EnvProd.appName;
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _EnvProd.apiBaseUrl;
  @EnviedField(varName: 'ENABLE_LOG')
  static const bool enableLog = _EnvProd.enableLog;
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _EnvProd.supabaseUrl;
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static const String supabaseAnonKey = _EnvProd.supabaseAnonKey;
}
