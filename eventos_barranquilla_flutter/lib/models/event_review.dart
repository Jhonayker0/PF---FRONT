class EventReview {
  final String userId;
  final String userName;
  final String reviewText;
  final int star;
  final String profilePictureUrl;
  final String createdAt;

  const EventReview({
    required this.userId,
    required this.userName,
    required this.reviewText,
    required this.star,
    this.profilePictureUrl = '',
    this.createdAt = '',
  });

  factory EventReview.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    String userId = '';
    String userName = '';
    String profilePictureUrl = '';

    if (user is Map<String, dynamic>) {
      userId = user['id']?.toString() ?? user['_id']?.toString() ?? user['user_id']?.toString() ?? '';
      userName = user['name']?.toString() ?? user['full_name']?.toString() ?? '';
      profilePictureUrl = user['profile_picture_url']?.toString() ?? user['profilePicture']?.toString() ?? '';
    } else if (user is String) {
      userId = user;
    }

    return EventReview(
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? userId,
      userName: json['user_name']?.toString() ?? json['userName']?.toString() ?? userName,
      reviewText: json['review_text']?.toString() ?? json['reviewText']?.toString() ?? json['text']?.toString() ?? '',
      star: (json['star'] is num)
          ? (json['star'] as num).toInt()
          : (json['rating'] is num)
              ? (json['rating'] as num).toInt()
              : 0,
      profilePictureUrl: json['profile_picture_url']?.toString() ?? json['profilePictureUrl']?.toString() ?? profilePictureUrl,
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'review_text': reviewText,
      'star': star,
    };
  }

  EventReview copyWith({
    String? userId,
    String? userName,
    String? reviewText,
    int? star,
    String? profilePictureUrl,
    String? createdAt,
  }) {
    return EventReview(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      reviewText: reviewText ?? this.reviewText,
      star: star ?? this.star,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
