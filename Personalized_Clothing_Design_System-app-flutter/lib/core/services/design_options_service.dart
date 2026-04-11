import '../api/api_client.dart';
import '../config/app_config.dart';
import '../models/design_option_model.dart';

class DesignOptionsService {
  final ApiClient _apiClient;

  DesignOptionsService(this._apiClient);

  Future<List<DesignOptionModel>> getOptions({String? category}) async {
    final response = await _apiClient.get(
      '${AppConfig.designOptionsApi}/options',
      queryParameters: category != null ? {'category': category} : null,
    );

    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List;
    return list.map((e) => DesignOptionModel.fromJson(e)).toList();
  }

  Future<List<DesignOptionModel>> getChildren(String parentId) async {
    final response = await _apiClient.get(
      '${AppConfig.designOptionsApi}/options/children',
      queryParameters: {'parent_id': parentId},
    );

    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List;
    return list.map((e) => DesignOptionModel.fromJson(e)).toList();
  }
}
