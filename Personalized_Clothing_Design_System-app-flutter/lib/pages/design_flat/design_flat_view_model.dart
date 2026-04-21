import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service_providers.dart';
import '../profile/profile_view_model.dart';
import 'design_flat_state.dart';

class DesignFlatViewModel extends Notifier<DesignFlatState> {
  @override
  DesignFlatState build() {
    Future.microtask(() => _loadOptions());
    return const DesignFlatState();
  }

  Future<void> _loadOptions() async {
    state = state.copyWith(isLoadingOptions: true);
    try {
      final service = ref.read(designOptionsServiceProvider);
      final all = await service.getOptions();
      state = state.copyWith(
        isLoadingOptions: false,
        patternOptions: all.where((o) => o.category == 'pattern').toList(),
        materialOptions: all.where((o) => o.category == 'material').toList(),
        styleOptions: all.where((o) => o.category == 'style').toList(),
        audienceOptions: all.where((o) => o.category == 'audience').toList(),
        modelOptions: all.where((o) => o.category == 'ai_model').toList(),
        clothingTypeOptions: all.where((o) => o.category == 'clothing_type').toList(),
        colorOptions: all.where((o) => o.category == 'color').toList(),
      );
    } catch (_) {
      state = state.copyWith(isLoadingOptions: false);
    }
  }

  void setStep(DesignStep step) => state = state.copyWith(currentStep: step);
  void selectPattern(String id) => state = state.copyWith(selectedPattern: id, currentStep: DesignStep.initial);
  void selectMaterial(String id) => state = state.copyWith(selectedMaterial: id, currentStep: DesignStep.initial);
  void selectStyle(String id) => state = state.copyWith(selectedStyle: id, currentStep: DesignStep.initial);
  void selectAudience(String id) => state = state.copyWith(selectedAudience: id, currentStep: DesignStep.initial);
  void selectModel(String id) => state = state.copyWith(selectedModel: id, currentStep: DesignStep.initial);
  void selectClothingType(String id) => state = state.copyWith(selectedClothingType: id, currentStep: DesignStep.initial);
  void selectColor(String id) => state = state.copyWith(selectedColor: id, currentStep: DesignStep.initial);

  void updateParams(Map<String, dynamic> params) =>
      state = state.copyWith(params: params);

  Future<void> generateFlatDesign() async {
    if (!state.canGenerate || state.isGenerating) return;
    state = state.copyWith(isGenerating: true, errorMessage: null, generateStep: GenerateStep.analyzing);
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      state = state.copyWith(generateStep: GenerateStep.sketching);
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(generateStep: GenerateStep.refining);
      await Future.delayed(const Duration(milliseconds: 700));
      state = state.copyWith(generateStep: GenerateStep.rendering);

      final result = await ref.read(flatDesignServiceProvider).generate(
        silhouetteId: state.selectedClothingType!,
        patternId: state.selectedPattern!,
        materialId: state.selectedMaterial!,
        styleId: state.selectedStyle!,
        audienceId: state.selectedAudience!,
        aiModelId: state.selectedModel!,
        colorId: state.selectedColor,
        params: state.params,
      );
      state = state.copyWith(
        isGenerating: false,
        generateStep: GenerateStep.done,
        generatedImageUrl: result.imageUrl,
        generatedDesignId: result.id,
      );
      // 生成后刷新统计
      _notifyProfileRefresh();
    } catch (e) {
      state = state.copyWith(isGenerating: false, generateStep: GenerateStep.idle, errorMessage: e.toString());
    }
  }

  Future<void> generateRandomDesign() async {
    if (state.isGenerating) return;
    state = state.copyWith(isGenerating: true, errorMessage: null, generateStep: GenerateStep.analyzing);
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(generateStep: GenerateStep.sketching);
      await Future.delayed(const Duration(milliseconds: 700));
      state = state.copyWith(generateStep: GenerateStep.refining);
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(generateStep: GenerateStep.rendering);

      final result = await ref.read(flatDesignServiceProvider).generateRandom();
      // 回填随机选择的参数，让 chip 行显示正确内容
      state = state.copyWith(
        isGenerating: false,
        generateStep: GenerateStep.done,
        generatedImageUrl: result.model.imageUrl,
        generatedDesignId: result.model.id,
        selectedClothingType: result.silhouetteId,
        selectedPattern: result.patternId,
        selectedMaterial: result.materialId,
        selectedStyle: result.styleId,
        selectedAudience: result.audienceId,
        selectedModel: 'ai_standard',
      );
      _notifyProfileRefresh();
    } catch (e) {
      state = state.copyWith(isGenerating: false, generateStep: GenerateStep.idle, errorMessage: e.toString());
    }
  }

  Future<void> regenerate() async {
    final designId = state.generatedDesignId;
    if (designId == null || state.isGenerating) return;
    state = state.copyWith(isGenerating: true, errorMessage: null, generateStep: GenerateStep.analyzing);
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(generateStep: GenerateStep.sketching);
      await Future.delayed(const Duration(milliseconds: 700));
      state = state.copyWith(generateStep: GenerateStep.rendering);

      final result = await ref.read(flatDesignServiceProvider).regenerate(designId);
      state = state.copyWith(
        isGenerating: false,
        generateStep: GenerateStep.done,
        generatedImageUrl: result.imageUrl,
        regenerateCount: state.regenerateCount + 1,
      );
    } catch (e) {
      state = state.copyWith(isGenerating: false, generateStep: GenerateStep.idle, errorMessage: e.toString());
    }
  }

  /// 通知 profile 页刷新统计数据
  void _notifyProfileRefresh() {
    try {
      ref.read(profileViewModelProvider.notifier).refreshStats();
    } catch (_) {}
  }

  void reset() {
    state = const DesignFlatState();
    Future.microtask(() => _loadOptions());
  }
}

final designFlatViewModelProvider =
    NotifierProvider<DesignFlatViewModel, DesignFlatState>(DesignFlatViewModel.new);
