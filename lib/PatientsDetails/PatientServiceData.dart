import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/PatientsDetails/PatientModelData.dart';
import 'package:http/http.dart' as http;

Future<List<PatientData>> fetchPatients(
    String patientId, String clinicId) async {
   String url = "${clinicUrl}/bookings/byInput/${patientId}/${clinicId}";
  print("fetching patients: $url");
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded["data"];
      return data.map((e) => PatientData.fromJson(e)).toList();
    } else {
      throw Exception("Failed with status code ${response.statusCode}");
    }
  } catch (e) {
    print("⚠️ Error fetching patients: $e");
    return [];
  }
}
