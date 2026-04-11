class DesignOptionModel {
  const DesignOptionModel({
    required this.id,
    required this.category,
    this.parentId,
    required this.name,
    this.nameEn,
    this.sortOrder,
    this.meta,
    this.isActive = true,
  });

  final String id;
  final String category;
  final String? parentId;
  final String name;
  final String? nameEn;
  final int? sortOrder;
  final Map<String, dynamic>? meta;
  final bool isActive;

  factory DesignOptionModel.fromJson(Map<String, dynamic> json) {
    return DesignOptionModel(
      id: json['id'] as String,
      category: json['category'] as String,
      parentId: json['parent_id'] as String?,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      sortOrder: json['sort_order'] as int?,
      meta: json['meta'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'parent_id': parentId,
      'name': name,
      'name_en': nameEn,
      'sort_order': sortOrder,
      'meta': meta,
      'is_active': isActive,
    };
  }
}
