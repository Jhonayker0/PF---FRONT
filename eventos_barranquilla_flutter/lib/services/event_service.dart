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

  Future<void> attendEvent({required String eventId, required String userId}) async {
    await _client.postJson('/events/$eventId/attend?user_id=$userId');
  }
}
