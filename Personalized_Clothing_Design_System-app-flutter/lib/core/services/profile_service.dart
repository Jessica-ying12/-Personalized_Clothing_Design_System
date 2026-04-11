import '../api/api_client.dart';
import '../config/app_config.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.profileApi}/update',
      data: {
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteAccount() async {
    await _apiClient.delete('${AppConfig.profileApi}/account');
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiClient.get('${AppConfig.profileApi}/stats');
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }
}
