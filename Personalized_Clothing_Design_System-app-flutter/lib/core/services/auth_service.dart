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
    String? fullName,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.authApi}/register',
      data: {
        'email': email,
        'password': password,
        if (fullName != null) 'nickname': fullName,
      },
    );

    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    final token = data['token'] as String;

    await SecureStorage.saveToken(token);
    await SecureStorage.saveUserId(data['user_id'].toString());
    await SecureStorage.saveEmail(data['email'] as String);

    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.authApi}/login',
      data: {'email': email, 'password': password},
    );

    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    final token = data['token'] as String;

    await SecureStorage.saveToken(token);
    await SecureStorage.saveUserId(data['user_id'].toString());
    await SecureStorage.saveEmail(data['email'] as String);

    return data;
  }

  Future<void> sendOtp({required String email}) async {
    await _apiClient.post(
      '${AppConfig.authApi}/send-otp',
      data: {'email': email},
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      '${AppConfig.authApi}/verify-otp',
      data: {'email': email, 'code': code},
    );

    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    final token = data['token'] as String;

    await SecureStorage.saveToken(token);
    await SecureStorage.saveUserId(data['user_id'].toString());
    await SecureStorage.saveEmail(data['email'] as String);

    return data;
  }

  Future<UserModel> getMe() async {
    final response = await _apiClient.get('${AppConfig.profileApi}/me');
    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    return UserModel(
      id: data['user_id'].toString(),
      email: data['email'] as String,
      fullName: data['nickname'] as String? ?? '',
      avatarUrl: data['avatar_url'] as String?,
      createdAt: DateTime.now(),
    );
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('${AppConfig.authApi}/logout');
    } catch (_) {}
    await SecureStorage.clear();
  }

  Future<void> changePassword(String newPassword, {String oldPassword = ''}) async {
    await _apiClient.post(
      '${AppConfig.authApi}/change-password',
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }

  Future<void> resetPassword({required String email}) async {
    await _apiClient.post(
      '${AppConfig.authApi}/send-otp',
      data: {'email': email},
    );
  }
}
