import 'dart:convert';
import 'package:cutomer_app/NGK/Modals/PriceCalculationModel.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'package:get/get.dart';

class PriceCalculationService {

  static Future<PriceCalculationModel> calculatePrice(
      Map<String, dynamic> payload) async {

    final endpoint = "/booking/calculate-price";

    // 🔹 PRINT PAYLOAD
    print("📤 PRICE CALCULATION API CALL");
    print("🔗 URL: $endpoint");
    print("📦 PAYLOAD:");
    print(const JsonEncoder.withIndent('  ').convert(payload));

    final api = Get.find<ApiProvider>().dio;

    try {
      final response = await api.post(
        endpoint,
        data: payload,
      );

      // 🔹 PRINT RESPONSE INFO
      print("📥 RESPONSE STATUS: ${response.statusCode}");
      print("📥 RAW RESPONSE BODY:");
      print(response);

      final decoded = response.data;

      // 🔹 PRINT DECODED RESPONSE
      print("📥 DECODED RESPONSE:");
      print(const JsonEncoder.withIndent('  ').convert(decoded));

      if (response.statusCode == 200 && decoded['success'] == true) {
        print("✅ PRICE CALCULATION SUCCESS");
        return PriceCalculationModel.fromJson(decoded['data']);
      } else {
        print("❌ PRICE CALCULATION FAILED");
        print("⚠️ MESSAGE: ${decoded['message']}");
        throw Exception(decoded['message'] ?? "Price calculation failed");
      }
    } catch (e, stack) {
      print("🔥 EXCEPTION IN PRICE CALCULATION");
      print("❌ ERROR: $e");
      print("📍 STACK TRACE:");
      print(stack);
      rethrow;
    }
  }
}
