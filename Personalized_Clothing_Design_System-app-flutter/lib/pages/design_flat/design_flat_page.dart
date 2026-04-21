import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/models/design_option_model.dart';
import '../../shared/utils/option_preview_images.dart';
import 'design_flat_state.dart';
import 'design_flat_view_model.dart';

// ── 选项视觉配置 ──────────────────────────────────────────────────
typedef _OptionMeta = ({IconData icon, Color color, String label});

const _optionMeta = <String, _OptionMeta>{
  'clothing_type': (icon: Icons.checkroom,    color: Color(0xFF6A9BFA), label: '服装类型'),
  'pattern':       (icon: Icons.pattern,      color: Color(0xFFCB8DEA), label: '花纹'),
  'material':      (icon: Icons.texture,      color: Color(0xFF4ECDC4), label: '材质'),
  'style':         (icon: Icons.style,        color: Color(0xFFFF6B6B), label: '风格'),
  'audience':      (icon: Icons.people,       color: Color(0xFFFFBE0B), label: '受众人群'),
  'ai_model':      (icon: Icons.auto_awesome, color: Color(0xFF06D6A0), label: 'AI模型'),
  'color':         (icon: Icons.palette,      color: Color(0xFFFF9F43), label: '颜色'),
};

// 服装类型一级分类 code
const _clothingTopCategories = ['ct_top', 'ct_bottom', 'ct_dress', 'ct_suit'];

class DesignFlatPage extends ConsumerStatefulWidget {
  const DesignFlatPage({super.key});

  @override
  ConsumerState<DesignFlatPage> createState() => _DesignFlatPageState();
}

class _DesignFlatPageState extends ConsumerState<DesignFlatPage> {
  // 当前正在选择的 category（null = 主界面）
  String? _selectingCategory;
  // 服装类型二级：当前展开的一级分类 code
  String? _clothingParentCode;
  // 待确认的选项 id
  String? _pendingId;

  // 数值参数（胸围/腰围/衣长等），选完款式后可调整
  final Map<String, double> _sizeParams = {
    'chest': 90,   // 胸围 cm
    'waist': 70,   // 腰围 cm
    'length': 65,  // 衣长 cm
  };

  // 根据选中的服装类型决定显示哪些数值
  List<({String key, String label, double min, double max, double step})> _getSizeFields() {
    final id = _pendingId ?? '';
    // 下装
    if (['ct_straight_pants','ct_wide_pants','ct_tapered_pants','ct_jeans','ct_sweatpants','ct_shorts'].contains(id)) {
      return [
        (key: 'waist', label: '腰围', min: 55, max: 110, step: 1),
        (key: 'hip',   label: '臀围', min: 70, max: 130, step: 1),
        (key: 'length', label: '裤长', min: 40, max: 120, step: 1),
      ];
    }
    // 裙装
    if (['ct_a_skirt','ct_pleated_skirt','ct_pencil_skirt','ct_dress_full','ct_midi_skirt','ct_slip_dress'].contains(id)) {
      return [
        (key: 'chest',  label: '胸围', min: 70, max: 130, step: 1),
        (key: 'waist',  label: '腰围', min: 55, max: 110, step: 1),
        (key: 'length', label: '裙长', min: 40, max: 130, step: 1),
      ];
    }
    // 套装
    if (['ct_suit_set','ct_sport_set','ct_casual_set'].contains(id)) {
      return [
        (key: 'chest',  label: '胸围', min: 70, max: 130, step: 1),
        (key: 'waist',  label: '腰围', min: 55, max: 110, step: 1),
        (key: 'length', label: '上衣长', min: 50, max: 90, step: 1),
      ];
    }
    // 上装（默认）
    return [
      (key: 'chest',  label: '胸围', min: 70, max: 130, step: 1),
      (key: 'shoulder', label: '肩宽', min: 30, max: 60, step: 0.5),
      (key: 'length', label: '衣长', min: 40, max: 90, step: 1),
    ];
  }

  void _openSelector(String category, String? currentId) {
    setState(() {
      _selectingCategory = category;
      _pendingId = currentId;
      // 服装类型默认不展开子类
      if (category == 'clothing_type') _clothingParentCode = null;
    });
  }

  void _confirmSelection(DesignFlatViewModel vm) {
    if (_pendingId == null || _selectingCategory == null) return;
    switch (_selectingCategory) {
      case 'clothing_type':
        vm.selectClothingType(_pendingId!);
        // 把数值参数一起更新
        vm.updateParams(Map<String, dynamic>.from(_sizeParams));
      case 'pattern':       vm.selectPattern(_pendingId!);
      case 'material':      vm.selectMaterial(_pendingId!);
      case 'style':         vm.selectStyle(_pendingId!);
      case 'audience':      vm.selectAudience(_pendingId!);
      case 'ai_model':      vm.selectModel(_pendingId!);
      case 'color':         vm.selectColor(_pendingId!);
    }
    setState(() { _selectingCategory = null; _clothingParentCode = null; });
  }

  void _cancelSelection() => setState(() {
    _selectingCategory = null;
    _clothingParentCode = null;
    _pendingId = null;
  });

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(designFlatViewModelProvider);
    final vm = ref.read(designFlatViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'design_flat.title')),
        automaticallyImplyLeading: false,
        actions: [
          if (_selectingCategory != null)
            TextButton(onPressed: _cancelSelection, child: const Text('取消')),
        ],
      ),
      body: state.isLoadingOptions
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, animation) {
                      // 进入选项面板：从右滑入；返回主界面：从左滑入
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
                    child: _selectingCategory != null
                        ? _buildSelectorPanel(context, state, vm)
                        : _buildDisplayArea(context, state),
                  ),
                ),
                _buildChipRow(context, state, vm),
              ],
            ),
      bottomNavigationBar: _selectingCategory == null
          ? _buildBottomBar(context, state, vm)
          : null,
    );
  }

  // ── 选项面板 ──────────────────────────────────────────────────
  Widget _buildSelectorPanel(BuildContext context, DesignFlatState state, DesignFlatViewModel vm) {
    final cat = _selectingCategory!;
    final meta = _optionMeta[cat] ?? (icon: Icons.tune, color: AppColors.primary, label: cat);

    // 服装类型：二级选择逻辑
    if (cat == 'clothing_type') {
      return _buildClothingTypePanel(context, state, vm, meta);
    }

    // 其他选项：直接展示平铺列表
    final options = _getOptions(cat, state);
    return _buildOptionGrid(context, cat, meta, options, vm);
  }

  // 服装类型二级面板
  Widget _buildClothingTypePanel(
    BuildContext context, DesignFlatState state, DesignFlatViewModel vm, _OptionMeta meta,
  ) {
    // 一级分类
    final topOptions = state.clothingTypeOptions
        .where((o) => _clothingTopCategories.contains(o.id))
        .toList()
      ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

    // 当前展开的子类
    final subOptions = _clothingParentCode != null
        ? (state.clothingTypeOptions
            .where((o) => o.parentId == _clothingParentCode)
            .toList()
          ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0)))
        : <DesignOptionModel>[];

    return Container(
      key: const ValueKey('clothing_type'),
      color: AppColors.background,
      child: Column(
        children: [
          // 标题行
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(meta.icon, color: meta.color, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _clothingParentCode != null
                      ? _getOptionName(state.clothingTypeOptions, _clothingParentCode) ?? '服装类型'
                      : '服装类型',
                  style: AppTextStyles.titleMd.copyWith(color: AppColors.grey800),
                ),
                if (_clothingParentCode != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  GestureDetector(
                    onTap: () => setState(() { _clothingParentCode = null; _pendingId = null; }),
                    child: Icon(Icons.arrow_back_ios, size: 14, color: AppColors.grey400),
                  ),
                ],
                const Spacer(),
                Text(
                  _clothingParentCode == null ? '选择大类' : '选择款式',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.grey400),
                ),
              ],
            ),
          ),

          // 一级分类 tab 行（始终显示）
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: topOptions.length,
              itemBuilder: (context, i) {
                final opt = topOptions[i];
                final isActive = _clothingParentCode == opt.id;
                return GestureDetector(
                  onTap: () => setState(() { _clothingParentCode = opt.id; _pendingId = null; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isActive ? meta.color : AppColors.grey100,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(color: isActive ? meta.color : AppColors.grey200),
                    ),
                    child: Text(
                      opt.name,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: isActive ? Colors.white : AppColors.grey600,
                        fontWeight: isActive ? AppFontWeight.semiBold : AppFontWeight.regular,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 子类网格（选择大类后展示）
          Expanded(
            child: _clothingParentCode == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checkroom, size: 56, color: AppColors.grey200),
                        const SizedBox(height: AppSpacing.md),
                        Text('请先选择上方大类', style: AppTextStyles.bodyMd.copyWith(color: AppColors.grey400)),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: AppSpacing.sm,
                            mainAxisSpacing: AppSpacing.sm,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: subOptions.length,
                          itemBuilder: (context, i) {
                            final opt = subOptions[i];
                            final isSelected = _pendingId == opt.id;
                            return GestureDetector(
                              onTap: () => setState(() => _pendingId = opt.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: isSelected ? meta.color.withValues(alpha: 0.12) : AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  border: Border.all(
                                    color: isSelected ? meta.color : AppColors.grey200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            _buildOptionImage(opt.id, meta),
                                            if (isSelected)
                                              Container(
                                                color: meta.color.withValues(alpha: 0.5),
                                                child: Center(child: Icon(Icons.check_circle, color: Colors.white, size: 24)),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        color: isSelected ? meta.color.withValues(alpha: 0.1) : AppColors.surface,
                                        child: Text(
                                          opt.name,
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.bodySm.copyWith(
                                            color: isSelected ? meta.color : AppColors.grey700,
                                            fontWeight: isSelected ? AppFontWeight.semiBold : AppFontWeight.regular,
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
                      // 选完款式后显示数值调整区
                      if (_pendingId != null)
                        _buildSizeSliders(context, meta),
                    ],
                  ),
          ),

          // 确认/取消按钮
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md,
                AppSpacing.md + MediaQuery.of(context).padding.bottom),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _cancelSelection, child: const Text('取消'))),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _pendingId != null ? () => _confirmSelection(vm) : null,
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

  // 通用选项网格（花纹/材质/风格/受众/模型/颜色）
  Widget _buildOptionGrid(
    BuildContext context, String cat, _OptionMeta meta,
    List<DesignOptionModel> options, DesignFlatViewModel vm,
  ) {
    return Container(
      key: ValueKey(cat),
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(meta.icon, color: meta.color, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(meta.label, style: AppTextStyles.titleMd.copyWith(color: AppColors.grey800)),
                const Spacer(),
                Text('选择后点击确认', style: AppTextStyles.bodySm.copyWith(color: AppColors.grey400)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cat == 'color' ? 4 : 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: cat == 'color' ? 1.0 : 1.1,
              ),
              itemCount: options.length,
              itemBuilder: (context, i) {
                final opt = options[i];
                final isSelected = _pendingId == opt.id;

                if (cat == 'color') {
                  return GestureDetector(
                    onTap: () => setState(() => _pendingId = opt.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _colorFromCode(opt.id),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: isSelected ? meta.color : AppColors.grey200,
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected ? [BoxShadow(color: meta.color.withValues(alpha: 0.3), blurRadius: 8)] : null,
                      ),
                      child: isSelected
                          ? Center(child: Icon(Icons.check, color: _isDark(_colorFromCode(opt.id)) ? Colors.white : Colors.black87, size: 22))
                          : null,
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => setState(() => _pendingId = opt.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: isSelected ? meta.color : AppColors.grey200,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: meta.color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg - 2),
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildOptionImage(opt.id, meta),
                                if (isSelected)
                                  Container(
                                    color: meta.color.withValues(alpha: 0.5),
                                    child: const Icon(Icons.check_circle_rounded,
                                        color: Colors.white, size: 30),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            color: isSelected ? meta.color : AppColors.surface,
                            child: Text(
                              opt.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: isSelected ? Colors.white : AppColors.grey700,
                                fontWeight: isSelected ? AppFontWeight.semiBold : AppFontWeight.regular,
                                fontSize: 13,
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
            padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md,
                AppSpacing.md + MediaQuery.of(context).padding.bottom),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _cancelSelection, child: const Text('取消'))),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _pendingId != null ? () => _confirmSelection(vm) : null,
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

  // ── 展示区 ────────────────────────────────────────────────────
  Widget _buildDisplayArea(BuildContext context, DesignFlatState state) {
    return Container(
      key: const ValueKey('display'),
      color: AppColors.grey50,
      child: Center(
        child: state.isGenerating
            ? _buildGeneratingProgress(context, state)
            : state.generatedImageUrl != null
                ? _buildNetworkImageWithLoading(
                    state.generatedImageUrl!,
                    loadingText: '图片渲染中，通常需要 10-30 秒...',
                  )
                : _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildGeneratingProgress(BuildContext context, DesignFlatState state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6A9BFA), Color(0xFFCB8DEA)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(color: const Color(0xFF6A9BFA).withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 4)],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(state.generateStep.label, key: ValueKey(state.generateStep),
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.grey700, fontWeight: AppFontWeight.medium),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: state.generateStep.progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value, minHeight: 6,
                backgroundColor: AppColors.grey200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A9BFA)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('${(state.generateStep.progress * 100).toInt()}%',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.grey500)),
        ],
      ),
    );
  }

  // 缓存每个选项图片的 Future，避免重复请求
  final Map<String, Future<void>> _imageFutures = {};

  Widget _buildOptionImage(String optionId, _OptionMeta meta) {
    final url = optionPreviewImages[optionId];
    if (url == null) {
      return Container(
        color: meta.color.withValues(alpha: 0.1),
        child: Icon(getOptionIcon(optionId, meta.icon), color: meta.color, size: 30),
      );
    }
    _imageFutures[optionId] ??= precacheImage(NetworkImage(url), context);
    return FutureBuilder<void>(
      future: _imageFutures[optionId],
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            color: meta.color.withValues(alpha: 0.08),
            child: Center(
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(meta.color),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Container(
            color: meta.color.withValues(alpha: 0.1),
            child: Icon(getOptionIcon(optionId, meta.icon), color: meta.color, size: 30),
          );
        }
        return Image.network(url, fit: BoxFit.cover);
      },
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 48, color: AppColors.grey300),
                const SizedBox(height: AppSpacing.md),
                Text('图片加载失败，请检查网络',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.grey400)),
                const SizedBox(height: AppSpacing.sm),
                TextButton(onPressed: () => setState(() {}), child: const Text('点击重试')),
              ],
            ),
          );
        }
        return Image.network(url, fit: BoxFit.contain);
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 64, color: AppColors.grey300),
        const SizedBox(height: AppSpacing.md),
        Text(FlutterI18n.translate(context, 'design_flat.placeholder'),
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.grey400), textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text('点击下方选项开始配置', style: AppTextStyles.bodySm.copyWith(color: AppColors.grey300)),
      ],
    );
  }

  // ── Chip 行 ───────────────────────────────────────────────────
  Widget _buildChipRow(BuildContext context, DesignFlatState state, DesignFlatViewModel vm) {
    final chips = [
      ('clothing_type', state.clothingTypeOptions, state.selectedClothingType),
      ('pattern',       state.patternOptions,       state.selectedPattern),
      ('material',      state.materialOptions,      state.selectedMaterial),
      ('style',         state.styleOptions,         state.selectedStyle),
      ('audience',      state.audienceOptions,      state.selectedAudience),
      ('ai_model',      state.modelOptions,         state.selectedModel),
      ('color',         state.colorOptions,         state.selectedColor),
    ];

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        itemCount: chips.length,
        itemBuilder: (context, i) {
          final (cat, opts, selectedId) = chips[i];
          final meta = _optionMeta[cat];
          final selectedName = _getOptionName(opts, selectedId);
          final isActive = _selectingCategory == cat;
          final isRequired = cat != 'color';

          return GestureDetector(
            onTap: () => _openSelector(cat, selectedId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isActive
                    ? (meta?.color ?? AppColors.primary)
                    : selectedName != null
                        ? (meta?.color ?? AppColors.primary).withValues(alpha: 0.1)
                        : AppColors.grey100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: isActive
                      ? (meta?.color ?? AppColors.primary)
                      : selectedName != null
                          ? (meta?.color ?? AppColors.primary).withValues(alpha: 0.4)
                          : isRequired ? AppColors.grey300 : AppColors.grey200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cat == 'color' && selectedId != null)
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: _colorFromCode(selectedId),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.grey300, width: 0.5),
                      ),
                    )
                  else
                    Icon(meta?.icon ?? Icons.tune, size: 14,
                        color: isActive ? Colors.white
                            : selectedName != null ? (meta?.color ?? AppColors.primary) : AppColors.grey500),
                  const SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(meta?.label ?? cat,
                              style: AppTextStyles.labelMd.copyWith(
                                color: isActive ? Colors.white70 : AppColors.grey500, fontSize: 10)),
                          if (isRequired && selectedName == null)
                            Text(' *', style: AppTextStyles.labelMd.copyWith(color: AppColors.error, fontSize: 10)),
                        ],
                      ),
                      Text(selectedName ?? (cat == 'color' ? '可选' : '未选择'),
                          style: AppTextStyles.bodySm.copyWith(
                            color: isActive ? Colors.white
                                : selectedName != null ? (meta?.color ?? AppColors.primary) : AppColors.grey400,
                            fontWeight: selectedName != null ? AppFontWeight.semiBold : AppFontWeight.regular,
                          )),
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

  // ── 底部操作栏 ────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, DesignFlatState state, DesignFlatViewModel vm) {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md,
          AppSpacing.sm + MediaQuery.of(context).padding.bottom),
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
                  Expanded(child: Text(state.errorMessage!,
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.error))),
                ],
              ),
            ),
          Row(
            children: [
              if (state.generatedImageUrl != null) ...[
                IconButton(
                  onPressed: state.isGenerating ? null : vm.reset,
                  icon: const Icon(Icons.refresh),
                  tooltip: '重置',
                ),
                IconButton(
                  onPressed: (state.isGenerating || !state.canRegenerate) ? null : vm.regenerate,
                  icon: Icon(Icons.autorenew,
                      color: state.canRegenerate ? null : AppColors.grey300),
                  tooltip: state.canRegenerate ? '重新生成（剩余${2 - state.regenerateCount}次）' : '已达重新生成上限',
                ),
              ],
              const Spacer(),
              if (state.generatedImageUrl != null)
                FilledButton.icon(
                  onPressed: () => context.push(RouteName.design3d, extra: {
                    'flatDesignId': state.generatedDesignId,
                    'flatImageUrl': state.generatedImageUrl,
                  }),
                  icon: const Icon(Icons.view_in_ar, size: 18),
                  label: Text(FlutterI18n.translate(context, 'design_flat.next_step')),
                )
              else ...[
                OutlinedButton.icon(
                  onPressed: state.isGenerating ? null : vm.generateRandomDesign,
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: Text(FlutterI18n.translate(context, 'design_flat.random_generate')),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: state.canGenerate && !state.isGenerating ? vm.generateFlatDesign : null,
                  child: state.isGenerating
                      ? const SizedBox(height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(FlutterI18n.translate(context, 'design_flat.generate')),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── 工具方法 ──────────────────────────────────────────────────
  List<DesignOptionModel> _getOptions(String cat, DesignFlatState state) => switch (cat) {
    'clothing_type' => state.clothingTypeOptions,
    'pattern'       => state.patternOptions,
    'material'      => state.materialOptions,
    'style'         => state.styleOptions,
    'audience'      => state.audienceOptions,
    'ai_model'      => state.modelOptions,
    'color'         => state.colorOptions,
    _               => [],
  };

  String? _getOptionName(List<DesignOptionModel> options, String? id) {
    if (id == null) return null;
    try { return options.firstWhere((o) => o.id == id).name; } catch (_) { return null; }
  }

  Color _colorFromCode(String code) {
    const map = {
      'col_white':    Color(0xFFF5F5F5),
      'col_black':    Color(0xFF2C2C2C),
      'col_sky_blue': Color(0xFF87CEEB),
      'col_coral':    Color(0xFFFF6B6B),
      'col_mint':     Color(0xFF98D8C8),
      'col_cream':    Color(0xFFFFF3CD),
      'col_gray':     Color(0xFF9E9E9E),
      'col_navy':     Color(0xFF1A237E),
      'col_pink':     Color(0xFFFFB6C1),
      'col_purple':   Color(0xFF9C27B0),
      'col_orange':   Color(0xFFFF9800),
      'col_brown':    Color(0xFF795548),
    };
    return map[code] ?? const Color(0xFFE0E0E0);
  }

  bool _isDark(Color c) => c.computeLuminance() < 0.4;

  // ── 数值调整滑块 ──────────────────────────────────────────────
  Widget _buildSizeSliders(BuildContext context, _OptionMeta meta) {
    final fields = _getSizeFields();
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: meta.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.straighten, size: 16, color: meta.color),
              const SizedBox(width: 6),
              Text('尺寸调整（可选）',
                  style: AppTextStyles.bodySm.copyWith(
                      color: meta.color, fontWeight: AppFontWeight.semiBold)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...fields.map((f) {
            final val = _sizeParams[f.key] ?? f.min + (f.max - f.min) / 2;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(f.label,
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.grey600)),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: meta.color,
                        thumbColor: meta.color,
                        inactiveTrackColor: meta.color.withValues(alpha: 0.2),
                        overlayColor: meta.color.withValues(alpha: 0.1),
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: val.clamp(f.min, f.max),
                        min: f.min,
                        max: f.max,
                        divisions: ((f.max - f.min) / f.step).round(),
                        onChanged: (v) => setState(() =>
                            _sizeParams[f.key] = (v * (1 / f.step)).round() * f.step),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text('${val.toStringAsFixed(f.step < 1 ? 1 : 0)} cm',
                        style: AppTextStyles.bodySm.copyWith(
                            color: meta.color, fontWeight: AppFontWeight.semiBold),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
