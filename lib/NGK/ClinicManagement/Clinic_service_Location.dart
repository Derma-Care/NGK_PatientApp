import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class ClinicServiceLocation {
  static Future<List<ClinicModelWithLocation>> fetchClinics({
    required double latitude,
    required double longitude,
    required String procedureId,
  }) async {
    final endpoint = "${registerUrl}/procedures/clinics"
        "?latitude=$latitude"
        "&longitude=$longitude"
        "&procedureId=$procedureId";

    final api = Get.find<ApiProvider>().dio;

    debugPrint("📤 [CLINIC API] URL: ${api.options.baseUrl}$endpoint");

    final response = await api.get(endpoint);

    debugPrint("📥 [CLINIC API] STATUS: ${response.statusCode}");
    debugPrint("📥 [CLINIC API] RAW BODY ↓↓↓");

    const encoder = JsonEncoder.withIndent('  ');
    debugPrint(encoder.convert(response.data));

    final decoded = response.data;

    // Always check data exists
    if (decoded['data'] != null &&
        decoded['data'].isNotEmpty &&
        decoded['data'][0]['procedurePricing'] != null) {
      final procedurePricing = decoded['data'][0]['procedurePricing'];

      debugPrint(
          "💰 Procedure Pricing ↓↓↓\n${encoder.convert(procedurePricing)}");
    } else {
      debugPrint("❌ procedurePricing not found");
    }

    if (response.statusCode == 200) {
      final List list = decoded['data'];
      return list.map((e) => ClinicModelWithLocation.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load clinics");
    }
  }
}
