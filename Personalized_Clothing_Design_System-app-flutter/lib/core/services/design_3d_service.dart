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
    String? tryOnImageUrl,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.design3dApi}/generate',
      data: {
        'flat_design_id': flatDesignId,
        'body_type_code': bodyShapeId,
        'skin_tone_code': skinColorId,
        'gender_code': genderId,
        'ai_model_code': aiModelId,
        'background_code': backgroundId,
      },
    );

    final resp = response.data as Map<String, dynamic>;
    return Design3dModel.fromJson(resp['data'] as Map<String, dynamic>);
  }

  Future<Design3dModel> regenerate(String designId) async {
    final response = await _apiClient.post(
      '${AppConfig.design3dApi}/regenerate/$designId',
      data: {},
    );

    final resp = response.data as Map<String, dynamic>;
    return Design3dModel.fromJson(resp['data'] as Map<String, dynamic>);
  }

  Future<Design3dModel> changeBackground({
    required String designId,
    required String backgroundId,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.design3dApi}/change-background',
      data: {'design_id': designId, 'background_code': backgroundId},
    );

    final resp = response.data as Map<String, dynamic>;
    return Design3dModel.fromJson(resp['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getList({int page = 1, int pageSize = 20}) async {
    final response = await _apiClient.get(
      '${AppConfig.design3dApi}/list',
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    final list = (data['data'] as List)
        .map((e) => Design3dModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return {'data': list, 'total': data['total'], 'page': data['page'], 'page_size': data['page_size']};
  }

  Future<Map<String, dynamic>> getHistory({int page = 1, int pageSize = 20}) async {
    final response = await _apiClient.get(
      '${AppConfig.design3dApi}/history',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    final list = (data['data'] as List)
        .map((e) => Design3dModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return {'data': list, 'total': data['total'], 'page': data['page'], 'page_size': data['page_size']};
  }

  Future<Map<String, dynamic>> getStatus(String designId) async => {'status': 'done'};

  Future<Design3dModel> getDetail(String designId) async {
    final response = await _apiClient.get('${AppConfig.design3dApi}/detail/$designId');
    final resp = response.data as Map<String, dynamic>;
    return Design3dModel.fromJson(resp['data'] as Map<String, dynamic>);
  }

  /// 从仓库移除（软删除，is_saved=0）
  Future<void> remove(String designId) async {
    await _apiClient.delete('${AppConfig.design3dApi}/remove/$designId');
  }

  /// 从历史记录彻底删除
  Future<void> historyRemove(String designId) async {
    await _apiClient.delete('${AppConfig.design3dApi}/history-remove/$designId');
  }

  Future<void> save(String designId) async {
    await _apiClient.post('${AppConfig.design3dApi}/save/$designId', data: {});
  }

  Future<int> batchRemove(List<String> designIds) async {
    final response = await _apiClient.post(
      '${AppConfig.design3dApi}/batch-remove',
      data: {'ids': designIds},
    );
    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }

  Future<int> batchSave(List<String> designIds) async => designIds.length;
}
