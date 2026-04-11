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
  final String silhouetteId;
  final String patternId;
  final String materialId;
  final String styleId;
  final String audienceId;
  final String aiModelId;
  final Map<String, dynamic>? params;
  final String? imageUrl;
  final String status; // pending, processing, done, failed
  final String? errorMsg;
  final int regenCount;
  final bool isSaved;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory FlatDesignModel.fromJson(Map<String, dynamic> json) {
    return FlatDesignModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      silhouetteId: json['silhouette_id'] as String? ?? '',
      patternId: json['pattern_id'] as String? ?? '',
      materialId: json['material_id'] as String? ?? '',
      styleId: json['style_id'] as String? ?? '',
      audienceId: json['audience_id'] as String? ?? '',
      aiModelId: json['ai_model_id'] as String? ?? '',
      params: json['params'] as Map<String, dynamic>?,
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String,
      errorMsg: json['error_msg'] as String?,
      regenCount: json['regen_count'] as int? ?? 0,
      isSaved: json['is_saved'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'silhouette_id': silhouetteId,
      'pattern_id': patternId,
      'material_id': materialId,
      'style_id': styleId,
      'audience_id': audienceId,
      'ai_model_id': aiModelId,
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
