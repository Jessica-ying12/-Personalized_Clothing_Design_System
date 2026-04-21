import '../../core/models/design_option_model.dart';

// 生成进度步骤
enum GenerateStep {
  idle,
  analyzing,   // 分析参数
  sketching,   // 生成草图
  refining,    // 优化细节
  rendering,   // 渲染输出
  done,
}

extension GenerateStepLabel on GenerateStep {
  String get label {
    switch (this) {
      case GenerateStep.idle: return '';
      case GenerateStep.analyzing: return '正在分析设计参数...';
      case GenerateStep.sketching: return '生成服装草图...';
      case GenerateStep.refining: return '优化细节与纹理...';
      case GenerateStep.rendering: return '渲染最终效果...';
      case GenerateStep.done: return '生成完成';
    }
  }

  double get progress {
    switch (this) {
      case GenerateStep.idle: return 0;
      case GenerateStep.analyzing: return 0.2;
      case GenerateStep.sketching: return 0.45;
      case GenerateStep.refining: return 0.7;
      case GenerateStep.rendering: return 0.9;
      case GenerateStep.done: return 1.0;
    }
  }
}

class DesignFlatState {
  const DesignFlatState({
    this.selectedPattern,
    this.selectedMaterial,
    this.selectedStyle,
    this.selectedAudience,
    this.selectedModel,
    this.selectedClothingType,
    this.selectedColor,
    this.isGenerating = false,
    this.isLoadingOptions = false,
    this.generatedImageUrl,
    this.generatedDesignId,
    this.regenerateCount = 0,
    this.currentStep = DesignStep.initial,
    this.generateStep = GenerateStep.idle,
    this.patternOptions = const [],
    this.materialOptions = const [],
    this.styleOptions = const [],
    this.audienceOptions = const [],
    this.modelOptions = const [],
    this.clothingTypeOptions = const [],
    this.colorOptions = const [],
    this.params = const {},
    this.errorMessage,
  });

  final String? selectedPattern;
  final String? selectedMaterial;
  final String? selectedStyle;
  final String? selectedAudience;
  final String? selectedModel;
  final String? selectedClothingType;
  final String? selectedColor;
  final bool isGenerating;
  final bool isLoadingOptions;
  final String? generatedImageUrl;
  final String? generatedDesignId;
  final int regenerateCount;
  final DesignStep currentStep;
  final GenerateStep generateStep;
  final List<DesignOptionModel> patternOptions;
  final List<DesignOptionModel> materialOptions;
  final List<DesignOptionModel> styleOptions;
  final List<DesignOptionModel> audienceOptions;
  final List<DesignOptionModel> modelOptions;
  final List<DesignOptionModel> clothingTypeOptions;
  final List<DesignOptionModel> colorOptions;
  final Map<String, dynamic> params;
  final String? errorMessage;

  bool get canGenerate =>
      selectedPattern != null &&
      selectedMaterial != null &&
      selectedStyle != null &&
      selectedAudience != null &&
      selectedModel != null &&
      selectedClothingType != null;
  // 颜色可选，不强制

  bool get canRegenerate => regenerateCount < 2;

  DesignFlatState copyWith({
    String? selectedPattern,
    String? selectedMaterial,
    String? selectedStyle,
    String? selectedAudience,
    String? selectedModel,
    String? selectedClothingType,
    String? selectedColor,
    bool? isGenerating,
    bool? isLoadingOptions,
    String? generatedImageUrl,
    String? generatedDesignId,
    int? regenerateCount,
    DesignStep? currentStep,
    GenerateStep? generateStep,
    List<DesignOptionModel>? patternOptions,
    List<DesignOptionModel>? materialOptions,
    List<DesignOptionModel>? styleOptions,
    List<DesignOptionModel>? audienceOptions,
    List<DesignOptionModel>? modelOptions,
    List<DesignOptionModel>? clothingTypeOptions,
    List<DesignOptionModel>? colorOptions,
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
      selectedColor: selectedColor ?? this.selectedColor,
      isGenerating: isGenerating ?? this.isGenerating,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
      generatedDesignId: generatedDesignId ?? this.generatedDesignId,
      regenerateCount: regenerateCount ?? this.regenerateCount,
      currentStep: currentStep ?? this.currentStep,
      generateStep: generateStep ?? this.generateStep,
      patternOptions: patternOptions ?? this.patternOptions,
      materialOptions: materialOptions ?? this.materialOptions,
      styleOptions: styleOptions ?? this.styleOptions,
      audienceOptions: audienceOptions ?? this.audienceOptions,
      modelOptions: modelOptions ?? this.modelOptions,
      clothingTypeOptions: clothingTypeOptions ?? this.clothingTypeOptions,
      colorOptions: colorOptions ?? this.colorOptions,
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
