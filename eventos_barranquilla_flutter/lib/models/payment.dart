class PaymentResponse {
  final String id;
  final String userId;
  final String eventId;
  final String userEmail;
  final String eventName;
  final double amount;
  final String currency;
  final String status;
  final String? qrCodeBase64;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;

  const PaymentResponse({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.userEmail,
    required this.eventName,
    required this.amount,
    required this.status,
    this.currency = 'COP',
    this.qrCodeBase64,
    this.createdAt,
    this.updatedAt,
    this.confirmedAt,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      eventName: json['event_name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'COP',
      status: json['status']?.toString() ?? '',
      qrCodeBase64: json['qr_code_base64']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      confirmedAt: DateTime.tryParse(json['confirmed_at']?.toString() ?? ''),
    );
  }
}

class PaymentWithQrResponse {
  final String paymentId;
  final double amount;
  final String eventName;
  final String qrCodeBase64;
  final String qrToken;
  final String status;

  const PaymentWithQrResponse({
    required this.paymentId,
    required this.amount,
    required this.eventName,
    required this.qrCodeBase64,
    required this.qrToken,
    required this.status,
  });

  factory PaymentWithQrResponse.fromJson(Map<String, dynamic> json) {
    return PaymentWithQrResponse(
      paymentId: json['payment_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      eventName: json['event_name']?.toString() ?? '',
      qrCodeBase64: json['qr_code_base64']?.toString() ?? '',
      qrToken: json['qr_token']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
    );
  }
}

class ValidateQrResponse {
  final String message;
  final String eventId;
  final String userId;
  final String? paymentId;

  const ValidateQrResponse({
    required this.message,
    required this.eventId,
    required this.userId,
    this.paymentId,
  });

  factory ValidateQrResponse.fromJson(Map<String, dynamic> json) {
    return ValidateQrResponse(
      message: json['message']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      paymentId: json['payment_id']?.toString(),
    );
  }
}