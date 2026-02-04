import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/Modals/ServiceModal.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

Future<SubService?> fetchSubServiceDetails(
    String hospitalId, String subServiceId) async {

  final endpoint =
      '$getSubServiceByServiceIDHospitalID/$hospitalId/$subServiceId';
  final api = Get.find<ApiProvider>().dio;

  debugPrint(
      '🔍 Calling: ${api.options.baseUrl}$endpoint');

  try {
    final response = await api.get(endpoint);

    debugPrint('🔁 Status: ${response.statusCode}');
    debugPrint('📦 Full Response JSON: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 302) {
      final decoded = response.data;
      final data = decoded['data'];

      if (data != null) {
        debugPrint(
            '✅ SubService Name: ${data['subServiceName']}');
        return SubService.fromJson(data);
      } else {
        debugPrint("❗ 'data' not found");
        return null;
      }
    } else {
      debugPrint('❌ HTTP error: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    debugPrint('❌ Exception: $e');
    return null;
  }
}
