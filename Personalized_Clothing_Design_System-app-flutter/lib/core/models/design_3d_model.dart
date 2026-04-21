class Design3dModel {
  const Design3dModel({
    required this.id,
    required this.userId,
    required this.flatDesignId,
    required this.bodyShapeId,
    required this.skinColorId,
    required this.genderId,
    required this.aiModelId,
    required this.backgroundId,
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
  final String flatDesignId;
  final String bodyShapeId;   // 对应后端 body_type_code
  final String skinColorId;   // 对应后端 skin_tone_code
  final String genderId;      // 对应后端 gender_code
  final String aiModelId;     // 对应后端 ai_model_code
  final String backgroundId;  // 对应后端 background_code
  final String? imageUrl;
  final String status;
  final String? errorMsg;
  final int regenCount;
  final bool isSaved;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Design3dModel.fromJson(Map<String, dynamic> json) {
    return Design3dModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      flatDesignId: json['flat_design_id']?.toString() ?? '',
      // 后端统一使用 *_code 字段名
      bodyShapeId: (json['body_type_code'] ?? '') as String,
      skinColorId: (json['skin_tone_code'] ?? '') as String,
      genderId: (json['gender_code'] ?? '') as String,
      aiModelId: (json['ai_model_code'] ?? '') as String,
      backgroundId: (json['background_code'] ?? '') as String,
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
      'flat_design_id': flatDesignId,
      'body_type_code': bodyShapeId,
      'skin_tone_code': skinColorId,
      'gender_code': genderId,
      'ai_model_code': aiModelId,
      'background_code': backgroundId,
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
