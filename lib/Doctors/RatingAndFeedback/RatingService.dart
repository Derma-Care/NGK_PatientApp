import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
 
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'RatingModal.dart'; // Your model



/// ✅ Safely fetches ratings for a given doctor.
/// If no ratings exist, returns an empty [RatingSummary] with 0 ratings (no crash).
Future<RatingSummary> fetchAndSetRatingSummary(
    String branchId, String doctorId) async {
  final url =
      Uri.parse('$wifiUrl/api/customer/getAverageRatingByDoctorId/$doctorId');

  

  print("🔎 Fetching ratings for doctor $doctorId from: $url");

  try {
    final response = await http.get(url);

    print("📡 API Response Status: ${response.statusCode}");
    print("📡 API Raw Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print("📦 Parsed JSON: $jsonResponse");

      final success = jsonResponse['success'] == true;
      final data = jsonResponse['data'];

      if (success && data != null) {
        final dataMap = Map<String, dynamic>.from(data);
        print("🔧 dataMap after conversion: $dataMap");

        if (dataMap['comments'] != null && dataMap['comments'] is List) {
          dataMap['comments'] = (dataMap['comments'] as List)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          print("💬 Parsed Comments Count: ${dataMap['comments'].length}");
        }

        final ratingSummary = RatingSummary.fromJson(dataMap);
        print(
            "✅ Ratings fetched for doctor: ${ratingSummary.doctorId}, Rating: ${ratingSummary.overallDoctorRating}, Comments: ${ratingSummary.comments.length}");



        return ratingSummary;
      } else {
        print("⚠️ API success=false or data=null -> Returning empty summary");
        return RatingSummary.empty(branchId, doctorId);
      }
    } else {
      print("❌ HTTP error: ${response.statusCode} ${response.reasonPhrase}");
      return RatingSummary.empty(branchId, doctorId);
    }
  } catch (e) {
    print("❌ Exception while fetching ratings: $e");
    return RatingSummary.empty(branchId, doctorId);
  }
}
