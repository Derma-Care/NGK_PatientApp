import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ClinicServiceLocation {
  static Future<List<ClinicModelWithLocation>> fetchClinics({
    required double latitude,
    required double longitude,
    required String procedureId,
  }) async {
    final url = Uri.parse(
      "${registerUrl}/procedures/clinics"
      "?latitude=$latitude&longitude=$longitude&procedureId=$procedureId",
    );
    debugPrint("response clinic url ${url}");

    final response = await http.get(url);
    debugPrint("response clinic ${response.body}");
    final decoded = jsonDecode(response.body);

// Always check data exists
    if (decoded['data'] != null &&
        decoded['data'].isNotEmpty &&
        decoded['data'][0]['procedurePricing'] != null) {
      final procedurePricing = decoded['data'][0]['procedurePricing'];

      const encoder = JsonEncoder.withIndent('  ');
      debugPrint("Procedure Pricing:\n${encoder.convert(procedurePricing)}");
    } else {
      debugPrint("❌ procedurePricing not found");
    }
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'];
      return list.map((e) => ClinicModelWithLocation.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load clinics");
    }
  }
}
