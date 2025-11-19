import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:http/http.dart' as http;

class ReportService {
  Future<Map<String, dynamic>?> getCustomerReports(String customerId) async {
    final String url = "$registerUrl/getReports/$customerId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']; // return only useful data
        } else {
          print("API returned success = false");
          return null;
        }
      } else {
        print("Failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching reports: $e");
      return null;
    }
  }
}
