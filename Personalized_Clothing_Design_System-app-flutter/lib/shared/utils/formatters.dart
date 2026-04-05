import 'package:flutter/foundation.dart';

class Formatters {
  Formatters._();

  static String date(DateTime dt, {String separator = '-'}) =>
      '${dt.year}$separator${_pad(dt.month)}$separator${_pad(dt.day)}';

  static String dateTime(DateTime dt, {String separator = '-'}) =>
      '${date(dt, separator: separator)} ${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';

  static String time(DateTime dt) =>
      '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';

  static String number(num value, {int decimals = 2}) =>
      value.toStringAsFixed(decimals);

  static String compact(int value) {
    if (value >= 100000000) return '${(value / 100000000).toStringAsFixed(1)}亿';
    if (value >= 10000) return '${(value / 10000).toStringAsFixed(1)}万';
    return value.toString();
  }

  static String fileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  @visibleForTesting
  static String pad(int n) => _pad(n);

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
