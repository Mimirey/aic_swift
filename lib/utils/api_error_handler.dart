import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:getx_setup/models/metadata/enums.dart';

class ApiErrorHandler {
  static void handlePageState({
    DioException? dioError,
    Object? genericError,
    required PageStatus pageState,
    required String errorMessage,
  }) {
    pageState = PageStatus.failure;
    errorMessage = _resolveMessage(
      dioError: dioError,
      genericError: genericError,
    );
  }

  static String resolveMessage({DioException? dioError, Object? genericError}) {
    return _resolveMessage(dioError: dioError, genericError: genericError);
  }

  static String _resolveMessage({
    DioException? dioError,
    Object? genericError,
  }) {
    if (dioError != null) {
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Koneksi timeout, periksa jaringan Anda";

        case DioExceptionType.connectionError:
          return "Tidak ada koneksi internet";

        case DioExceptionType.badResponse:
          return _resolveStatusCode(dioError.response);

        default:
          return "Terjadi kesalahan, coba lagi";
      }
    }

    debugPrint("Unexpected error: $genericError");
    return "Terjadi kesalahan tidak terduga";
  }

  static String _resolveStatusCode(Response? response) {
    if (response == null) return "Tidak ada respons dari server";

    switch (response.statusCode) {
      case 400:
        return response.data?['message'] ?? "Request tidak valid";
      case 401:
        return "Sesi habis, silakan login kembali";
      case 403:
        return "Anda tidak memiliki akses";
      case 404:
        return "Data tidak ditemukan";
      case 422:
        return response.data?['message'] ?? "Data tidak valid";
      case 500:
        return "Server sedang bermasalah, coba beberapa saat lagi";
      default:
        return "Error ${response.statusCode}";
    }
  }
}
