class ApiConfig {
  static String get userBaseUrl {
    const value = String.fromEnvironment('USER_API_BASE_URL');
    if (value.isNotEmpty) {
      return value;
    }
    return 'https://back-cumbe-users.onrender.com';
  }

  static String get eventBaseUrl {
    const value = String.fromEnvironment('EVENT_API_BASE_URL');
    if (value.isNotEmpty) {
      return value;
    }
    return 'https://back-cumbe-events.onrender.com';
  }

  static String get paymentBaseUrl {
    const value = String.fromEnvironment('PAYMENT_API_BASE_URL');
    if (value.isNotEmpty) {
      return value;
    }
    return 'https://back-cumbe-pay.onrender.com';
  }
}
