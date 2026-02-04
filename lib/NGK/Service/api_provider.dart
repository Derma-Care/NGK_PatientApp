import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/service/api_logger.dart';
 
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiProvider {
  late Dio dio;

  ApiProvider() {
    dio = Dio(
      BaseOptions(
        baseUrl: wifiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(ApiLogger());
  }
}
