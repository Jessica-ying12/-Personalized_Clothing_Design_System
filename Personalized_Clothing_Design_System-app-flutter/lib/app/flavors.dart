import 'env.dart';

enum Flavor {
  dev,
  preview,
  prod,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return EnvDev.appName;
      case Flavor.preview:
        return EnvPreview.appName;
      case Flavor.prod:
        return EnvProd.appName;
    }
  }

  static String get apiBaseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return EnvDev.apiBaseUrl;
      case Flavor.preview:
        return EnvPreview.apiBaseUrl;
      case Flavor.prod:
        return EnvProd.apiBaseUrl;
    }
  }

  static bool get enableLog {
    switch (appFlavor) {
      case Flavor.dev:
        return EnvDev.enableLog;
      case Flavor.preview:
        return EnvPreview.enableLog;
      case Flavor.prod:
        return EnvProd.enableLog;
    }
  }

  static String get supabaseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return EnvDev.supabaseUrl;
      case Flavor.preview:
        return EnvPreview.supabaseUrl;
      case Flavor.prod:
        return EnvProd.supabaseUrl;
    }
  }

  static String get supabaseAnonKey {
    switch (appFlavor) {
      case Flavor.dev:
        return EnvDev.supabaseAnonKey;
      case Flavor.preview:
        return EnvPreview.supabaseAnonKey;
      case Flavor.prod:
        return EnvProd.supabaseAnonKey;
    }
  }

  /// Replicate API Token（虚拟试穿功能）
  static const String replicateApiToken = 'r8_13DWl9wpY25rtVqQ89HZClvfa2EgKbF2xJLjs';
}
