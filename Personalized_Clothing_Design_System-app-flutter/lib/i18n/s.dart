import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class S {
  S._();

  static String of(BuildContext context, String key, {Map<String, String>? args}) {
    return FlutterI18n.translate(context, key, translationParams: args);
  }

  static String plural(BuildContext context, String key, int value) {
    return FlutterI18n.plural(context, key, value);
  }

  static Future<void> switchLocale(BuildContext context, Locale locale) {
    return FlutterI18n.refresh(context, locale);
  }

  static Locale? currentLocale(BuildContext context) {
    return FlutterI18n.currentLocale(context);
  }
}
