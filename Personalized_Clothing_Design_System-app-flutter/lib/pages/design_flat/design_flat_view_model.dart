import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service_providers.dart';
import 'design_flat_state.dart';

class DesignFlatViewModel extends Notifier<DesignFlatState> {
  @override
  DesignFlatState build() {
    loadOptions();
    return const DesignFlatState();
  }

  Future<void> loadOptions() async {
    state = state.copyWith(isLoadingOptions: true);

    try {
      final service = ref.read(designOptionsServiceProvider);

      final patternOptions = await service.getOptions(category: 'pattern');
      final materialOptions = await service.getOptions(category: 'material');
      final styleOptions = await service.getOptions(category: 'style');
      final audienceOptions = await service.getOptions(category: 'audience');
      final modelOptions = await service.getOptions(category: 'ai_model');
      final clothingTypeOptions = await service.getOptions(category: 'silhouette');

      state = state.copyWith(
        isLoadingOptions: false,
        patternOptions: patternOptions,
        materialOptions: materialOptions,
        styleOptions: styleOptions,
        audienceOptions: audienceOptions,
        modelOptions: modelOptions,
        clothingTypeOptions: clothingTypeOptions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingOptions: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectPattern(String patternId) {
    state = state.copyWith(
      selectedPattern: patternId,
      currentStep: DesignStep.initial,
      errorMessage: null,
    );
  }

  void selectMaterial(String materialId) {
    state = state.copyWith(
      selectedMaterial: materialId,
      currentStep: DesignStep.initial,
      errorMessage: null,
    );
  }

  void selectStyle(String styleId) {
    state = state.copyWith(
      selectedStyle: styleId,
      currentStep: DesignStep.initial,
      errorMessage: null,
    );
  }

  void selectAudience(String audienceId) {
    state = state.copyWith(
      selectedAudience: audienceId,
      currentStep: DesignStep.initial,
      errorMessage: null,
    );
  }

  void selectModel(String modelId) {
    state = state.copyWith(
      selectedModel: modelId,
      currentStep: DesignStep.initial,
      errorMessage: null,
    );
  }

  void selectClothingType(String typeId) {
    state = state.copyWith(
      selectedClothingType: typeId,
      currentStep: DesignStep.initial,
      errorMessage: null,
    );
  }

  void setStep(DesignStep step) {
    state = state.copyWith(currentStep: step);
  }

  void updateParams(Map<String, dynamic> params) {
    state = state.copyWith(params: {...state.params, ...params});
  }

  Future<void> generateFlatDesign() async {
    if (!state.canGenerate) return;

    state = state.copyWith(isGenerating: true, errorMessage: null);

    try {
      final service = ref.read(flatDesignServiceProvider);
      final design = await service.generate(
        silhouetteId: state.selectedClothingType!,
        patternId: state.selectedPattern!,
        materialId: state.selectedMaterial!,
        styleId: state.selectedStyle!,
        audienceId: state.selectedAudience!,
        aiModelId: state.selectedModel!,
        params: state.params.isNotEmpty ? state.params : null,
      );

      // 轮询检查生成状�?
      await _pollGenerationStatus(design.id);
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _pollGenerationStatus(String designId) async {
    final service = ref.read(flatDesignServiceProvider);

    while (true) {
      await Future.delayed(const Duration(seconds: 2));

      try {
        final status = await service.getStatus(designId);

        if (status['status'] == 'done') {
          state = state.copyWith(
            isGenerating: false,
            generatedImageUrl: status['image_url'] as String?,
            generatedDesignId: designId,
          );
          break;
        } else if (status['status'] == 'failed') {
          state = state.copyWith(
            isGenerating: false,
            errorMessage: status['error_msg'] as String? ?? '生成失败',
          );
          break;
        }
      } catch (e) {
        state = state.copyWith(
          isGenerating: false,
          errorMessage: e.toString(),
        );
        break;
      }
    }
  }

  Future<void> regenerate() async {
    if (state.generatedDesignId == null || !state.canRegenerate) return;

    state = state.copyWith(isGenerating: true, errorMessage: null);

    try {
      final service = ref.read(flatDesignServiceProvider);
      final design = await service.regenerate(state.generatedDesignId!);

      await _pollGenerationStatus(design.id);
      
      // 更新重新生成次数
      state = state.copyWith(
        regenerateCount: state.regenerateCount + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> generateRandomDesign() async {
    state = state.copyWith(isGenerating: true, errorMessage: null);

    try {
      final service = ref.read(flatDesignServiceProvider);
      final design = await service.generateRandom();

      // 轮询检查生成状�?
      await _pollGenerationStatus(design.id);
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const DesignFlatState();
    loadOptions();
  }
}

final designFlatViewModelProvider =
    NotifierProvider<DesignFlatViewModel, DesignFlatState>(
  DesignFlatViewModel.new,
);
