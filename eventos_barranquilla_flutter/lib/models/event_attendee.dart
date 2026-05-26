import 'user.dart';

class EventAttendee {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profilePicture;

  const EventAttendee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
  });

  String get displayName {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isNotEmpty) {
      return trimmedEmail;
    }

    return 'Asistente';
  }

  factory EventAttendee.fromJson(Map<String, dynamic> json) {
    final nestedUser = json['user'];
    final source = nestedUser is Map<String, dynamic> ? nestedUser : json;

    return EventAttendee(
      id: source['id']?.toString() ?? source['_id']?.toString() ?? source['user_id']?.toString() ?? '',
      name: source['name']?.toString() ?? source['full_name']?.toString() ?? source['username']?.toString() ?? '',
      email: source['email']?.toString() ?? '',
      role: source['role']?.toString() ?? '',
      profilePicture: source['profile_picture_url']?.toString() ??
          source['profile_picture']?.toString() ??
          source['profilePicture']?.toString(),
    );
  }

  factory EventAttendee.fromUser(User user) {
    return EventAttendee(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      profilePicture: user.profilePicture,
    );
  }
}