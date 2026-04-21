import '../api/api_client.dart';
import '../config/app_config.dart';
import '../models/design_option_model.dart';

class DesignOptionsService {
  final ApiClient _apiClient;

  DesignOptionsService(this._apiClient);

  Future<List<DesignOptionModel>> getOptions({String? category}) async {
    final response = await _apiClient.get(
      '${AppConfig.designOptionsApi}/list',
      queryParameters: category != null ? {'category': category} : null,
    );

    final resp = response.data as Map<String, dynamic>;
    final list = resp['data'] as List;
    return list.map((e) => DesignOptionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DesignOptionModel>> getChildren(String parentId) async {
    final response = await _apiClient.get(
      '${AppConfig.designOptionsApi}/children/$parentId',
    );

    final resp = response.data as Map<String, dynamic>;
    final list = resp['data'] as List;
    return list.map((e) => DesignOptionModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
