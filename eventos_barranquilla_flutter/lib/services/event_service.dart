import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/event.dart';
import '../models/event_attendee.dart';
import '../models/event_review.dart';
import '../models/user_review_entry.dart';
import '../models/user.dart';
import '../data/event_categories.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'user_service.dart';

class EventService {
  EventService({ApiClient? client})
      : _client = client ?? ApiClient(ApiConfig.eventBaseUrl);

  final ApiClient _client;
  final UserService _userService = UserService();

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

  Future<List<Event>> fetchAllEvents() async {
    final popularEvents = await fetchPopularEvents();
    final categorizedEvents = await Future.wait(
      EventCategories.generalCategories.map(fetchEventsByCategory),
    );

    final deduplicated = <String, Event>{};
    for (final event in popularEvents) {
      deduplicated[event.id] = event;
    }
    for (final events in categorizedEvents) {
      for (final event in events) {
        deduplicated[event.id] = event;
      }
    }

    return deduplicated.values.toList();
  }

  Future<List<Event>> fetchEventsByIds(List<String> eventIds) async {
    final loaded = <Event>[];
    for (final eventId in eventIds) {
      try {
        final event = await fetchEventById(eventId);
        loaded.add(event);
      } catch (_) {
        // ignore missing events individually
      }
    }
    return loaded;
  }

  Future<List<Event>> fetchEventsCreatedByOrganizer(String organizerId) async {
    final allEvents = await fetchAllEvents();
    return allEvents.where((event) => event.organizerId == organizerId).toList();
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
    double price = 0.0,
    String? categoryGroup,
    String? categorySpecific,
    List<String>? pictureUrls,
    User? organizer,
  }) async {
    final localImagePaths = (pictureUrls ?? const [])
      .where((path) => path.trim().isNotEmpty)
      .toList();

    // Create event first (JSON) and then upload images to /events/{event_id}/upload-image
    final resolvedGroup = categoryGroup ?? category;
    final resolvedSpecific = categorySpecific ?? category;
    final organizerId = organizer?.id ?? userId;
    final payload = <String, dynamic>{
      'name': name,
      'description': description,
      'date': date,
      'location': location,
      'category': resolvedSpecific,
      'category_group': resolvedGroup,
      'category_specific': resolvedSpecific,
      'price': price,
      // backend expects categories as an array (of strings)
      'categories': [resolvedSpecific],
      'organizer': organizerId,
    };
    try {
      print('Creating event (json) to ${_client.baseUrl}/events/$userId/events');
      print('Payload: ${jsonEncode(payload)}');
      final data = await _client.postJson('/events/$userId/events', body: payload);
      if (data is Map<String, dynamic>) {
        final created = Event.fromJson(data);
        // If there are local images, upload each and then update the event with returned URLs
        if (localImagePaths.isNotEmpty && localImagePaths.every((path) => File(path).existsSync())) {
          final uploaded = <String>[];
          for (final path in localImagePaths) {
            try {
              final url = await uploadEventImage(eventId: created.id, filePath: path);
              uploaded.add(url);
            } catch (e) {
              // if an image upload fails, continue with others
            }
          }
          if (uploaded.isNotEmpty) {
            try {
              return await updateEvent(eventId: created.id, pictureUrls: uploaded);
            } catch (_) {
              // if update fails, return created without pictures
            }
          }
        }
        return created;
      }
      throw ApiException(500, 'Unexpected response when creating event');
    } catch (e) {
      print('JSON createEvent error: $e');
      rethrow;
    }

    
  }

  Future<Event> _createEventMultipart({
    required String userId,
    required String name,
    required String description,
    required String date,
    required String location,
    required String category,
    required double price,
    String? categoryGroup,
    String? categorySpecific,
    required List<String> picturePaths,
    User? organizer,
  }) async {
    final resolvedGroup = categoryGroup ?? category;
    final resolvedSpecific = categorySpecific ?? category;
    final uri = Uri.parse('${ApiConfig.eventBaseUrl}/events/$userId/events');
    final request = http.MultipartRequest('POST', uri)
      ..fields['name'] = name
      ..fields['description'] = description
      ..fields['date'] = date
      ..fields['location'] = location
      ..fields['category'] = resolvedSpecific
      ..fields['category_group'] = resolvedGroup
      ..fields['category_specific'] = resolvedSpecific
      ..fields['price'] = (price % 1 == 0) ? price.toInt().toString() : price.toString();
    // include categories as JSON string so backend can parse array
    request.fields['categories'] = jsonEncode([resolvedSpecific]);

    // send organizer as ID string (matches backend schema)
    request.fields['organizer'] = organizer?.id ?? userId;
    // ensure we accept JSON response
    request.headers['Accept'] = 'application/json';

    print('Multipart request fields: ${request.fields}');

    // attach files under 'pictures' (backend expects 'pictures' array)
    for (final path in picturePaths) {
      final file1 = await http.MultipartFile.fromPath('pictures', path);
      print('Attaching file (pictures): ${file1.filename} size=${file1.length}');
      request.files.add(file1);

      // also attach under 'pictures[]' in case backend expects array notation
      final file2 = await http.MultipartFile.fromPath('pictures[]', path);
      print('Attaching file (pictures[]): ${file2.filename} size=${file2.length}');
      request.files.add(file2);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('Multipart response status: ${response.statusCode}');
      print('Multipart response body: ${response.body}');
      throw ApiException(
        response.statusCode,
        response.body.isEmpty ? 'Request failed' : response.body,
      );
    }

    if (response.body.isEmpty) {
      throw ApiException(500, 'Empty response when creating event');
    }

    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (decoded is Map<String, dynamic>) {
      return Event.fromJson(decoded);
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
    String? categoryGroup,
    String? categorySpecific,
    double? price,
    String? organizerId,
    List<String>? pictureUrls,
  }) async {
    final resolvedGroup = categoryGroup ?? category;
    final resolvedSpecific = categorySpecific ?? category;
    final payload = <String, dynamic>{
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (location != null) 'location': location,
      if (category != null) 'category': resolvedSpecific,
      if (categoryGroup != null || category != null) 'category_group': resolvedGroup,
      if (categorySpecific != null || category != null) 'category_specific': resolvedSpecific,
      if (price != null) 'price': price,
      if (organizerId != null) 'organizer': organizerId,
      if (category != null || categoryGroup != null || categorySpecific != null)
        'categories': [
          {resolvedGroup: resolvedSpecific},
        ],
      if (pictureUrls != null && pictureUrls.isNotEmpty) 'pictures': pictureUrls,
    };
    final data = await _client.putJson('/events/$eventId', body: payload);
    if (data is Map<String, dynamic>) {
      return Event.fromJson(data);
    }
    throw ApiException(500, 'Unexpected response when updating event');
  }

  Future<Event> updateEventMultipart({
    required String eventId,
    String? name,
    String? description,
    String? date,
    String? location,
    String? category,
    String? categoryGroup,
    String? categorySpecific,
    double? price,
    String? organizerId,
    List<String>? keptPictureUrls,
    List<String>? newPicturePaths,
  }) async {
    final resolvedGroup = categoryGroup ?? category;
    final resolvedSpecific = categorySpecific ?? category;
    final uri = Uri.parse('${ApiConfig.eventBaseUrl}/events/$eventId');
    final request = http.MultipartRequest('PUT', uri)
      ..fields['name'] = name ?? ''
      ..fields['description'] = description ?? ''
      ..fields['date'] = date ?? ''
      ..fields['location'] = location ?? ''
      ..fields['category'] = resolvedSpecific ?? ''
      ..fields['category_group'] = resolvedGroup ?? ''
      ..fields['category_specific'] = resolvedSpecific ?? '';

    if (price != null) {
      request.fields['price'] = (price % 1 == 0) ? price.toInt().toString() : price.toString();
    }
    if (resolvedSpecific != null) {
      request.fields['categories'] = jsonEncode([resolvedSpecific]);
    }
    if (organizerId != null) request.fields['organizer'] = organizerId;

    request.headers['Accept'] = 'application/json';

    if (keptPictureUrls != null && keptPictureUrls.isNotEmpty) {
      request.fields['pictures'] = jsonEncode(keptPictureUrls);
    }

    if (newPicturePaths != null && newPicturePaths.isNotEmpty) {
      for (final path in newPicturePaths) {
        final file = await http.MultipartFile.fromPath('pictures', path);
        request.files.add(file);
        final file2 = await http.MultipartFile.fromPath('pictures[]', path);
        request.files.add(file2);
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (decoded is Map<String, dynamic>) {
      return Event.fromJson(decoded);
    }
    throw ApiException(500, 'Unexpected response when updating event');
  }

  Future<void> deleteEvent(String eventId) async {
    await _client.deleteJson('/events/$eventId');
  }

  Future<String> uploadEventImage({
    required String eventId,
    required String filePath,
    String? token,
  }) async {
    return _sendEventImageRequest(
      method: 'POST',
      path: '/events/$eventId/upload-image',
      filePath: filePath,
      token: token,
    );
  }

  Future<String> updateEventImage({
    required String eventId,
    required String filePath,
    String? token,
  }) async {
    return _sendEventImageRequest(
      method: 'PUT',
      path: '/events/$eventId/upload-image',
      filePath: filePath,
      token: token,
    );
  }

  Future<void> deleteEventImage({
    required String eventId,
    required String imageUrl,
    String? token,
  }) async {
    final headers = <String, String>{
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final query = <String, String>{};
    if (imageUrl.isNotEmpty) {
      query['image_url'] = imageUrl;
    }

    final uri = Uri.parse('${ApiConfig.eventBaseUrl}/events/$eventId/images')
        .replace(queryParameters: query.isEmpty ? null : query);
    final response = await http.delete(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        response.body.isEmpty ? 'Request failed' : response.body,
      );
    }
  }

  Future<String> _sendEventImageRequest({
    required String method,
    required String path,
    required String filePath,
    String? token,
  }) async {
    final uri = Uri.parse('${ApiConfig.eventBaseUrl}$path');
    final request = http.MultipartRequest(method, uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw ApiException(streamed.statusCode, body);
    }
    if (body.isEmpty) {
      return '';
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic> && decoded['url'] is String) {
      return decoded['url'] as String;
    }
    if (decoded is Map<String, dynamic> && decoded['image_url'] is String) {
      return decoded['image_url'] as String;
    }
    return '';
  }

  Future<void> attendEvent({required String eventId, required String userId}) async {
    await _client.postJson('/events/$eventId/attend?user_id=$userId');
  }

  Future<void> leaveEvent({required String eventId, required String userId}) async {
    await _client.deleteJson('/events/$eventId/attend?user_id=$userId');
  }

  Future<List<EventAttendee>> fetchAttendees(String eventId) async {
    final data = await _client.getJson('/events/$eventId/attendees');
    if (data is List) {
      final attendees = <EventAttendee>[];
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          attendees.add(EventAttendee.fromJson(item));
          continue;
        }

        final attendeeId = item?.toString().trim() ?? '';
        if (attendeeId.isEmpty) {
          continue;
        }

        try {
          final user = await _userService.fetchUser(attendeeId);
          attendees.add(EventAttendee.fromUser(user));
        } catch (_) {
          attendees.add(
            EventAttendee(
              id: attendeeId,
              name: attendeeId,
              email: '',
              role: '',
            ),
          );
        }
      }
      return attendees;
    }
    return [];
  }

  Future<List<EventReview>> fetchEventReviews(String eventId) async {
    final data = await _client.getJson('/events/$eventId/reviews');
    final rawList = data is List
        ? data
        : data is Map<String, dynamic> && data['reviews'] is List
            ? data['reviews'] as List
            : const [];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(EventReview.fromJson)
        .toList();
  }

  Future<EventReview> addEventReview({
    required String eventId,
    required String userId,
    required String reviewText,
    required int star,
    String? token,
  }) async {
    final headers = token != null && token.isNotEmpty
        ? {'Authorization': 'Bearer $token'}
        : null;
    final data = await _client.postJson(
      '/events/$eventId/reviews',
      headers: headers,
      body: {
        'user_id': userId,
        'review_text': reviewText,
        'star': star,
      },
    );
    if (data is Map<String, dynamic>) {
      return EventReview.fromJson(data);
    }
    throw ApiException(500, 'Invalid review response');
  }

  Future<EventReview> updateEventReview({
    required String eventId,
    required String userId,
    required String reviewText,
    required int star,
    String? token,
  }) async {
    final headers = token != null && token.isNotEmpty
        ? {'Authorization': 'Bearer $token'}
        : null;
    final data = await _client.patchJson(
      '/events/$eventId/reviews/$userId',
      headers: headers,
      body: {
        'review_text': reviewText,
        'star': star,
      },
    );
    if (data is Map<String, dynamic>) {
      return EventReview.fromJson(data);
    }
    throw ApiException(500, 'Invalid review response');
  }

  Future<void> deleteEventReview({
    required String eventId,
    required String userId,
    String? token,
  }) async {
    final headers = token != null && token.isNotEmpty
        ? {'Authorization': 'Bearer $token'}
        : null;
    await _client.deleteJson('/events/$eventId/reviews/$userId', headers: headers);
  }

  Future<List<UserReviewEntry>> fetchReviewsGivenByUser(String userId) async {
    final events = await fetchAllEvents();
    final results = await Future.wait(
      events.map((event) async {
        final reviews = await fetchEventReviews(event.id);
        final myReview = reviews.where((review) => review.userId == userId).toList();
        if (myReview.isEmpty) {
          return <UserReviewEntry>[];
        }
        return myReview
            .map((review) => UserReviewEntry(event: event, review: review))
            .toList();
      }),
    );

    return results.expand((entries) => entries).toList();
  }
}
