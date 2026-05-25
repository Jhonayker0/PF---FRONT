import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient(String baseUrl, {http.Client? client})
      : baseUrl = _normalizeBaseUrl(baseUrl),
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static String _normalizeBaseUrl(String value) {
    return value.replaceFirst(RegExp(r'/+$'), '');
  }

  Future<dynamic> getJson(String path, {Map<String, String>? headers}) {
    return _sendJson('GET', path, headers: headers);
  }

  Future<dynamic> postJson(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _sendJson('POST', path, headers: headers, body: body);
  }

  Future<dynamic> putJson(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _sendJson('PUT', path, headers: headers, body: body);
  }

  Future<dynamic> patchJson(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _sendJson('PATCH', path, headers: headers, body: body);
  }

  Future<dynamic> deleteJson(String path, {Map<String, String>? headers}) {
    return _sendJson('DELETE', path, headers: headers);
  }

  Future<dynamic> _sendJson(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    final response = await _client.send(
      http.Request(method, uri)
        ..headers.addAll(requestHeaders)
        ..body = body != null ? jsonEncode(body) : '',
    );
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        responseBody.isEmpty ? 'Request failed' : responseBody,
      );
    }
    if (responseBody.isEmpty) {
      return null;
    }
    return jsonDecode(responseBody);
  }
}
