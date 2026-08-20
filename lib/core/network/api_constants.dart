class ApiConstants {
  ApiConstants._();
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://msi-abcd.tailc3de19.ts.net/',
  );
  static const String login = 'api/v1/auth/login';
  static const String shipments = 'api/v1/shipments';
  static const String optimizedRoute =
      'api/v1/pathfinding/find-optimized-delivery-route';
}
