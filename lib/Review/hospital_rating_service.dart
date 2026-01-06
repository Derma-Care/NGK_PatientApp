import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:http/http.dart' as http;

class HospitalRatingService {
   

  static Future<Map<String, dynamic>> fetchClinicRatings(
      String clinicId) async {
    final url = Uri.parse("$wifiUrl/booking/ratings/clinic/$clinicId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['data'];
    } else {
      throw Exception("Failed to load clinic ratings");
    }
  }
}
