import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'api_exception.dart';
import '../utils/token_storage.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final headers = {'Content-Type': 'application/json'};

    if (withAuth) {
      final token = await TokenStorage.readToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    late http.Response response;
    try {
      response = await http
          .post(uri, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const ApiException('Gagal terhubung ke server. Cek koneksi internet kamu.');
    }

    final decoded = _safeDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw ApiException(
      decoded['message'] as String? ?? 'Terjadi kesalahan (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _safeDecode(String body) {
    if (body.isEmpty) return {};
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}