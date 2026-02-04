import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class CustomerDataBasicInfo {

  // Fetch basic customer data
  Future<Map<String, dynamic>?> fetchCustomerDataData(
      String mobileNumber) async {

    final endpoint = "/admin/getBasicCustomerDetails/$mobileNumber";
    final api = Get.find<ApiProvider>().dio;

    debugPrint("📤 Requesting: ${api.options.baseUrl}$endpoint");

    try {
      final response = await api.get(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint(
          "📥 Response Status provider: ${response.statusCode}");
      debugPrint(
          "📥 Response Body provider: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        return Map<String, dynamic>.from(data);
      } else {
        debugPrint(
            "❌ Error: ${response.statusMessage}");
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      debugPrint("⚠️ Exception caught: $e");
      return null;
    }
  }
}
