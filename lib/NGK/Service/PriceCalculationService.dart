import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/Modals/PriceCalculationModel.dart';
import 'package:http/http.dart' as http;

class PriceCalculationService {
  static Future<PriceCalculationModel> calculatePrice(
      Map<String, dynamic> payload) async {
    final url = "${wifiUrl}/booking/calculate-price";

    // 🔹 PRINT PAYLOAD
    print("📤 PRICE CALCULATION API CALL");
    print("🔗 URL: $url");
    print("📦 PAYLOAD:");
    print(const JsonEncoder.withIndent('  ').convert(payload));

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      // 🔹 PRINT RESPONSE INFO
      print("📥 RESPONSE STATUS: ${response.statusCode}");
      print("📥 RAW RESPONSE BODY:");
      print(response.body);

      final decoded = jsonDecode(response.body);

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
