import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'package:personalized_clothing_design_system/pages/design_flat/design_flat_state.dart';
import 'package:personalized_clothing_design_system/pages/design_flat/design_flat_view_model.dart';

class DesignFlatPage extends ConsumerWidget {
  const DesignFlatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designFlatViewModelProvider);
    final viewModel = ref.read(designFlatViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'design_flat.title')),
      ),
      body: Row(
        children: [
          // 左侧选项�?
          Expanded(
            flex: 2,
            child: _buildOptionsPanel(context, state, viewModel),
          ),
          // 中央展示�?
          Expanded(
            flex: 3,
            child: _buildDisplayArea(context, state),
          ),
          // 右侧选项�?
          Expanded(
            flex: 2,
            child: _buildDetailsPanel(context, state, viewModel),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, state, viewModel),
    );
  }

  Widget _buildOptionsPanel(
    BuildContext context,
    DesignFlatState state,
    DesignFlatViewModel viewModel,
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
              'design_flat.clothing_type',
              _getOptionName(state.clothingTypeOptions, state.selectedClothingType),
              () => viewModel.setStep(DesignStep.selectingClothingType),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOptionItem(
              context,
              'design_flat.pattern',
              _getOptionName(state.patternOptions, state.selectedPattern),
              () => viewModel.setStep(DesignStep.selectingPattern),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOptionItem(
              context,
              'design_flat.material',
              _getOptionName(state.materialOptions, state.selectedMaterial),
              () => viewModel.setStep(DesignStep.selectingMaterial),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOptionItem(
              context,
              'design_flat.style',
              _getOptionName(state.styleOptions, state.selectedStyle),
              () => viewModel.setStep(DesignStep.selectingStyle),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOptionItem(
              context,
              'design_flat.audience',
              _getOptionName(state.audienceOptions, state.selectedAudience),
              () => viewModel.setStep(DesignStep.selectingAudience),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOptionItem(
              context,
              'design_flat.model',
              _getOptionName(state.modelOptions, state.selectedModel),
              () => viewModel.setStep(DesignStep.selectingModel),
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

  Widget _buildDisplayArea(BuildContext context, DesignFlatState state) {
    return Container(
      color: AppColors.grey50,
      child: Center(
        child: state.generatedImageUrl != null
            ? Image.network(
                state.generatedImageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildPlaceholder(context),
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
          Icons.image_outlined,
          size: 80,
          color: AppColors.grey300,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          FlutterI18n.translate(context, 'design_flat.placeholder'),
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.grey400,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsPanel(
    BuildContext context,
    DesignFlatState state,
    DesignFlatViewModel viewModel,
  ) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FlutterI18n.translate(context, 'design_flat.details'),
            style: AppTextStyles.titleMd.copyWith(
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _buildDetailContent(context, state, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    DesignFlatState state,
    DesignFlatViewModel viewModel,
  ) {
    switch (state.currentStep) {
      case DesignStep.selectingClothingType:
        return _buildOptionList(
          context,
          state.clothingTypeOptions,
          state.selectedClothingType,
          viewModel.selectClothingType,
        );
      case DesignStep.selectingPattern:
        return _buildOptionList(
          context,
          state.patternOptions,
          state.selectedPattern,
          viewModel.selectPattern,
        );
      case DesignStep.selectingMaterial:
        return _buildOptionList(
          context,
          state.materialOptions,
          state.selectedMaterial,
          viewModel.selectMaterial,
        );
      case DesignStep.selectingStyle:
        return _buildOptionList(
          context,
          state.styleOptions,
          state.selectedStyle,
          viewModel.selectStyle,
        );
      case DesignStep.selectingAudience:
        return _buildOptionList(
          context,
          state.audienceOptions,
          state.selectedAudience,
          viewModel.selectAudience,
        );
      case DesignStep.selectingModel:
        return _buildOptionList(
          context,
          state.modelOptions,
          state.selectedModel,
          viewModel.selectModel,
        );
      default:
        return Center(
          child: Text(
            FlutterI18n.translate(context, 'design_flat.select_option_hint'),
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.grey400,
            ),
          ),
        );
    }
  }

  Widget _buildOptionList(
    BuildContext context,
    List<dynamic> options,
    String? selectedId,
    Function(String) onSelect,
  ) {
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option.id == selectedId;

        return InkWell(
          onTap: () => onSelect(option.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.grey50,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.grey200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option.name,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.grey800,
                      fontWeight: isSelected
                          ? AppFontWeight.semiBold
                          : AppFontWeight.regular,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    DesignFlatState state,
    DesignFlatViewModel viewModel,
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
              if (state.generatedImageUrl != null) ...[
                TextButton.icon(
                  onPressed: state.isGenerating ? null : viewModel.reset,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    FlutterI18n.translate(context, 'design_flat.reset'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton.icon(
                  onPressed: state.isGenerating ? null : viewModel.regenerate,
                  icon: const Icon(Icons.autorenew),
                  label: Text(
                    FlutterI18n.translate(context, 'design_flat.regenerate'),
                  ),
                ),
              ],
              const Spacer(),
              if (state.generatedImageUrl != null)
                ElevatedButton(
                  onPressed: () {
                    context.push(
                      RouteName.design3d,
                      extra: {
                        'flatDesignId': state.generatedDesignId,
                        'flatImageUrl': state.generatedImageUrl,
                      },
                    );
                  },
                  child: Text(
                    FlutterI18n.translate(context, 'design_flat.next_step'),
                  ),
                )
              else ...[
                OutlinedButton.icon(
                  onPressed: !state.isGenerating
                      ? viewModel.generateRandomDesign
                      : null,
                  icon: const Icon(Icons.shuffle),
                  label: Text(
                    FlutterI18n.translate(context, 'design_flat.random_generate'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: state.canGenerate && !state.isGenerating
                      ? viewModel.generateFlatDesign
                      : null,
                  child: state.isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          FlutterI18n.translate(context, 'design_flat.generate'),
                        ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
