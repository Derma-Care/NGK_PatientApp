import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final fullUrl = options.baseUrl + options.path;

    debugPrint('➡️ ${options.method} | $fullUrl');
    debugPrint('HEADERS: ${options.headers}');
    debugPrint('BODY: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final fullUrl =
        response.requestOptions.baseUrl + response.requestOptions.path;

    debugPrint('✅ ${response.statusCode} | $fullUrl');
    debugPrint('RESPONSE: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler handler) {
    final fullUrl = e.requestOptions.baseUrl + e.requestOptions.path;

    debugPrint('❌ ERROR | $fullUrl');
    debugPrint('MESSAGE: ${e.message}');
    debugPrint('DATA: ${e.response?.data}');
    super.onError(e, handler);
  }
}
