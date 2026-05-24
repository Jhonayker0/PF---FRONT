import '../models/user.dart';
import 'api_client.dart';
import 'api_config.dart';

class UserService {
  UserService({ApiClient? client})
      : _client = client ?? ApiClient(ApiConfig.userBaseUrl);

  final ApiClient _client;

  Future<String> login({required String email, required String password}) async {
    final data = await _client.postJson('/users/login', body: {
      'email': email,
      'password': password,
    });
    if (data is Map<String, dynamic> && data['access_token'] is String) {
      return data['access_token'] as String;
    }
    throw ApiException(500, 'Invalid login response');
  }

  Future<String> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _client.postJson('/users/signup', body: {
      'name': name,
      'email': email,
      'password': password,
    });
    if (data is Map<String, dynamic> && data['access_token'] is String) {
      return data['access_token'] as String;
    }
    throw ApiException(500, 'Invalid signup response');
  }

  Future<String> verifyToken(String token) async {
    final data = await _client.getJson('/users/verify-token/$token');
    if (data is Map<String, dynamic> && data['user_id'] is String) {
      return data['user_id'] as String;
    }
    throw ApiException(401, 'Invalid token');
  }

  Future<User> fetchUser(String userId) async {
    final data = await _client.getJson('/users/$userId');
    if (data is Map<String, dynamic>) {
      return User.fromJson(data);
    }
    throw ApiException(404, 'User not found');
  }

  Future<void> updateFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    await _client.putJson('/users/$userId/fcm_token?fcm_token=$fcmToken');
  }

  Future<void> logout({required String token}) async {
    await _client.postJson(
      '/users/logout',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> addFavorite({
    required String userId,
    required String eventId,
    required String token,
  }) async {
    await _client.postJson(
      '/users/$userId/favorites/$eventId',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> removeFavorite({
    required String userId,
    required String eventId,
    required String token,
  }) async {
    await _client.deleteJson(
      '/users/$userId/favorites/$eventId',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
