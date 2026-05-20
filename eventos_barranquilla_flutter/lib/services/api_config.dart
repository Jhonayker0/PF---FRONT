import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get userBaseUrl {
    const value = String.fromEnvironment('USER_API_BASE_URL');
    if (value.isNotEmpty) {
      return value;
    }
    return kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  }

  static String get eventBaseUrl {
    const value = String.fromEnvironment('EVENT_API_BASE_URL');
    if (value.isNotEmpty) {
      return value;
    }
    return kIsWeb ? 'http://localhost:4003' : 'http://10.0.2.2:4003';
  }
}
