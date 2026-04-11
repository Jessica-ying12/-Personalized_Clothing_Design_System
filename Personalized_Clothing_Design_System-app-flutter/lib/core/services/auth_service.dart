import '../api/api_client.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../storage/secure_storage.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.authApi}/register',
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>;
    final token = session['access_token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await SecureStorage.saveToken(token);
    await SecureStorage.saveUserId(user.id);
    await SecureStorage.saveEmail(user.email);

    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.authApi}/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>;
    final token = session['access_token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await SecureStorage.saveToken(token);
    await SecureStorage.saveUserId(user.id);
    await SecureStorage.saveEmail(user.email);

    return data;
  }

  Future<UserModel> getMe() async {
    final response = await _apiClient.get('${AppConfig.authApi}/me');
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await SecureStorage.clear();
  }

  Future<void> changePassword(String newPassword) async {
    await _apiClient.post(
      '${AppConfig.authApi}/change-password',
      data: {'new_password': newPassword},
    );
  }

  Future<void> resetPassword({required String email}) async {
    await _apiClient.post(
      '${AppConfig.authApi}/reset-password',
      data: {'email': email},
    );
  }
}
