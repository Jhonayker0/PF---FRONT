class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'client' or 'admin'
  final String? profilePicture;
  final List<String> favorites;
  final List<String> attendedEvents;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'client',
    this.profilePicture,
    List<String>? favorites,
    List<String>? attendedEvents,
  })  : favorites = favorites ?? [],
        attendedEvents = attendedEvents ?? [];

  String get normalizedRole => role.trim().toLowerCase();

  bool get isAdmin {
    final normalized = normalizedRole;
    return normalized == 'admin' ||
        normalized == 'administrator' ||
        normalized == 'organizer' ||
        normalized == 'organizador';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final favorites = json['favorites'];
    final attended = json['attended_events'] ?? json['attendedEvents'];
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: (json['role'] ?? 'client').toString().trim().toLowerCase(),
      profilePicture: json['profile_picture_url'] ??
          json['profile_picture'] ??
          json['profilePicture'],
      favorites: favorites is List
          ? favorites.map((item) => item.toString()).toList()
          : [],
      attendedEvents: attended is List
          ? attended.map((item) => item.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_picture_url': profilePicture,
      'favorites': favorites,
      'attended_events': attendedEvents,
    };
  }
}
