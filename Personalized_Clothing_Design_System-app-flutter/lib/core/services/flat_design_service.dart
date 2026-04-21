import '../api/api_client.dart';
import '../config/app_config.dart';
import '../models/flat_design_model.dart';

class FlatDesignService {
  final ApiClient _apiClient;

  FlatDesignService(this._apiClient);

  Future<FlatDesignModel> generate({
    required String silhouetteId,
    required String patternId,
    required String materialId,
    required String styleId,
    required String audienceId,
    required String aiModelId,
    String? colorId,
    Map<String, dynamic>? params,
    bool autoSave = true,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.flatDesignApi}/generate',
      data: {
        'clothing_type_code': silhouetteId,
        'pattern_code': patternId,
        'material_code': materialId,
        'style_code': styleId,
        'audience_code': audienceId,
        'ai_model_code': aiModelId,
        if (colorId != null) 'color_code': colorId,
        if (params != null) 'params': params,
      },
    );

    final resp = response.data as Map<String, dynamic>;
    return FlatDesignModel.fromJson(resp['data'] as Map<String, dynamic>);
  }

  Future<({FlatDesignModel model, String silhouetteId, String patternId, String materialId, String styleId, String audienceId})> generateRandom() async {
    final response = await _apiClient.post(
      '${AppConfig.flatDesignApi}/generate-random',
      data: {},
    );

    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    final model = FlatDesignModel.fromJson(data['model'] as Map<String, dynamic>);
    return (
      model: model,
      silhouetteId: data['clothing_type_code'] as String,
      patternId: data['pattern_code'] as String,
      materialId: data['material_code'] as String,
      styleId: data['style_code'] as String,
      audienceId: data['audience_code'] as String,
    );
  }

  Future<FlatDesignModel> regenerate(String designId) async {
    final response = await _apiClient.post(
      '${AppConfig.flatDesignApi}/regenerate/$designId',
      data: {},
    );

    final resp = response.data as Map<String, dynamic>;
    return FlatDesignModel.fromJson(resp['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getList({int page = 1, int pageSize = 20}) async {
    final response = await _apiClient.get(
      '${AppConfig.flatDesignApi}/list',
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    final list = (data['data'] as List)
        .map((e) => FlatDesignModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return {'data': list, 'total': data['total'], 'page': data['page'], 'page_size': data['page_size']};
  }

  Future<Map<String, dynamic>> getHistory({int page = 1, int pageSize = 20}) async {
    final response = await _apiClient.get(
      '${AppConfig.flatDesignApi}/history',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    final list = (data['data'] as List)
        .map((e) => FlatDesignModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return {'data': list, 'total': data['total'], 'page': data['page'], 'page_size': data['page_size']};
  }

  Future<Map<String, dynamic>> getStatus(String designId) async => {'status': 'done'};

  Future<FlatDesignModel> getDetail(String designId) async {
    final response = await _apiClient.get('${AppConfig.flatDesignApi}/detail/$designId');
    final resp = response.data as Map<String, dynamic>;
    return FlatDesignModel.fromJson(resp['data'] as Map<String, dynamic>);
  }

  /// 从仓库移除（软删除，is_saved=0）
  Future<void> remove(String designId) async {
    await _apiClient.delete('${AppConfig.flatDesignApi}/remove/$designId');
  }

  /// 从历史记录彻底删除
  Future<void> historyRemove(String designId) async {
    await _apiClient.delete('${AppConfig.flatDesignApi}/history-remove/$designId');
  }

  Future<void> save(String designId) async {
    await _apiClient.post('${AppConfig.flatDesignApi}/save/$designId', data: {});
  }

  Future<int> batchRemove(List<String> designIds) async {
    final response = await _apiClient.post(
      '${AppConfig.flatDesignApi}/batch-remove',
      data: {'ids': designIds},
    );
    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }

  Future<int> batchSave(List<String> designIds) async => designIds.length;
}
