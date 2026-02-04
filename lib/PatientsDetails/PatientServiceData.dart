import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/PatientsDetails/PatientModelData.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

Future<List<PatientData>> fetchPatients(
    String patientId, String clinicId) async {

  final endpoint =
      "$clinicUrl/bookings/byInput/$patientId/$clinicId";
  final api = Get.find<ApiProvider>().dio;

  debugPrint("📤 Fetching patients URL: ${api.options.baseUrl}$endpoint");

  try {
    final response = await api.get(endpoint);

    debugPrint("📥 Fetch patients status: ${response.statusCode}");
    debugPrint("📥 Fetch patients body: ${response.data}");

    if (response.statusCode == 200) {
      final decoded = response.data;
      final List data = decoded["data"];

      return data
          .map<PatientData>(
              (e) => PatientData.fromJson(e))
          .toList();
    } else {
      throw Exception(
          "Failed with status code ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("⚠️ Error fetching patients: $e");
    return [];
  }
}
