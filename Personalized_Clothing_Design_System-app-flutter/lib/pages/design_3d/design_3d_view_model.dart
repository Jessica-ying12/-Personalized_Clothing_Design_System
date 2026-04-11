import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service_providers.dart';
import 'design_3d_state.dart';

class Design3dViewModel extends Notifier<Design3dState> {
  @override
  Design3dState build() {
    loadOptions();
    return const Design3dState();
  }

  Future<void> loadOptions() async {
    state = state.copyWith(isLoadingOptions: true);

    try {
      final service = ref.read(designOptionsServiceProvider);

      final bodyTypeOptions = await service.getOptions(category: 'body_shape');
      final skinToneOptions = await service.getOptions(category: 'skin_color');
      final genderOptions = await service.getOptions(category: 'gender');
      final modelOptions = await service.getOptions(category: 'ai_model');
      final backgroundOptions = await service.getOptions(category: 'background');

      state = state.copyWith(
        isLoadingOptions: false,
        bodyTypeOptions: bodyTypeOptions,
        skinToneOptions: skinToneOptions,
        genderOptions: genderOptions,
        modelOptions: modelOptions,
        backgroundOptions: backgroundOptions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingOptions: false,
        errorMessage: e.toString(),
      );
    }
  }

  void initialize(String flatDesignId, String? flatImageUrl) {
    state = state.copyWith(
      flatDesignId: flatDesignId,
      flatImageUrl: flatImageUrl,
    );
  }

  void selectBodyType(String bodyTypeId) {
    state = state.copyWith(
      selectedBodyType: bodyTypeId,
      errorMessage: null,
    );
  }

  void selectSkinTone(String skinToneId) {
    state = state.copyWith(
      selectedSkinTone: skinToneId,
      errorMessage: null,
    );
  }

  void selectGender(String genderId) {
    state = state.copyWith(
      selectedGender: genderId,
      errorMessage: null,
    );
  }

  void selectModel(String modelId) {
    state = state.copyWith(
      selectedModel: modelId,
      errorMessage: null,
    );
  }

  void selectBackground(String backgroundId) {
    state = state.copyWith(
      selectedBackground: backgroundId,
      errorMessage: null,
    );
  }

  Future<void> changeBackground() async {
    if (state.generated3dDesignId == null || state.selectedBackground == null) {
      return;
    }

    // 循环切换到下一个背�?
    final currentIndex = state.backgroundOptions
        .indexWhere((o) => o.id == state.selectedBackground);
    final nextIndex = (currentIndex + 1) % state.backgroundOptions.length;
    final nextBackground = state.backgroundOptions[nextIndex];

    state = state.copyWith(isGenerating: true, errorMessage: null);

    try {
      final service = ref.read(design3dServiceProvider);
      final design = await service.changeBackground(
        designId: state.generated3dDesignId!,
        backgroundId: nextBackground.id,
      );

      await _pollGenerationStatus(design.id);
      
      state = state.copyWith(selectedBackground: nextBackground.id);
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: e.toString(),
      );
    }
  }

  void toggleView() {
    state = state.copyWith(showFlat: !state.showFlat);
  }

  Future<void> generate3dDesign() async {
    if (!state.canGenerate) return;

    state = state.copyWith(isGenerating: true, errorMessage: null);

    try {
      final service = ref.read(design3dServiceProvider);
      final design = await service.generate(
        flatDesignId: state.flatDesignId!,
        bodyShapeId: state.selectedBodyType!,
        skinColorId: state.selectedSkinTone!,
        genderId: state.selectedGender!,
        aiModelId: state.selectedModel!,
        backgroundId: state.selectedBackground!,
      );

      await _pollGenerationStatus(design.id);
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _pollGenerationStatus(String designId) async {
    final service = ref.read(design3dServiceProvider);

    while (true) {
      await Future.delayed(const Duration(seconds: 2));

      try {
        final status = await service.getStatus(designId);

        if (status['status'] == 'done') {
          state = state.copyWith(
            isGenerating: false,
            generated3dImageUrl: status['image_url'] as String?,
            generated3dDesignId: designId,
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

  Future<void> regenerate3d() async {
    if (!state.canRegenerate || state.generated3dDesignId == null) return;

    state = state.copyWith(isGenerating: true, errorMessage: null);

    try {
      final service = ref.read(design3dServiceProvider);
      final design = await service.regenerate(state.generated3dDesignId!);

      await _pollGenerationStatus(design.id);
      
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
}

final design3dViewModelProvider =
    NotifierProvider<Design3dViewModel, Design3dState>(Design3dViewModel.new);
