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
  final String bodyShapeId;
  final String skinColorId;
  final String genderId;
  final String aiModelId;
  final String backgroundId;
  final String? imageUrl;
  final String status; // pending, processing, done, failed
  final String? errorMsg;
  final int regenCount;
  final bool isSaved;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Design3dModel.fromJson(Map<String, dynamic> json) {
    return Design3dModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      flatDesignId: json['flat_design_id'] as String,
      bodyShapeId: json['body_shape_id'] as String,
      skinColorId: json['skin_color_id'] as String,
      genderId: json['gender_id'] as String,
      aiModelId: json['ai_model_id'] as String,
      backgroundId: json['background_id'] as String,
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
      'flat_design_id': flatDesignId,
      'body_shape_id': bodyShapeId,
      'skin_color_id': skinColorId,
      'gender_id': genderId,
      'ai_model_id': aiModelId,
      'background_id': backgroundId,
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
