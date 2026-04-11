import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'design_3d_state.dart';
import 'design_3d_view_model.dart';

class Design3dPage extends ConsumerStatefulWidget {
  const Design3dPage({
    super.key,
    this.flatDesignId,
    this.flatImageUrl,
  });

  final String? flatDesignId;
  final String? flatImageUrl;

  @override
  ConsumerState<Design3dPage> createState() => _Design3dPageState();
}

class _Design3dPageState extends ConsumerState<Design3dPage> {
  @override
  void initState() {
    super.initState();
    if (widget.flatDesignId != null) {
      Future.microtask(() {
        ref.read(design3dViewModelProvider.notifier).initialize(
              widget.flatDesignId!,
              widget.flatImageUrl,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(design3dViewModelProvider);
    final viewModel = ref.read(design3dViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'design_3d.title')),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildOptionsPanel(context, state, viewModel),
          ),
          Expanded(
            flex: 3,
            child: _buildDisplayArea(context, state, viewModel),
          ),
          Expanded(
            flex: 2,
            child: _buildControlPanel(context, state, viewModel),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, state, viewModel),
    );
  }

  Widget _buildOptionsPanel(
    BuildContext context,
    Design3dState state,
    Design3dViewModel viewModel,
  ) {
    if (state.isLoadingOptions) {
      return Container(
        color: AppColors.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptionItem(
              context,
              'design_3d.body_type',
              _getOptionName(state.bodyTypeOptions, state.selectedBodyType),
              () => _showOptionDialog(
                context,
                'design_3d.body_type',
                state.bodyTypeOptions,
                state.selectedBodyType,
                viewModel.selectBodyType,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOptionItem(
              context,
              'design_3d.skin_tone',
              _getOptionName(state.skinToneOptions, state.selectedSkinTone),
              () => _showOptionDialog(
                context,
                'design_3d.skin_tone',
                state.skinToneOptions,
                state.selectedSkinTone,
                viewModel.selectSkinTone,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOptionItem(
              context,
              'design_3d.gender',
              _getOptionName(state.genderOptions, state.selectedGender),
              () => _showOptionDialog(
                context,
                'design_3d.gender',
                state.genderOptions,
                state.selectedGender,
                viewModel.selectGender,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOptionItem(
              context,
              'design_3d.model',
              _getOptionName(state.modelOptions, state.selectedModel),
              () => _showOptionDialog(
                context,
                'design_3d.model',
                state.modelOptions,
                state.selectedModel,
                viewModel.selectModel,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOptionItem(
              context,
              'design_3d.background',
              _getOptionName(state.backgroundOptions, state.selectedBackground),
              () => _showOptionDialog(
                context,
                'design_3d.background',
                state.backgroundOptions,
                state.selectedBackground,
                viewModel.selectBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    String labelKey,
    String? value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.smd),
        decoration: BoxDecoration(
          color: value != null ? AppColors.primaryLight : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FlutterI18n.translate(context, labelKey),
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      value,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }

  String? _getOptionName(List<dynamic> options, String? selectedId) {
    if (selectedId == null) return null;
    try {
      final option = options.firstWhere((o) => o.id == selectedId);
      return option.name;
    } catch (e) {
      return null;
    }
  }

  void _showOptionDialog(
    BuildContext context,
    String titleKey,
    List<dynamic> options,
    String? selectedId,
    Function(String) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(FlutterI18n.translate(context, titleKey)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option.id == selectedId;

              return ListTile(
                title: Text(option.name),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                selected: isSelected,
                onTap: () {
                  onSelect(option.id);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterI18n.translate(context, 'common.cancel')),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayArea(
    BuildContext context,
    Design3dState state,
    Design3dViewModel viewModel,
  ) {
    return Container(
      color: AppColors.grey50,
      child: Center(
        child: state.showFlat && state.flatImageUrl != null
            ? Image.network(
                state.flatImageUrl!,
                fit: BoxFit.contain,
              )
            : state.generated3dImageUrl != null
                ? Image.network(
                    state.generated3dImageUrl!,
                    fit: BoxFit.contain,
                  )
                : _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.view_in_ar,
          size: 80,
          color: AppColors.grey300,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          FlutterI18n.translate(context, 'design_3d.placeholder'),
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.grey400,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel(
    BuildContext context,
    Design3dState state,
    Design3dViewModel viewModel,
  ) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.generated3dImageUrl != null) ...[
            ElevatedButton.icon(
              onPressed: viewModel.changeBackground,
              icon: const Icon(Icons.wallpaper),
              label: Text(
                FlutterI18n.translate(context, 'design_3d.change_background'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton.icon(
              onPressed: viewModel.toggleView,
              icon: Icon(state.showFlat ? Icons.view_in_ar : Icons.image),
              label: Text(
                FlutterI18n.translate(context, 'design_3d.toggle_view'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (state.canRegenerate)
              ElevatedButton.icon(
                onPressed: state.isGenerating ? null : viewModel.regenerate3d,
                icon: const Icon(Icons.refresh),
                label: Text(
                  FlutterI18n.translate(context, 'design_3d.regenerate'),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    Design3dState state,
    Design3dViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
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
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: Text(
                  FlutterI18n.translate(context, 'design_3d.back'),
                ),
              ),
              const Spacer(),
              if (state.generated3dImageUrl == null)
                ElevatedButton(
                  onPressed: state.canGenerate && !state.isGenerating
                      ? viewModel.generate3dDesign
                      : null,
                  child: state.isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          FlutterI18n.translate(context, 'design_3d.generate'),
                        ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
