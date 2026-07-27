class ConstantApi {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://localhost:8080',
  );
  static const String apiUrl = "/api";
  static const String version = "/v1";

  static const String fullUrl = "$baseUrl$apiUrl$version";

  // AUTH
  static const String auth = "/auth";
  static const String login = "$auth/login";

  // ORDER

  // PAYMENT

  // HISTORY

  /// CART

  // USER

  // NOTIFICATION
}
