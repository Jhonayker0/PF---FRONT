class SmartIdCard {
  final String userId;
  final String qrContent;
  final String? qrCodeBase64;
  final String? generatedAt;

  const SmartIdCard({
    required this.userId,
    required this.qrContent,
    this.qrCodeBase64,
    this.generatedAt,
  });

  factory SmartIdCard.fromJson(String userId, Map<String, dynamic> json) {
    final qrContent = json['qr_content']?.toString() ??
        json['qr_value']?.toString() ??
        json['qr_token']?.toString() ??
        json['content']?.toString() ??
        json['user_id']?.toString() ??
        userId;

    return SmartIdCard(
      userId: userId,
      qrContent: qrContent,
      qrCodeBase64: json['qr_code_base64']?.toString() ??
          json['qr_image_base64']?.toString() ??
          json['image_base64']?.toString(),
      generatedAt: json['generated_at']?.toString() ??
          json['created_at']?.toString() ??
          json['updated_at']?.toString(),
    );
  }
}
