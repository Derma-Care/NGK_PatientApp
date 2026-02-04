import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class PackageService {
  static Future<List<dynamic>> fetchPackages({
    required double latitude,
    required double longitude,
  }) async {
    final endpoint = "$registerUrl/procedures/packages"
        "?latitude=$latitude"
        "&longitude=$longitude";

    final api = Get.find<ApiProvider>().dio;

    debugPrint("📦 [PACKAGE API] URL: ${api.options.baseUrl}$endpoint");

    final response = await api.get(endpoint);

    debugPrint("📦 [PACKAGE API] STATUS: ${response.statusCode}");
    debugPrint("📦 [PACKAGE API] BODY: ${response.data}");

    if (response.statusCode == 200) {
      final decoded = response.data;
      return decoded['data'] ?? [];
    } else {
      throw Exception("Failed to fetch packages");
    }
  }
}
