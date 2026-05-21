import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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
    double price = 0.0,
    String? categoryGroup,
    String? categorySpecific,
    List<String>? pictureUrls,
    User? organizer,
  }) async {
    final localImagePaths = (pictureUrls ?? const [])
      .where((path) => path.trim().isNotEmpty)
      .toList();

    if (localImagePaths.isNotEmpty && localImagePaths.every((path) => File(path).existsSync())) {
      try {
        print('Creating event (multipart) to ${ApiConfig.eventBaseUrl}/events/$userId/events');
        print('Local image paths: $localImagePaths');
        return await _createEventMultipart(
          userId: userId,
          name: name,
          description: description,
          date: date,
          location: location,
          category: category,
          price: price,
          categoryGroup: categoryGroup,
          categorySpecific: categorySpecific,
          picturePaths: localImagePaths,
          organizer: organizer,
        );
      } catch (e) {
        print('Multipart createEvent error: $e');
        rethrow;
      }
    }

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
      if (pictureUrls != null && pictureUrls.isNotEmpty)
        'pictures': pictureUrls,
    };
    try {
      print('Creating event (json) to ${_client.baseUrl}/events/$userId/events');
      print('Payload: ${jsonEncode(payload)}');
      final data = await _client.postJson('/events/$userId/events', body: payload);
      if (data is Map<String, dynamic>) {
        return Event.fromJson(data);
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
      if (category != null || categoryGroup != null || categorySpecific != null)
        'categories': [
          {resolvedGroup: resolvedSpecific},
        ],
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
