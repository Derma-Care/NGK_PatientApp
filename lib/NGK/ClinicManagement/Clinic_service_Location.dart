import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
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
    print("response clinic url ${url}");

    final response = await http.get(url);
    print("response clinic ${response.body}");
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'];
      return list.map((e) => ClinicModelWithLocation.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load clinics");
    }
  }
}
