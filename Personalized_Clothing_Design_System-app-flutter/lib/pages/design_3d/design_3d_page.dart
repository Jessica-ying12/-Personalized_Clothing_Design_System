import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/models/design_option_model.dart';
import '../../shared/utils/option_preview_images.dart';
import 'design_3d_state.dart';
import 'design_3d_view_model.dart';

// 3D 选项视觉配置
const d3OptionMeta = <String, ({IconData icon, Color color, String label})>{
  'body_type': (
    icon: Icons.accessibility_new,
    color: Color(0xFF6A9BFA),
    label: '身体类型',
  ),
  'skin_tone': (icon: Icons.face, color: Color(0xFFFFBE0B), label: '肤色'),
  'gender': (icon: Icons.people, color: Color(0xFFCB8DEA), label: '性别'),
  'ai_model': (
    icon: Icons.auto_awesome,
    color: Color(0xFF06D6A0),
    label: 'AI模型',
  ),
  'background': (icon: Icons.wallpaper, color: Color(0xFFFF6B6B), label: '背景'),
};

class Design3dPage extends ConsumerStatefulWidget {
  const Design3dPage({super.key, this.flatDesignId, this.flatImageUrl});

  final String? flatDesignId;
  final String? flatImageUrl;

  @override
  ConsumerState<Design3dPage> createState() => _Design3dPageState();
}

class _Design3dPageState extends ConsumerState<Design3dPage> {
  String? _selectingCategory;
  String? _pendingId;

  @override
  void initState() {
    super.initState();
    if (widget.flatDesignId != null) {
      Future.microtask(() {
        ref
            .read(design3dViewModelProvider.notifier)
            .initialize(widget.flatDesignId!, widget.flatImageUrl);
      });
    }
  }

  void _openSelector(String category, String? currentId) {
    setState(() {
      _selectingCategory = category;
      _pendingId = currentId;
    });
  }

  void _confirmSelection(Design3dViewModel vm) {
    if (_pendingId == null || _selectingCategory == null) return;
    switch (_selectingCategory) {
      case 'body_type':
        vm.selectBodyType(_pendingId!);
      case 'skin_tone':
        vm.selectSkinTone(_pendingId!);
      case 'gender':
        vm.selectGender(_pendingId!);
      case 'ai_model':
        vm.selectModel(_pendingId!);
      case 'background':
        vm.selectBackground(_pendingId!);
    }
    setState(() => _selectingCategory = null);
  }

  void _cancelSelection() => setState(() => _selectingCategory = null);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(design3dViewModelProvider);
    final vm = ref.read(design3dViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'design_3d.title')),
        actions: [
          if (_selectingCategory != null)
            TextButton(onPressed: _cancelSelection, child: const Text('取消')),
        ],
      ),
      body:
          state.isLoadingOptions
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        final isSelector = _selectingCategory != null;
                        final offsetTween = Tween<Offset>(
                          begin: Offset(isSelector ? 1.0 : -1.0, 0),
                          end: Offset.zero,
                        );
                        return SlideTransition(
                          position: offsetTween.animate(
                            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                          ),
                          child: child,
                        );
                      },
                      child:
                          _selectingCategory != null
                              ? _buildSelectorPanel(context, state, vm)
                              : _buildDisplayArea(context, state, vm),
                    ),
                  ),
                  _buildChipRow(context, state, vm),
                ],
              ),
      bottomNavigationBar:
          _selectingCategory == null
              ? _buildBottomBar(context, state, vm)
              : null,
    );
  }

  // ── 选项卡片面板 ──────────────────────────────────────────────
  Widget _buildSelectorPanel(
    BuildContext context,
    Design3dState state,
    Design3dViewModel vm,
  ) {
    final cat = _selectingCategory!;
    final meta =
        d3OptionMeta[cat] ??
        (icon: Icons.tune, color: AppColors.primary, label: cat);

    List<DesignOptionModel> options;
    switch (cat) {
      case 'body_type':
        options = state.bodyTypeOptions;
      case 'skin_tone':
        options = state.skinToneOptions;
      case 'gender':
        options = state.genderOptions;
      case 'ai_model':
        options = state.modelOptions;
      case 'background':
        options = state.backgroundOptions;
      default:
        options = [];
    }

    return Container(
      key: ValueKey(cat),
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(meta.icon, color: meta.color, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  meta.label,
                  style: AppTextStyles.titleMd.copyWith(
                    color: AppColors.grey800,
                  ),
                ),
                const Spacer(),
                Text(
                  '选择后点击确认',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.1,
              ),
              itemCount: options.length,
              itemBuilder: (context, i) {
                final opt = options[i];
                final isSelected = _pendingId == opt.id;
                final previewUrl = optionPreviewImages[opt.id];
                return GestureDetector(
                  onTap: () => setState(() => _pendingId = opt.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? meta.color.withValues(alpha: 0.12)
                              : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: isSelected ? meta.color : AppColors.grey200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusLg - 1,
                      ),
                      child: Stack(
                        children: [
                          // 预览�?
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 70,
                            child:
                                previewUrl != null
                                    ? Image.network(
                                      previewUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            color: meta.color.withValues(
                                              alpha: 0.08,
                                            ),
                                            child: Icon(
                                              meta.icon,
                                              color: meta.color.withValues(
                                                alpha: 0.3,
                                              ),
                                              size: 32,
                                            ),
                                          ),
                                    )
                                    : Container(
                                      color: meta.color.withValues(alpha: 0.08),
                                      child: Icon(
                                        meta.icon,
                                        color: meta.color.withValues(
                                          alpha: 0.4,
                                        ),
                                        size: 32,
                                      ),
                                    ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 70,
                              child: Container(
                                color: meta.color.withValues(alpha: 0.2),
                                child: Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: meta.color,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              color:
                                  isSelected
                                      ? meta.color.withValues(alpha: 0.12)
                                      : AppColors.surface,
                              child: Text(
                                opt.name,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color:
                                      isSelected
                                          ? meta.color
                                          : AppColors.grey800,
                                  fontWeight:
                                      isSelected
                                          ? AppFontWeight.semiBold
                                          : AppFontWeight.regular,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelSelection,
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed:
                        _pendingId != null ? () => _confirmSelection(vm) : null,
                    style: FilledButton.styleFrom(backgroundColor: meta.color),
                    child: const Text('确认选择'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 图片展示�?────────────────────────────────────────────────
  Widget _buildDisplayArea(
    BuildContext context,
    Design3dState state,
    Design3dViewModel vm,
  ) {
    return Container(
      key: const ValueKey('display3d'),
      color: AppColors.grey50,
      child: Stack(
        children: [
          Center(
            child:
                state.isGenerating
                    ? _buildGenerating(context)
                    : AnimatedCrossFade(
                      duration: const Duration(milliseconds: 350),
                      crossFadeState:
                          state.showFlat
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                      firstChild:
                          state.flatImageUrl != null
                              ? _buildNetworkImageWithLoading(
                                  state.flatImageUrl!,
                                  loadingText: '平面图加载中...',
                                )
                              : _buildPlaceholder(context),
                      secondChild:
                          state.generated3dImageUrl != null
                              ? _buildNetworkImageWithLoading(
                                  state.generated3dImageUrl!,
                                  loadingText: 'AI 正在渲染立体图，通常需要 30-60 秒...',
                                )
                              : _buildPlaceholder(context),
                    ),
          ),
          // 生成后右上角操作按钮
          if (state.generated3dImageUrl != null && !state.isGenerating)
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Column(
                children: [
                  _actionBtn(
                    icon: state.showFlat ? Icons.view_in_ar : Icons.image,
                    label: state.showFlat ? '3D视图' : '平面图',
                    onTap: vm.toggleView,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (state.canRegenerate)
                    _actionBtn(
                      icon: Icons.refresh,
                      label: '重新生成',
                      onTap: state.isGenerating ? null : vm.regenerate3d,
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  _actionBtn(
                    icon: Icons.wallpaper,
                    label: '换背景',
                    onTap: state.isGenerating ? null : vm.changeBackground,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNetworkImageWithLoading(String url, {String loadingText = '图片加载中...'}) {
    return FutureBuilder<void>(
      future: precacheImage(NetworkImage(url), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF6A9BFA), Color(0xFFCB8DEA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(loadingText,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.grey600)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('请耐心等待，不要关闭页面',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.grey400)),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildImageError();
        }
        return Image.network(url, fit: BoxFit.contain);
      },
    );
  }

  Widget _buildImageError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 48, color: AppColors.grey300),
          const SizedBox(height: AppSpacing.md),
          Text(
            '图片加载失败，网络可能较慢',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.grey400),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => setState(() {}),
            child: const Text('点击重试'),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey200.withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerating(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6A9BFA), Color(0xFFCB8DEA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A9BFA).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.view_in_ar, color: Colors.white, size: 32),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'AI 虚拟试穿中...',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.grey700,
            fontWeight: AppFontWeight.medium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '首次使用需唤醒 AI 服务，约需 30-60 秒',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.grey400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        const SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A9BFA)),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '正在将服装穿到模特身上...',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.grey400),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.view_in_ar, size: 64, color: AppColors.grey300),
        const SizedBox(height: AppSpacing.md),
        Text(
          FlutterI18n.translate(context, 'design_3d.placeholder'),
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.grey400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '点击下方选项配置参数',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.grey300),
        ),
      ],
    );
  }

  // ── 底部 chip �?──────────────────────────────────────────────
  Widget _buildChipRow(
    BuildContext context,
    Design3dState state,
    Design3dViewModel vm,
  ) {
    final chips = [
      ('body_type', state.bodyTypeOptions, state.selectedBodyType),
      ('skin_tone', state.skinToneOptions, state.selectedSkinTone),
      ('gender', state.genderOptions, state.selectedGender),
      ('ai_model', state.modelOptions, state.selectedModel),
      ('background', state.backgroundOptions, state.selectedBackground),
    ];

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: chips.length,
        itemBuilder: (context, i) {
          final (cat, opts, selectedId) = chips[i];
          final meta = d3OptionMeta[cat];
          final selectedName =
              selectedId != null ? _getOptionName(opts, selectedId) : null;
          final isActive = _selectingCategory == cat;

          return GestureDetector(
            onTap: () => _openSelector(cat, selectedId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.smd,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? (meta?.color ?? AppColors.primary)
                        : selectedName != null
                        ? (meta?.color ?? AppColors.primary).withValues(
                          alpha: 0.1,
                        )
                        : AppColors.grey100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color:
                      isActive
                          ? (meta?.color ?? AppColors.primary)
                          : selectedName != null
                          ? (meta?.color ?? AppColors.primary).withValues(
                            alpha: 0.4,
                          )
                          : AppColors.grey200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    meta?.icon ?? Icons.tune,
                    size: 14,
                    color:
                        isActive
                            ? Colors.white
                            : selectedName != null
                            ? (meta?.color ?? AppColors.primary)
                            : AppColors.grey500,
                  ),
                  const SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta?.label ?? cat,
                        style: AppTextStyles.labelMd.copyWith(
                          color: isActive ? Colors.white70 : AppColors.grey500,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        selectedName ?? '未选择',
                        style: AppTextStyles.bodySm.copyWith(
                          color:
                              isActive
                                  ? Colors.white
                                  : selectedName != null
                                  ? (meta?.color ?? AppColors.primary)
                                  : AppColors.grey400,
                          fontWeight:
                              selectedName != null
                                  ? AppFontWeight.semiBold
                                  : AppFontWeight.regular,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _getOptionName(List<DesignOptionModel> options, String? id) {
    if (id == null) return null;
    try {
      return options.firstWhere((o) => o.id == id).name;
    } catch (_) {
      return null;
    }
  }

  // ── 底部操作�?────────────────────────────────────────────────
  Widget _buildBottomBar(
    BuildContext context,
    Design3dState state,
    Design3dViewModel vm,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(FlutterI18n.translate(context, 'design_3d.back')),
              ),
              const Spacer(),
              // 重新生成平面图（最多2次，仅在未生成立体图时显示）
              if (state.generated3dImageUrl == null && state.flatDesignId != null) ...[
                OutlinedButton.icon(
                  onPressed: (state.isGenerating || !state.canRegenerateFlat)
                      ? null
                      : vm.regenerateFlat,
                  icon: const Icon(Icons.image_search, size: 16),
                  label: Text(
                    state.canRegenerateFlat
                        ? '换平面图(${2 - state.flatRegenerateCount}次)'
                        : '已达上限',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (state.generated3dImageUrl == null)
                FilledButton(
                  onPressed:
                      state.canGenerate && !state.isGenerating
                          ? vm.generate3dDesign
                          : null,
                  child:
                      state.isGenerating
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            FlutterI18n.translate(
                              context,
                              'design_3d.generate',
                            ),
                          ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
