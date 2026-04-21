import '../api/api_client.dart';
import '../config/app_config.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final response = await _apiClient.put(
      '${AppConfig.profileApi}/update',
      data: {
        if (fullName != null) 'nickname': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    );

    final resp = response.data as Map<String, dynamic>;
    return resp['data'] as Map<String, dynamic>? ?? {};
  }

  Future<void> deleteAccount() async {
    await _apiClient.delete('${AppConfig.profileApi}/delete');
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiClient.get('${AppConfig.profileApi}/stats');
    final resp = response.data as Map<String, dynamic>;
    return resp['data'] as Map<String, dynamic>? ?? {};
  }
}
