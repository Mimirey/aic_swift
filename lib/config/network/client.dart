import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:getx_setup/config/network/constant_api.dart';
import 'package:getx_setup/utils/session_manager.dart';
import 'package:getx_setup/utils/token_expired_handler.dart';

class Client {
  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ConstantApi.fullUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.addAll([
      TokenExpiredInterceptor(),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers["Content-Type"] = "application/json";
          options.headers["Accept"] = "application/json";

          final token = await SessionManager.readAccessToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },
      ),

      if (kDebugMode)
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          error: true,
        ),
    ]);

    return dio;
  }
}
