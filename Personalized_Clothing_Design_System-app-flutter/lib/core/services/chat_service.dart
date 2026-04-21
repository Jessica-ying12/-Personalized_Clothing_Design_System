import '../api/api_client.dart';
import '../config/app_config.dart';

class ChatService {
  final ApiClient _apiClient;
  ChatService(this._apiClient);

  Future<String> ask(String message) async {
    final response = await _apiClient.post(
      '${AppConfig.chatApi}/ask',
      data: {'message': message},
    );
    final resp = response.data as Map<String, dynamic>;
    final data = resp['data'] as Map<String, dynamic>;
    return data['reply'] as String;
  }
}
