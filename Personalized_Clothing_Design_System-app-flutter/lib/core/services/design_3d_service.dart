import '../api/api_client.dart';
import '../config/app_config.dart';
import '../models/design_3d_model.dart';

class Design3dService {
  final ApiClient _apiClient;

  Design3dService(this._apiClient);

  Future<Design3dModel> generate({
    required String flatDesignId,
    required String bodyShapeId,
    required String skinColorId,
    required String genderId,
    required String aiModelId,
    required String backgroundId,
    bool autoSave = true,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.design3dApi}/generate',
      data: {
        'flat_design_id': flatDesignId,
        'body_shape_id': bodyShapeId,
        'skin_color_id': skinColorId,
        'gender_id': genderId,
        'ai_model_id': aiModelId,
        'background_id': backgroundId,
        'auto_save': autoSave,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return Design3dModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Design3dModel> regenerate(String designId) async {
    final response = await _apiClient.post(
      '${AppConfig.design3dApi}/regenerate',
      data: {'design_id': designId},
    );

    final data = response.data as Map<String, dynamic>;
    return Design3dModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Design3dModel> changeBackground({
    required String designId,
    required String backgroundId,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.design3dApi}/background',
      data: {
        'design_id': designId,
        'background_id': backgroundId,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return Design3dModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '${AppConfig.design3dApi}/list',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List)
        .map((e) => Design3dModel.fromJson(e))
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
      '${AppConfig.design3dApi}/history',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List)
        .map((e) => Design3dModel.fromJson(e))
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
      '${AppConfig.design3dApi}/status',
      queryParameters: {'design_id': designId},
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Design3dModel> getDetail(String designId) async {
    final response = await _apiClient.get(
      '${AppConfig.design3dApi}/detail',
      queryParameters: {'design_id': designId},
    );

    final data = response.data as Map<String, dynamic>;
    return Design3dModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> remove(String designId) async {
    await _apiClient.delete(
      '${AppConfig.design3dApi}/remove',
      data: {'design_id': designId},
    );
  }

  Future<void> save(String designId) async {
    await _apiClient.post(
      '${AppConfig.design3dApi}/save',
      data: {'design_id': designId},
    );
  }

  Future<int> batchRemove(List<String> designIds) async {
    final response = await _apiClient.post(
      '${AppConfig.design3dApi}/batch-remove',
      data: {'design_ids': designIds},
    );
    final data = response.data as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }

  Future<int> batchSave(List<String> designIds) async {
    final response = await _apiClient.post(
      '${AppConfig.design3dApi}/batch-save',
      data: {'design_ids': designIds},
    );
    final data = response.data as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }
}
