import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/SubserviceAndHospital/HospitalCardModel.dart';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'package:http/http.dart' as http;

class HospitalService {

  Future<List<HospitalCardModel>> fetchHospitalCards(
      String hospitalID,
      String subServiceId,
      double lat,
      double long,
  ) async {

    final endpoint =
        "$registerUrl/getBranchesInfoBySubServiceId/"
        "$hospitalID/$subServiceId/$lat/$long";

    final api = Get.find<ApiProvider>().dio;

    debugPrint("📤 Sending GET request to: ${api.options.baseUrl}$endpoint");

    try {
      final response = await api.get(endpoint);

      debugPrint("📥 Response status: ${response.statusCode}");

      final decoded = response.data;

      debugPrint("🔓 Full Decoded Response Type: ${decoded.runtimeType}");
      debugPrint("🔓 Full Decoded Response Content: $decoded");

      if (response.statusCode == 200) {
        // ✅ API returns `data` as a Map
        if (decoded is Map && decoded.containsKey('data')) {
          final Map<String, dynamic> data = decoded['data'];
          debugPrint('📦 Single hospital object found');

          List<HospitalCardModel> result = [];

          String base64Logo = '';
          try {
            final logo = data['hospitalLogo'] ?? '';

            if (logo.startsWith('http')) {
              // 🔹 Keep http.get for image bytes (NO logic change)
              final imageResponse = await http.get(Uri.parse(logo));
              final contentType =
                  imageResponse.headers['content-type'] ?? '';

              if (imageResponse.statusCode == 200 &&
                  contentType.startsWith('image/')) {
                base64Logo = base64Encode(imageResponse.bodyBytes);
              } else {
                debugPrint('⚠️ Invalid image content from URL: $logo');
              }
            } else if (logo.length > 100) {
              base64Logo = logo;
            } else {
              debugPrint('⚠️ Invalid logo format or too short: $logo');
            }
          } catch (imgErr) {
            debugPrint('❌ Error handling logo: $imgErr');
          }

          // 🔹 Debug hospital info
          debugPrint("🏥 Hospital Name: ${data['hospitalName']}");
          debugPrint(
              "📍 Branch Count: ${(data['branches'] as List?)?.length ?? 0}");

          if (data['branches'] != null) {
            for (var branch in data['branches']) {
              debugPrint("  🔗 Branch Name: ${branch['branchName']}");
              debugPrint(
                  "  🌐 Virtual Tour: ${branch['virtualClinicTour']}");
            }
          }

          // ✅ Build model
          result.add(HospitalCardModel.fromJson({
            ...data,
            "hospitalLogo": base64Logo,
          }));

          return result;
        } else {
          debugPrint(
              '⚠️ API response does not have a valid "data" object.');
          throw Exception(
              'Unexpected API response format: $decoded');
        }
      } else {
        final errorMsg =
            decoded['message'] ?? 'Failed to load hospital data.';
        debugPrint('❌ Backend message: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('🔥 Exception caught: $e');
      throw Exception(
          'Error fetching hospital data: ${e.toString()}');
    }
  }
}
