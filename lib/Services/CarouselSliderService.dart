import 'package:cutomer_app/NGK/Modals/ClinicAdModel.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/NGK/service/api_provider.dart';

class CarouselSliderService {
  /// Fetch dashboard image ads (customer side)
  Future<List<ClinicAdModel>> fetchImages() async {
    final endpoint = '/api/login/dashboard-ads';
    final api = Get.find<ApiProvider>().dio;

    debugPrint("📤 Fetch images URL: ${api.options.baseUrl}$endpoint");

    try {
      final response = await api.get(endpoint);

      debugPrint("📥 Status: ${response.statusCode}");
      debugPrint("📥 Body: ${response.data}");

      if (response.statusCode == 200) {
        final List list = response.data['data'];

        return list.map((item) => ClinicAdModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      debugPrint("❌ Error fetching images: $e");
      return [];
    }
  }

  Future<List<ClinicAdModel>> fetchServiceImages() async {
    final endpoint = '/admin/service-ads';
    final api = Get.find<ApiProvider>().dio;

    try {
      final response = await api.get(endpoint);

      if (response.statusCode == 200) {
        final List list = response.data['data'];

        return list.map((e) => ClinicAdModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load ads');
      }
    } catch (e) {
      debugPrint("❌ Error fetching ads: $e");
      return [];
    }
  }
}
