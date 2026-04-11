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
    Map<String, dynamic>? params,
    bool autoSave = true,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.flatDesignApi}/generate',
      data: {
        'silhouette_id': silhouetteId,
        'pattern_id': patternId,
        'material_id': materialId,
        'style_id': styleId,
        'audience_id': audienceId,
        'ai_model_id': aiModelId,
        if (params != null) 'params': params,
        'auto_save': autoSave,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return FlatDesignModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<FlatDesignModel> generateRandom() async {
    final response = await _apiClient.post(
      '${AppConfig.flatDesignApi}/generate-random',
      data: {},
    );

    final data = response.data as Map<String, dynamic>;
    return FlatDesignModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<FlatDesignModel> regenerate(String designId) async {
    final response = await _apiClient.post(
      '${AppConfig.flatDesignApi}/regenerate',
      data: {'design_id': designId},
    );

    final data = response.data as Map<String, dynamic>;
    return FlatDesignModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '${AppConfig.flatDesignApi}/list',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List)
        .map((e) => FlatDesignModel.fromJson(e))
        .toList();

    return {
      'data': list,
      'total': data['total'],
      'page': data['page'],
      'page_size': data['page_size'],
    };
  }

  Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '${AppConfig.flatDesignApi}/history',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List)
        .map((e) => FlatDesignModel.fromJson(e))
        .toList();

    return {
      'data': list,
      'total': data['total'],
      'page': data['page'],
      'page_size': data['page_size'],
    };
  }

  Future<Map<String, dynamic>> getStatus(String designId) async {
    final response = await _apiClient.get(
      '${AppConfig.flatDesignApi}/status',
      queryParameters: {'design_id': designId},
    );

    return response.data as Map<String, dynamic>;
  }

  Future<FlatDesignModel> getDetail(String designId) async {
    final response = await _apiClient.get(
      '${AppConfig.flatDesignApi}/detail',
      queryParameters: {'design_id': designId},
    );

    final data = response.data as Map<String, dynamic>;
    return FlatDesignModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> remove(String designId) async {
    await _apiClient.delete(
      '${AppConfig.flatDesignApi}/remove',
      data: {'design_id': designId},
    );
  }

  Future<void> save(String designId) async {
    await _apiClient.post(
      '${AppConfig.flatDesignApi}/save',
      data: {'design_id': designId},
    );
  }

  Future<int> batchRemove(List<String> designIds) async {
    final response = await _apiClient.post(
      '${AppConfig.flatDesignApi}/batch-remove',
      data: {'design_ids': designIds},
    );
    final data = response.data as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }

  Future<int> batchSave(List<String> designIds) async {
    final response = await _apiClient.post(
      '${AppConfig.flatDesignApi}/batch-save',
      data: {'design_ids': designIds},
    );
    final data = response.data as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }
}
