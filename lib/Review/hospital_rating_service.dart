import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class HospitalRatingService {

  static Future<Map<String, dynamic>> fetchClinicRatings(
      String clinicId) async {

    final endpoint = "/booking/ratings/clinic/$clinicId";
    final api = Get.find<ApiProvider>().dio;

    debugPrint(
        "📤 [CLINIC RATINGS] URL: ${api.options.baseUrl}$endpoint");

    final response = await api.get(endpoint);

    debugPrint(
        "📥 [CLINIC RATINGS] STATUS: ${response.statusCode}");
    debugPrint(
        "📥 [CLINIC RATINGS] BODY: ${response.data}");

    if (response.statusCode == 200) {
      final decoded = response.data;
      return decoded['data'];
    } else {
      throw Exception("Failed to load clinic ratings");
    }
  }
}
