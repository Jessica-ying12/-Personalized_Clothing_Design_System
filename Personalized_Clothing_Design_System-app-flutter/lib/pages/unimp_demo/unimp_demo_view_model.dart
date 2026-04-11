import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/unimp/unimp_service.dart';
import 'unimp_demo_state.dart';

class UniMPDemoViewModel extends Notifier<UniMPDemoState> {
  CancelToken? _downloadCancelToken;

  @override
  UniMPDemoState build() => const UniMPDemoState();

  void updateAppId(String appId) {
    state = state.copyWith(appId: appId);
  }

  Future<void> openMiniProgram() async {
    await _execute('打开小程序', () async {
      await UniMPService.open(state.appId);
      state = state.copyWith(status: '小程序已打开');
    });
  }

  Future<void> closeMiniProgram() async {
    await _execute('关闭小程序', () async {
      await UniMPService.close(state.appId);
      state = state.copyWith(status: '小程序已关闭');
    });
  }

  Future<void> checkExists() async {
    await _execute('检查小程序', () async {
      final exists = await UniMPService.checkExists(state.appId);
      state = state.copyWith(status: exists ? '小程序已安装' : '小程序未安装');
    });
  }

  Future<void> getVersion() async {
    await _execute('获取版本', () async {
      final version = await UniMPService.getVersion(state.appId);
      state = state.copyWith(
        status: version != null ? '版本: $version' : '无版本信息',
      );
    });
  }

  Future<void> downloadAndInstall(String wgtUrl) async {
    if (state.loading) return;
    _downloadCancelToken = CancelToken();
    state = state.copyWith(
      loading: true,
      status: '下载�?..',
      downloadProgress: () => 0.0,
    );
    try {
      await UniMPService.downloadAndInstall(
        wgtUrl,
        appId: state.appId,
        cancelToken: _downloadCancelToken,
        onProgress: (progress) {
          state = state.copyWith(
            status: '下载�?${(progress * 100).toStringAsFixed(0)}%',
            downloadProgress: () => progress,
          );
        },
      );
      state = state.copyWith(
        status: '安装完成，小程序已打开',
        downloadProgress: () => null,
      );
    } on UniMPException catch (e) {
      state = state.copyWith(
        status: '远程安装失败: $e',
        downloadProgress: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        status: '远程安装异常: $e',
        downloadProgress: () => null,
      );
    } finally {
      _downloadCancelToken = null;
      state = state.copyWith(loading: false);
    }
  }

  void cancelDownload() {
    _downloadCancelToken?.cancel('用户取消');
    _downloadCancelToken = null;
  }

  Future<void> _execute(String action, Future<void> Function() task) async {
    if (state.loading) return;
    state = state.copyWith(loading: true, status: '$action...');
    try {
      await task();
    } on UniMPException catch (e) {
      state = state.copyWith(status: '$action 失败: $e');
    } catch (e) {
      state = state.copyWith(status: '$action 异常: $e');
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}

final unimpDemoViewModelProvider =
    NotifierProvider<UniMPDemoViewModel, UniMPDemoState>(
        UniMPDemoViewModel.new);
