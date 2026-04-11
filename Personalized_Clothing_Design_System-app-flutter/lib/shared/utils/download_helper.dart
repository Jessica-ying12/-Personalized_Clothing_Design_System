import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:path_provider/path_provider.dart';

class DownloadHelper {
  static Future<String?> downloadImage(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    try {
      // 显示下载进度对话�?
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(FlutterI18n.translate(context, 'common.downloading')),
            ],
          ),
        ),
      );

      // 获取下载目录
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('无法获取存储目录');
      }

      // 创建保存路径
      final savePath = '${directory.path}/$fileName';

      // 下载文件
      final dio = Dio();
      await dio.download(url, savePath);

      // 关闭进度对话�?
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return savePath;
    } catch (e) {
      // 关闭进度对话�?
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  static void showDownloadSuccess(BuildContext context, String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${FlutterI18n.translate(context, 'common.download_success')}: $path',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showDownloadError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${FlutterI18n.translate(context, 'common.download_failed')}: $error',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
