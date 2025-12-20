import 'package:dio/dio.dart';
import 'package:beadneko/core/event_bus.dart';
import 'package:beadneko/enums.dart';
import 'package:beadneko/utils/sp_util.dart';

class AuthInterceptor extends Interceptor {
  static bool isRefreshing = false;
  static List<Map<String, dynamic>> requestList = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(
      "Authorization",
      () => 'Bearer ${SPUtil.getAccessToken()}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      EventBus().fire(AuthEvent.unauthenticated);
    }
    super.onError(err, handler);
  }
}
