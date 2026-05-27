class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'client' or 'admin'
  final String? profilePicture;
  final List<String> favorites;
  final List<String> attendedEvents;
  final List<String> following;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'client',
    this.profilePicture,
    List<String>? favorites,
    List<String>? attendedEvents,
    List<String>? following,
  })  : favorites = favorites ?? [],
        attendedEvents = attendedEvents ?? [],
        following = following ?? [];

  String get normalizedRole => role.trim().toLowerCase();

  bool get isAdmin {
    final normalized = normalizedRole;
    return normalized == 'admin' ||
        normalized == 'administrator' ||
        normalized == 'organizer' ||
      normalized == 'organizador' ||
      // TODO: remove this temporary fallback when the backend returns role/is_admin consistently.
      email.trim().toLowerCase() == 'admin@example.com';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final favorites = json['favorites'];
    final attended = json['attended_events'] ?? json['attendedEvents'];
    final following = json['following'];
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
        following: following is List
          ? following.map((item) => item.toString()).toList()
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
      'following': following,
    };
  }
}
