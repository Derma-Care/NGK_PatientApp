import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class PackageService {
  static Future<List<ClinicModelWithLocation>> fetchPackagesClinics({
    required double latitude,
    required double longitude,
    required String state,
  }) async {
    final endpoint = "$registerUrl/procedures/packages"
        "?latitude=$latitude"
        "&longitude=$longitude&state=$state";

    final api = Get.find<ApiProvider>().dio;

    debugPrint("📦 [PACKAGE API] URL: ${api.options.baseUrl}$endpoint");

    final response = await api.get(endpoint);

    debugPrint("📦 [PACKAGE API] STATUS: ${response.statusCode}");
    debugPrint("📦 [PACKAGE API] BODY: ${response.data}");

    if (response.statusCode == 200) {
      final List data = response.data['data'] ?? [];

      return data.map((e) => ClinicModelWithLocation.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch packages");
    }
  }
}
