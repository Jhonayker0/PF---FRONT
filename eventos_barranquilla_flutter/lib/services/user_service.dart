import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<String> uploadProfilePicture({
    required String userId,
    required String filePath,
    String? token,
  }) async {
    return _sendProfileImageRequest(
      method: 'POST',
      path: '/users/$userId/upload-profile-picture',
      filePath: filePath,
      token: token,
    );
  }

  Future<String> updateProfilePicture({
    required String userId,
    required String filePath,
    String? token,
  }) async {
    return _sendProfileImageRequest(
      method: 'PUT',
      path: '/users/$userId/profile-picture',
      filePath: filePath,
      token: token,
    );
  }

  Future<void> deleteProfilePicture({
    required String userId,
    String? token,
  }) async {
    final headers = token != null && token.isNotEmpty
        ? {'Authorization': 'Bearer $token'}
        : null;
    await _client.deleteJson('/users/$userId/profile-picture', headers: headers);
  }

  Future<User> updateUser({
    required String userId,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final headers = token != null && token.isNotEmpty
        ? {'Authorization': 'Bearer $token'}
        : null;
    final data = await _client.putJson('/users/$userId', headers: headers, body: body);
    if (data is Map<String, dynamic>) {
      return User.fromJson(data);
    }
    throw ApiException(500, 'Invalid update response');
  }

  Future<String> _sendProfileImageRequest({
    required String method,
    required String path,
    required String filePath,
    String? token,
  }) async {
    final uri = Uri.parse('${ApiConfig.userBaseUrl}$path');
    final request = http.MultipartRequest(method, uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw ApiException(streamed.statusCode, body);
    }
    if (body.isEmpty) {
      return '';
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic> && decoded['url'] is String) {
      return decoded['url'] as String;
    }
    if (decoded is Map<String, dynamic> && decoded['profile_picture_url'] is String) {
      return decoded['profile_picture_url'] as String;
    }
    return '';
  }
}
