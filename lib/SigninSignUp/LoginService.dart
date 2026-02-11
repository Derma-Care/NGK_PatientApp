import 'dart:convert';
import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../Utils/ShowSnackBar.dart';

class LoginApiService {
  final String endpoint = "/api/auth/send-otp";

  Future<Map<String, dynamic>> sendUserDataWithFCMToken(
    String fullname,
    String mobileNumber,
    String token,
  ) async {
    try {
      final api = Get.find<ApiProvider>().dio;

      final response = await api.post(
        endpoint,
        data: {
          'mobile': mobileNumber,
        },
      );

      return {
        'statusCode': response.statusCode,
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final data = e.response?.data;

      return {
        'statusCode': e.response?.statusCode ?? 500,
        'message': data?['message'] ??
            "Unable to connect to server. Please try again.",
      };
    }
  }
}
