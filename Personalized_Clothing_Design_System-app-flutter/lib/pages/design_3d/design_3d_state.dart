import '../../core/models/design_option_model.dart';

class Design3dState {
  const Design3dState({
    this.flatImageUrl,
    this.flatDesignId,
    this.selectedBodyType,
    this.selectedSkinTone,
    this.selectedGender,
    this.selectedModel,
    this.selectedBackground,
    this.isGenerating = false,
    this.isLoadingOptions = false,
    this.generated3dImageUrl,
    this.generated3dDesignId,
    this.regenerateCount = 0,
    this.showFlat = false,
    this.bodyTypeOptions = const [],
    this.skinToneOptions = const [],
    this.genderOptions = const [],
    this.modelOptions = const [],
    this.backgroundOptions = const [],
    this.errorMessage,
  });

  final String? flatImageUrl;
  final String? flatDesignId;
  final String? selectedBodyType;
  final String? selectedSkinTone;
  final String? selectedGender;
  final String? selectedModel;
  final String? selectedBackground;
  final bool isGenerating;
  final bool isLoadingOptions;
  final String? generated3dImageUrl;
  final String? generated3dDesignId;
  final int regenerateCount;
  final bool showFlat;
  final List<DesignOptionModel> bodyTypeOptions;
  final List<DesignOptionModel> skinToneOptions;
  final List<DesignOptionModel> genderOptions;
  final List<DesignOptionModel> modelOptions;
  final List<DesignOptionModel> backgroundOptions;
  final String? errorMessage;

  bool get canGenerate =>
      flatDesignId != null &&
      selectedBodyType != null &&
      selectedSkinTone != null &&
      selectedGender != null &&
      selectedModel != null &&
      selectedBackground != null;

  bool get canRegenerate => regenerateCount < 1;

  Design3dState copyWith({
    String? flatImageUrl,
    String? flatDesignId,
    String? selectedBodyType,
    String? selectedSkinTone,
    String? selectedGender,
    String? selectedModel,
    String? selectedBackground,
    bool? isGenerating,
    bool? isLoadingOptions,
    String? generated3dImageUrl,
    String? generated3dDesignId,
    int? regenerateCount,
    bool? showFlat,
    List<DesignOptionModel>? bodyTypeOptions,
    List<DesignOptionModel>? skinToneOptions,
    List<DesignOptionModel>? genderOptions,
    List<DesignOptionModel>? modelOptions,
    List<DesignOptionModel>? backgroundOptions,
    String? errorMessage,
  }) {
    return Design3dState(
      flatImageUrl: flatImageUrl ?? this.flatImageUrl,
      flatDesignId: flatDesignId ?? this.flatDesignId,
      selectedBodyType: selectedBodyType ?? this.selectedBodyType,
      selectedSkinTone: selectedSkinTone ?? this.selectedSkinTone,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedModel: selectedModel ?? this.selectedModel,
      selectedBackground: selectedBackground ?? this.selectedBackground,
      isGenerating: isGenerating ?? this.isGenerating,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
      generated3dImageUrl: generated3dImageUrl ?? this.generated3dImageUrl,
      generated3dDesignId: generated3dDesignId ?? this.generated3dDesignId,
      regenerateCount: regenerateCount ?? this.regenerateCount,
      showFlat: showFlat ?? this.showFlat,
      bodyTypeOptions: bodyTypeOptions ?? this.bodyTypeOptions,
      skinToneOptions: skinToneOptions ?? this.skinToneOptions,
      genderOptions: genderOptions ?? this.genderOptions,
      modelOptions: modelOptions ?? this.modelOptions,
      backgroundOptions: backgroundOptions ?? this.backgroundOptions,
      errorMessage: errorMessage,
    );
  }
}
