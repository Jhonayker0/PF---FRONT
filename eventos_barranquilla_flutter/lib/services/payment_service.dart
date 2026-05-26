import 'package:flutter/foundation.dart';

import '../models/payment.dart';
import 'api_client.dart';
import 'api_config.dart';

class PaymentService {
  PaymentService({ApiClient? client})
      : _client = client ?? ApiClient(ApiConfig.paymentBaseUrl);

  final ApiClient _client;

  Future<PaymentWithQrResponse> initiatePayment({
    required String userId,
    required String eventId,
    String? token,
  }) async {
    debugPrint(
      '[PaymentService] POST /payments/initiate user_id=$userId event_id=$eventId',
    );
    final headers = token != null && token.isNotEmpty
        ? {'Authorization': 'Bearer $token'}
        : null;
    try {
      final data = await _client.postJson(
        '/payments/initiate',
        headers: headers,
        body: {
          'user_id': userId,
          'event_id': eventId,
        },
      );

      if (data is Map<String, dynamic>) {
        return PaymentWithQrResponse.fromJson(data);
      }

      throw ApiException(500, 'Invalid payment initiation response');
    } on ApiException catch (error) {
      debugPrint(
        '[PaymentService] initiate failed status=${error.statusCode} body=${error.message}',
      );
      rethrow;
    }
  }

  Future<ValidateQrResponse> validateQr(String token, {String? authToken}) async {
    final headers = authToken != null && authToken.isNotEmpty
        ? {'Authorization': 'Bearer $authToken'}
        : null;
    final data = await _client.postJson(
      '/payments/validate',
      headers: headers,
      body: {
        'token': token,
      },
    );

    if (data is Map<String, dynamic>) {
      return ValidateQrResponse.fromJson(data);
    }

    throw ApiException(500, 'Invalid payment validation response');
  }

  Future<PaymentResponse> getPayment(String paymentId, {String? token}) async {
    final headers = token != null && token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null;
    final data = await _client.getJson('/payments/$paymentId', headers: headers);
    if (data is Map<String, dynamic>) {
      return PaymentResponse.fromJson(data);
    }
    throw ApiException(404, 'Payment not found');
  }

  Future<List<PaymentResponse>> getUserPayments(String userId) async {
    final data = await _client.getJson('/payments/user/$userId');
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(PaymentResponse.fromJson)
          .toList();
    }
    return [];
  }

  Future<List<PaymentResponse>> getEventPayments(String eventId, {String? token}) async {
    final headers = token != null && token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null;
    final data = await _client.getJson('/payments/event/$eventId', headers: headers);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(PaymentResponse.fromJson)
          .toList();
    }
    return [];
  }

  Future<PaymentResponse> cancelPayment(String paymentId) async {
    final data = await _client.postJson('/payments/$paymentId/cancel');
    if (data is Map<String, dynamic>) {
      return PaymentResponse.fromJson(data);
    }
    throw ApiException(500, 'Invalid payment cancel response');
  }
}