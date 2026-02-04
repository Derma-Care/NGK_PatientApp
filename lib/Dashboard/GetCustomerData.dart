// api_service.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/Customers/GetCustomerModel.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

// Define the API call function
Future<GetCustomerModel> fetchUserData(String customerId) async {
  final endpoint = '$registerUrl/id/$customerId';
  final api = Get.find<ApiProvider>().dio;

  debugPrint("🔍 URL: ${api.options.baseUrl}$endpoint");

  try {
    final response = await api.get(endpoint);

    debugPrint("🔍 StatusCode: ${response.statusCode}");
    debugPrint("📦 Response Data: ${response.data}");

    if (response.statusCode == 200) {
      final responseData = response.data;

      // Debug full response
      debugPrint("👤 User Data Response: $responseData");

      // Convert JSON → Model
      return GetCustomerModel.fromJson(responseData);
    } else {
      throw Exception('Failed to load user data');
    }
  } catch (e) {
    debugPrint("❌ Error fetching user data: $e");
    throw Exception('Error fetching user data');
  }
}
