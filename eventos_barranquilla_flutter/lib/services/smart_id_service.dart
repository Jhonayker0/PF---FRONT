import '../models/smart_id_card.dart';
import 'api_client.dart';
import 'api_config.dart';

class SmartIdService {
  SmartIdService({ApiClient? client})
      : _client = client ?? ApiClient(ApiConfig.userBaseUrl);

  final ApiClient _client;

  String _smartIdPath(String userId) {
    const template = String.fromEnvironment(
      'SMART_ID_API_PATH',
      defaultValue: '/users/{userId}/smart-id',
    );
    return template
        .replaceAll('{userId}', userId)
        .replaceAll('{user_id}', userId);
  }

  Future<SmartIdCard> fetchSmartId({
    required String userId,
    String? token,
  }) async {
    final headers = token != null && token.isNotEmpty
        ? {'Authorization': 'Bearer $token'}
        : null;

    try {
      final data = await _client.getJson(_smartIdPath(userId), headers: headers);
      if (data is Map<String, dynamic>) {
        return SmartIdCard.fromJson(userId, data);
      }
    } catch (_) {
      // Fallback below.
    }

    return SmartIdCard(userId: userId, qrContent: userId);
  }
}
