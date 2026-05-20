import '../models/event.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'api_config.dart';

class EventService {
  EventService({ApiClient? client})
      : _client = client ?? ApiClient(ApiConfig.eventBaseUrl);

  final ApiClient _client;

  Future<List<Event>> fetchPopularEvents() async {
    final data = await _client.getJson('/events/popular');
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Event.fromJson)
          .toList();
    }
    return [];
  }

  Future<List<Event>> fetchEventsByCategory(String categoryName) async {
    final data = await _client.getJson('/events/category/${Uri.encodeComponent(categoryName)}');
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Event.fromJson)
          .toList();
    }
    return [];
  }

  Future<Event> fetchEventById(String eventId) async {
    final data = await _client.getJson('/events/$eventId');
    if (data is Map<String, dynamic>) {
      return Event.fromJson(data);
    }
    throw ApiException(404, 'Event not found');
  }

  Future<Event> createEvent({
    required String userId,
    required String name,
    required String description,
    required String date,
    required String location,
    required String category,
    List<String>? pictureUrls,
    User? organizer,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'description': description,
      'date': date,
      'location': location,
      'categories': [category],
      if (organizer != null)
        'organizer': {
          'name': organizer.name,
          'email': organizer.email,
        },
      if (pictureUrls != null && pictureUrls.isNotEmpty)
        'picture': pictureUrls,
    };
    final data = await _client.postJson('/events/$userId/events', body: payload);
    if (data is Map<String, dynamic>) {
      return Event.fromJson(data);
    }
    throw ApiException(500, 'Unexpected response when creating event');
  }

  Future<Event> updateEvent({
    required String eventId,
    String? name,
    String? description,
    String? date,
    String? location,
    String? category,
    List<String>? pictureUrls,
  }) async {
    final payload = <String, dynamic>{
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (location != null) 'location': location,
      if (category != null) 'categories': [category],
      if (pictureUrls != null && pictureUrls.isNotEmpty) 'picture': pictureUrls,
    };
    final data = await _client.putJson('/events/$eventId', body: payload);
    if (data is Map<String, dynamic>) {
      return Event.fromJson(data);
    }
    throw ApiException(500, 'Unexpected response when updating event');
  }

  Future<void> deleteEvent(String eventId) async {
    await _client.deleteJson('/events/$eventId');
  }

  Future<void> attendEvent({required String eventId, required String userId}) async {
    await _client.postJson('/events/$eventId/attend?user_id=$userId');
  }

  Future<void> leaveEvent({required String eventId, required String userId}) async {
    await _client.deleteJson('/events/$eventId/attend?user_id=$userId');
  }

  Future<List<dynamic>> fetchAttendees(String eventId) async {
    final data = await _client.getJson('/events/$eventId/attendees');
    if (data is List) {
      return data;
    }
    return [];
  }
}
