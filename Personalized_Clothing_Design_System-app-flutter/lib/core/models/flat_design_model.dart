class FlatDesignModel {
  const FlatDesignModel({
    required this.id,
    required this.userId,
    required this.silhouetteId,
    required this.patternId,
    required this.materialId,
    required this.styleId,
    required this.audienceId,
    required this.aiModelId,
    this.colorId,
    this.params,
    this.imageUrl,
    required this.status,
    this.errorMsg,
    this.regenCount = 0,
    this.isSaved = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String silhouetteId;   // 对应后端 clothing_type_code
  final String patternId;      // 对应后端 pattern_code
  final String materialId;     // 对应后端 material_code
  final String styleId;        // 对应后端 style_code
  final String audienceId;     // 对应后端 audience_code
  final String aiModelId;      // 对应后端 ai_model_code
  final String? colorId;       // 对应后端 color_code
  final Map<String, dynamic>? params;
  final String? imageUrl;
  final String status;
  final String? errorMsg;
  final int regenCount;
  final bool isSaved;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory FlatDesignModel.fromJson(Map<String, dynamic> json) {
    return FlatDesignModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      silhouetteId: (json['clothing_type_code'] ?? '') as String,
      patternId: (json['pattern_code'] ?? '') as String,
      materialId: (json['material_code'] ?? '') as String,
      styleId: (json['style_code'] ?? '') as String,
      audienceId: (json['audience_code'] ?? '') as String,
      aiModelId: (json['ai_model_code'] ?? '') as String,
      colorId: json['color_code'] as String?,
      params: json['params'] as Map<String, dynamic>?,
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'done',
      errorMsg: json['error_msg'] as String?,
      regenCount: json['regen_count'] as int? ?? 0,
      isSaved: json['is_saved'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'clothing_type_code': silhouetteId,
      'pattern_code': patternId,
      'material_code': materialId,
      'style_code': styleId,
      'audience_code': audienceId,
      'ai_model_code': aiModelId,
      'color_code': colorId,
      'params': params,
      'image_url': imageUrl,
      'status': status,
      'error_msg': errorMsg,
      'regen_count': regenCount,
      'is_saved': isSaved,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
