import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class CarouselSliderService {
  /// Fetch dashboard image ads (customer side)
  Future<List<String>> fetchImages() async {
    final endpoint = '/api/login/dashboard-ads';
    final api = Get.find<ApiProvider>().dio;

    debugPrint(
        "📤 [CAROUSEL] Fetch images URL: ${api.options.baseUrl}$endpoint");

    try {
      final response = await api.get(endpoint);

      debugPrint("📥 [CAROUSEL] Status: ${response.statusCode}");
      debugPrint("📥 [CAROUSEL] Body: ${response.data}");

      if (response.statusCode == 200) {
        final decoded = response.data;
        final List list = decoded['data']; // ✅ correct path

        return list
            .where((item) => item['type'] == 'image') // optional filter
            .map<String>((item) => item['url'].toString()) // ✅ correct key
            .toList();
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      debugPrint("❌ Error fetching images: $e");
      return [];
    }
  }

  /// Fetch service / admin carousel images
  // Future<List<String>> fetchServiceImages() async {
  //   final endpoint = '/admin/dashboard-ads';
  //   final api = Get.find<ApiProvider>().dio;

  //   debugPrint(
  //       "📤 [CAROUSEL ADMIN] Fetch images URL: ${api.options.baseUrl}$endpoint");

  //   try {
  //     final response = await api.get(endpoint);

  //     debugPrint("📥 [CAROUSEL ADMIN] Status: ${response.statusCode}");
  //     debugPrint("📥 [CAROUSEL ADMIN] Body: ${response.data}");

  //     if (response.statusCode == 200) {
  //       final data = response.data;

  //       List<String> imageUrls = [];

  //       // Extract mediaUrlOrImage from each object
  //       for (var item in data) {
  //         if (item.containsKey('mediaUrlOrImage')) {
  //           imageUrls.add(item['mediaUrlOrImage']);
  //         }
  //       }

  //       debugPrint(
  //           "🖼️ [CAROUSEL ADMIN] imageUrls length: ${imageUrls.length}");

  //       return imageUrls;
  //     } else {
  //       debugPrint(
  //           "❌ [CAROUSEL ADMIN] Status code: ${response.statusCode}");
  //       throw Exception('Failed to load images');
  //     }
  //   } catch (e) {
  //     debugPrint("❌ Error fetching images: $e");
  //     return [];
  //   }
  // }

  Future<List<String>> fetchServiceImages() async {
    final endpoint = '/admin/service-ads';
    final api = Get.find<ApiProvider>().dio;

    try {
      final response = await api.get(endpoint);

      debugPrint("📥 Body: ${response.data}");

      if (response.statusCode == 200) {
        final List list = response.data['data']; // ✅ FIX

        return list
            .where((e) => e['url'] != null)
            .map<String>((e) => e['url'].toString())
            .toList();
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      debugPrint("❌ Error fetching images: $e");
      return [];
    }
  }
}
