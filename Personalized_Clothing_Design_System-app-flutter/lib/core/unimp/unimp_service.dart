import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class UniMPService {
  static const _channel = MethodChannel('UniMP_mini_apps');

  UniMPService._();

  static Future<bool> open(String appId,
      {Map<String, dynamic>? extraData}) async {
    final result = await _invoke<bool>('open', {
      'appId': appId,
      if (extraData != null) 'extraData': extraData,
    });
    return result ?? false;
  }

  static Future<bool> close(String appId) async {
    return await _invoke<bool>('close', {'appId': appId}) ?? false;
  }

  static Future<bool> install(String appId, String wgtPath) async {
    final result = await _invoke<bool>('install', {
      'appId': appId,
      'wgtPath': wgtPath,
    });
    return result ?? false;
  }

  static Future<bool> checkExists(String appId) async {
    return await _invoke<bool>('checkExists', {'appId': appId}) ?? false;
  }

  static Future<Map<String, String>?> getVersion(String appId) async {
    final result = await _invoke<Map>('getVersion', {'appId': appId});
    return result?.cast<String, String>();
  }

  static Future<bool> downloadAndInstall(
    String wgtUrl, {
    required String appId,
    void Function(double progress)? onProgress,
    bool autoOpen = true,
    CancelToken? cancelToken,
  }) async {
    final cacheDir = await getTemporaryDirectory();
    final wgtDir = Directory('${cacheDir.path}/unimp_wgt');
    if (!wgtDir.existsSync()) wgtDir.createSync(recursive: true);
    final savePath = '${wgtDir.path}/$appId.wgt';

    final dio = Dio();
    try {
      await dio.download(
        wgtUrl,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(received / total);
        },
      );
    } on DioException catch (e) {
      throw UniMPException('download', e.message ?? 'Download failed');
    } finally {
      dio.close();
    }

    final installed = await install(appId, savePath);
    if (!installed) {
      throw UniMPException('install', 'Install returned false');
    }

    try {
      File(savePath).deleteSync();
    } catch (_) {}

    if (autoOpen) await open(appId);
    return true;
  }

  static Future<T?> _invoke<T>(
      String method, Map<String, dynamic> args) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      throw UniMPException(method, e.message ?? 'Unknown error');
    }
  }
}

class UniMPException implements Exception {
  final String method;
  final String message;

  UniMPException(this.method, this.message);

  @override
  String toString() => 'UniMPException[$method]: $message';
}
