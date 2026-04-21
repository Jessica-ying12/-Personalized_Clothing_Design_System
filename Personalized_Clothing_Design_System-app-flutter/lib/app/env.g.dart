// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env.dev
final class _EnvDev {
  static const String appName = 'PCDS Dev';

  // Android 模拟器访问宿主机用 10.0.2.2
  // 真机调试用局域网 IP：192.168.1.5
  static const String apiBaseUrl = 'http://192.168.1.5:9099';

  static const bool enableLog = true;

  static const String supabaseUrl = 'https://placeholder.supabase.co';

  static const String supabaseAnonKey = 'placeholder_anon_key';
}

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env.preview
final class _EnvPreview {
  static const String appName = 'PCDS Preview';

  // 真机调试时改为：http://192.168.1.5:9099/dev-api
  static const String apiBaseUrl = 'http://10.0.2.2:9099';

  static const bool enableLog = true;

  static const String supabaseUrl = 'https://placeholder.supabase.co';

  static const String supabaseAnonKey = 'placeholder_anon_key';
}

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env.prod
final class _EnvProd {
  static const String appName = 'PCDS';

  static const String apiBaseUrl = 'http://10.0.2.2:9099';

  static const bool enableLog = false;

  static const String supabaseUrl = 'https://placeholder.supabase.co';

  static const String supabaseAnonKey = 'placeholder_anon_key';
}
