import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'RatingModal.dart';

/// ✅ Safely fetches ratings for a given doctor.
/// If no ratings exist, returns an empty [RatingSummary] with 0 ratings (no crash).
Future<RatingSummary> fetchAndSetRatingSummary(
    String branchId, String doctorId) async {

  final endpoint =
      '/api/customer/getAverageRatingByDoctorId/$doctorId';
  final api = Get.find<ApiProvider>().dio;

  debugPrint(
      "🔎 Fetching ratings for doctor $doctorId from: ${api.options.baseUrl}$endpoint");

  try {
    final response = await api.get(endpoint);

    debugPrint("📡 API Response Status: ${response.statusCode}");
    debugPrint("📡 API Raw Body: ${response.data}");

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      debugPrint("📦 Parsed JSON: $jsonResponse");

      final success = jsonResponse['success'] == true;
      final data = jsonResponse['data'];

      if (success && data != null) {
        final dataMap = Map<String, dynamic>.from(data);
        debugPrint("🔧 dataMap after conversion: $dataMap");

        if (dataMap['comments'] != null && dataMap['comments'] is List) {
          dataMap['comments'] = (dataMap['comments'] as List)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          debugPrint(
              "💬 Parsed Comments Count: ${dataMap['comments'].length}");
        }

        final ratingSummary = RatingSummary.fromJson(dataMap);

        debugPrint(
            "✅ Ratings fetched for doctor: ${ratingSummary.doctorId}, "
            "Rating: ${ratingSummary.overallDoctorRating}, "
            "Comments: ${ratingSummary.comments.length}");

        return ratingSummary;
      } else {
        debugPrint(
            "⚠️ API success=false or data=null -> Returning empty summary");
        return RatingSummary.empty(branchId, doctorId);
      }
    } else {
      debugPrint(
          "❌ HTTP error: ${response.statusCode} ${response.statusMessage}");
      return RatingSummary.empty(branchId, doctorId);
    }
  } catch (e) {
    debugPrint("❌ Exception while fetching ratings: $e");
    return RatingSummary.empty(branchId, doctorId);
  }
}
