import '../models/user.dart';

class ProfileStats {
  final int events;
  final int reviews;
  final int monthsOnCumbe;

  const ProfileStats({
    required this.events,
    required this.reviews,
    required this.monthsOnCumbe,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      events: json['events'] ?? 0,
      reviews: json['reviews'] ?? 0,
      monthsOnCumbe: json['monthsOnCumbe'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events,
      'reviews': reviews,
      'monthsOnCumbe': monthsOnCumbe,
    };
  }
}

const Map<String, dynamic> mockUserJson = {
  'id': 'u-1',
  'name': 'Jhonayker',
  'email': 'jhonayker@email.com',
  'role': 'client',
};

const Map<String, dynamic> mockProfileStatsJson = {
  'events': 1,
  'reviews': 1,
  'monthsOnCumbe': 1,
};

final User mockUser = User.fromJson(mockUserJson);
final ProfileStats mockProfileStats = ProfileStats.fromJson(
  mockProfileStatsJson,
);
