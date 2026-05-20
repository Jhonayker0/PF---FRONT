class ApiConfig {
  static String get userBaseUrl {
    const value = String.fromEnvironment('USER_API_BASE_URL');
    if (value.isNotEmpty) {
      return value;
    }
    return 'https://back-cumbe-users.achesito.xyz';
  }

  static String get eventBaseUrl {
    const value = String.fromEnvironment('EVENT_API_BASE_URL');
    if (value.isNotEmpty) {
      return value;
    }
    return 'https://back-cumbe-events.achesito.xyz';
  }
}
