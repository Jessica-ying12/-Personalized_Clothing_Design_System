import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service_providers.dart';
import 'design_3d_state.dart';

class Design3dViewModel extends Notifier<Design3dState> {
  @override
  Design3dState build() => const Design3dState();

  Future<void> initialize(String flatDesignId, String? flatImageUrl) async {
    state = state.copyWith(
      flatDesignId: flatDesignId,
      flatImageUrl: flatImageUrl,
    );
    await _loadOptions();
  }

  Future<void> _loadOptions() async {
    state = state.copyWith(isLoadingOptions: true);
    try {
      final service = ref.read(designOptionsServiceProvider);
      final all = await service.getOptions();
      state = state.copyWith(
        isLoadingOptions: false,
        bodyTypeOptions: all.where((o) => o.category == 'body_type').toList(),
        skinToneOptions: all.where((o) => o.category == 'skin_tone').toList(),
        genderOptions: all.where((o) => o.category == 'gender').toList(),
        modelOptions: all.where((o) => o.category == 'ai_model').toList(),
        backgroundOptions:
            all.where((o) => o.category == 'background').toList(),
      );
    } catch (_) {
      state = state.copyWith(isLoadingOptions: false);
    }
  }

  void selectBodyType(String id) =>
      state = state.copyWith(selectedBodyType: id);
  void selectSkinTone(String id) =>
      state = state.copyWith(selectedSkinTone: id);
  void selectGender(String id) => state = state.copyWith(selectedGender: id);
  void selectModel(String id) => state = state.copyWith(selectedModel: id);
  void selectBackground(String id) =>
      state = state.copyWith(selectedBackground: id);

  void toggleView() => state = state.copyWith(showFlat: !state.showFlat);

  Future<void> generate3dDesign() async {
    if (!state.canGenerate || state.isGenerating) return;
    state = state.copyWith(isGenerating: true, errorMessage: null);
    try {
      final result = await ref.read(design3dServiceProvider).generate(
            flatDesignId: state.flatDesignId!,
            bodyShapeId: state.selectedBodyType!,
            skinColorId: state.selectedSkinTone!,
            genderId: state.selectedGender!,
            aiModelId: state.selectedModel!,
            backgroundId: state.selectedBackground!,
          );
      state = state.copyWith(
        isGenerating: false,
        generated3dImageUrl: result.imageUrl,
        generated3dDesignId: result.id,
        showFlat: false,
      );
    } catch (e) {
      state = state.copyWith(isGenerating: false, errorMessage: e.toString());
    }
  }

  Future<void> regenerate3d() async {
    final designId = state.generated3dDesignId;
    if (designId == null || state.isGenerating) return;
    state = state.copyWith(isGenerating: true, errorMessage: null);
    try {
      final result =
          await ref.read(design3dServiceProvider).regenerate(designId);
      state = state.copyWith(
        isGenerating: false,
        generated3dImageUrl: result.imageUrl,
        regenerateCount: state.regenerateCount + 1,
      );
    } catch (e) {
      state = state.copyWith(isGenerating: false, errorMessage: e.toString());
    }
  }

  Future<void> changeBackground() async {
    final designId = state.generated3dDesignId;
    final backgroundId = state.selectedBackground;
    if (designId == null || backgroundId == null || state.isGenerating) return;
    state = state.copyWith(isGenerating: true, errorMessage: null);
    try {
      final result = await ref.read(design3dServiceProvider).changeBackground(
            designId: designId,
            backgroundId: backgroundId,
          );
      state = state.copyWith(
        isGenerating: false,
        generated3dImageUrl: result.imageUrl,
      );
    } catch (e) {
      state = state.copyWith(isGenerating: false, errorMessage: e.toString());
    }
  }
}

final design3dViewModelProvider =
    NotifierProvider<Design3dViewModel, Design3dState>(Design3dViewModel.new);
