import '../../core/models/design_option_model.dart';

class DesignFlatState {
  const DesignFlatState({
    this.selectedPattern,
    this.selectedMaterial,
    this.selectedStyle,
    this.selectedAudience,
    this.selectedModel,
    this.selectedClothingType,
    this.isGenerating = false,
    this.isLoadingOptions = false,
    this.generatedImageUrl,
    this.generatedDesignId,
    this.regenerateCount = 0,
    this.currentStep = DesignStep.initial,
    this.patternOptions = const [],
    this.materialOptions = const [],
    this.styleOptions = const [],
    this.audienceOptions = const [],
    this.modelOptions = const [],
    this.clothingTypeOptions = const [],
    this.params = const {},
    this.errorMessage,
  });

  final String? selectedPattern;
  final String? selectedMaterial;
  final String? selectedStyle;
  final String? selectedAudience;
  final String? selectedModel;
  final String? selectedClothingType;
  final bool isGenerating;
  final bool isLoadingOptions;
  final String? generatedImageUrl;
  final String? generatedDesignId;
  final int regenerateCount;
  final DesignStep currentStep;
  final List<DesignOptionModel> patternOptions;
  final List<DesignOptionModel> materialOptions;
  final List<DesignOptionModel> styleOptions;
  final List<DesignOptionModel> audienceOptions;
  final List<DesignOptionModel> modelOptions;
  final List<DesignOptionModel> clothingTypeOptions;
  final Map<String, dynamic> params;
  final String? errorMessage;

  bool get canGenerate =>
      selectedPattern != null &&
      selectedMaterial != null &&
      selectedStyle != null &&
      selectedAudience != null &&
      selectedModel != null &&
      selectedClothingType != null;

  bool get canRegenerate => regenerateCount < 2;

  DesignFlatState copyWith({
    String? selectedPattern,
    String? selectedMaterial,
    String? selectedStyle,
    String? selectedAudience,
    String? selectedModel,
    String? selectedClothingType,
    bool? isGenerating,
    bool? isLoadingOptions,
    String? generatedImageUrl,
    String? generatedDesignId,
    int? regenerateCount,
    DesignStep? currentStep,
    List<DesignOptionModel>? patternOptions,
    List<DesignOptionModel>? materialOptions,
    List<DesignOptionModel>? styleOptions,
    List<DesignOptionModel>? audienceOptions,
    List<DesignOptionModel>? modelOptions,
    List<DesignOptionModel>? clothingTypeOptions,
    Map<String, dynamic>? params,
    String? errorMessage,
  }) {
    return DesignFlatState(
      selectedPattern: selectedPattern ?? this.selectedPattern,
      selectedMaterial: selectedMaterial ?? this.selectedMaterial,
      selectedStyle: selectedStyle ?? this.selectedStyle,
      selectedAudience: selectedAudience ?? this.selectedAudience,
      selectedModel: selectedModel ?? this.selectedModel,
      selectedClothingType: selectedClothingType ?? this.selectedClothingType,
      isGenerating: isGenerating ?? this.isGenerating,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
      generatedDesignId: generatedDesignId ?? this.generatedDesignId,
      regenerateCount: regenerateCount ?? this.regenerateCount,
      currentStep: currentStep ?? this.currentStep,
      patternOptions: patternOptions ?? this.patternOptions,
      materialOptions: materialOptions ?? this.materialOptions,
      styleOptions: styleOptions ?? this.styleOptions,
      audienceOptions: audienceOptions ?? this.audienceOptions,
      modelOptions: modelOptions ?? this.modelOptions,
      clothingTypeOptions: clothingTypeOptions ?? this.clothingTypeOptions,
      params: params ?? this.params,
      errorMessage: errorMessage,
    );
  }
}

enum DesignStep {
  initial,
  selectingPattern,
  selectingMaterial,
  selectingStyle,
  selectingAudience,
  selectingModel,
  selectingClothingType,
}
