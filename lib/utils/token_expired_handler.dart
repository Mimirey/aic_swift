import 'package:dio/dio.dart';
import 'package:Swift/config/network/constant_api.dart';
import 'package:Swift/utils/session_manager.dart';

class TokenExpiredInterceptor extends Interceptor {
  static bool _hasRedirected = false;

  static void resetUnauthorizedGuard() {
    _hasRedirected = false;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    final skipRedirect = err.requestOptions.extra["skipAuthRedirect"] == true;

    if (statusCode == 401) {
      if (path == ConstantApi.login) {
        return handler.next(err);
      }

      if (skipRedirect) {
        return handler.next(err);
      }
      if (!_hasRedirected) {
        _hasRedirected = true;

        await SessionManager.clearSession();

        _redirectToLogin();
      }

      return handler.resolve(
        Response(
          requestOptions: err.requestOptions,
          statusCode: 401,
          data: {"status": "unauthorized"},
        ),
      );
    }

    handler.next(err);
  }

  void _redirectToLogin() {
    // AppRouter.router.go(AppRoutes.login);
  }
}
