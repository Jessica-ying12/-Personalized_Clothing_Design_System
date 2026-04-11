import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service_providers.dart';
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
        clothingTypeOptions:
            all.where((o) => o.category == 'clothing_type').toList(),
      );
    } catch (_) {
      state = state.copyWith(isLoadingOptions: false);
    }
  }

  void setStep(DesignStep step) => state = state.copyWith(currentStep: step);

  void selectPattern(String id) =>
      state = state.copyWith(selectedPattern: id, currentStep: DesignStep.initial);

  void selectMaterial(String id) =>
      state = state.copyWith(selectedMaterial: id, currentStep: DesignStep.initial);

  void selectStyle(String id) =>
      state = state.copyWith(selectedStyle: id, currentStep: DesignStep.initial);

  void selectAudience(String id) =>
      state = state.copyWith(selectedAudience: id, currentStep: DesignStep.initial);

  void selectModel(String id) =>
      state = state.copyWith(selectedModel: id, currentStep: DesignStep.initial);

  void selectClothingType(String id) =>
      state = state.copyWith(selectedClothingType: id, currentStep: DesignStep.initial);

  Future<void> generateFlatDesign() async {
    if (!state.canGenerate || state.isGenerating) return;
    state = state.copyWith(isGenerating: true, errorMessage: null);
    try {
      final result = await ref.read(flatDesignServiceProvider).generate(
            silhouetteId: state.selectedClothingType!,
            patternId: state.selectedPattern!,
            materialId: state.selectedMaterial!,
            styleId: state.selectedStyle!,
            audienceId: state.selectedAudience!,
            aiModelId: state.selectedModel!,
            params: state.params,
          );
      state = state.copyWith(
        isGenerating: false,
        generatedImageUrl: result.imageUrl,
        generatedDesignId: result.id,
      );
    } catch (e) {
      state = state.copyWith(isGenerating: false, errorMessage: e.toString());
    }
  }

  Future<void> generateRandomDesign() async {
    if (state.isGenerating) return;
    state = state.copyWith(isGenerating: true, errorMessage: null);
    try {
      final result = await ref.read(flatDesignServiceProvider).generateRandom();
      state = state.copyWith(
        isGenerating: false,
        generatedImageUrl: result.imageUrl,
        generatedDesignId: result.id,
      );
    } catch (e) {
      state = state.copyWith(isGenerating: false, errorMessage: e.toString());
    }
  }

  Future<void> regenerate() async {
    final designId = state.generatedDesignId;
    if (designId == null || state.isGenerating) return;
    state = state.copyWith(isGenerating: true, errorMessage: null);
    try {
      final result =
          await ref.read(flatDesignServiceProvider).regenerate(designId);
      state = state.copyWith(
        isGenerating: false,
        generatedImageUrl: result.imageUrl,
        regenerateCount: state.regenerateCount + 1,
      );
    } catch (e) {
      state = state.copyWith(isGenerating: false, errorMessage: e.toString());
    }
  }

  void reset() {
    state = const DesignFlatState();
    Future.microtask(() => _loadOptions());
  }
}

final designFlatViewModelProvider =
    NotifierProvider<DesignFlatViewModel, DesignFlatState>(
        DesignFlatViewModel.new);
