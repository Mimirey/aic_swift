class ApiConstants {
  ApiConstants._();
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/',
  );
  static String get wsBaseUrl {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return '$scheme://${uri.authority}';
  }

  static const String login = 'api/v1/auth/login';
  static const String shipments = 'api/v1/shipments';
  static const String optimizedRoute =
      'api/v1/pathfinding/find-optimized-delivery-route';
  static const String wsNavigation = 'api/v1/ws/navigation';
  static const String wsDriverPosition = 'api/v1/ws/driver/position';
}
