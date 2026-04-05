import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme.dart';
import '../../shared/shared.dart';
import 'unimp_demo_view_model.dart';

class UniMPDemoPage extends ConsumerStatefulWidget {
  const UniMPDemoPage({super.key});

  @override
  ConsumerState<UniMPDemoPage> createState() => _UniMPDemoPageState();
}

class _UniMPDemoPageState extends ConsumerState<UniMPDemoPage> {
  final _appIdController = TextEditingController(text: '__UNI__1A35A87');
  final _wgtUrlController = TextEditingController(
    text: 'https://www.sodatool.com/d/c553e93e-0bcd-4f96-b871-751800eefb54',
  );

  @override
  void dispose() {
    _appIdController.dispose();
    _wgtUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unimpDemoViewModelProvider);
    final vm = ref.read(unimpDemoViewModelProvider.notifier);

    return Scaffold(
      appBar: const AppNavigationBar(title: 'UniMP Demo'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _appIdController,
              decoration: const InputDecoration(
                labelText: 'AppID',
                border: OutlineInputBorder(),
              ),
              onChanged: vm.updateAppId,
            ),
            const SizedBox(height: AppSpacing.smd),
            TextField(
              controller: _wgtUrlController,
              decoration: const InputDecoration(
                labelText: 'wgt 远程地址（可选）',
                hintText: 'https://example.com/app.wgt',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.smd,
              runSpacing: AppSpacing.smd,
              children: [
                _buildButton('打开', state.loading, vm.openMiniProgram),
                _buildButton('关闭', state.loading, vm.closeMiniProgram),
                _buildButton('检查存在', state.loading, vm.checkExists),
                _buildButton('版本', state.loading, vm.getVersion),
                _buildButton('远程安装', state.loading, () {
                  final url = _wgtUrlController.text.trim();
                  if (url.isEmpty) return;
                  vm.downloadAndInstall(url);
                }),
                if (state.loading && state.downloadProgress != null)
                  _buildButton('取消下载', false, vm.cancelDownload),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.smd),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: AppFontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (state.loading)
                    LinearProgressIndicator(value: state.downloadProgress),
                  if (state.status.isNotEmpty) Text(state.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, bool loading, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: Text(label),
    );
  }
}
