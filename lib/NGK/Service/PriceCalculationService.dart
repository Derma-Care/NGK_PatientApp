import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/Modals/PriceCalculationModel.dart';
import 'package:http/http.dart' as http;

class PriceCalculationService {
  static Future<PriceCalculationModel> calculatePrice(
      Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse("${wifiUrl}/booking/calculate-price"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      return PriceCalculationModel.fromJson(decoded['data']);
    } else {
      throw Exception(decoded['message'] ?? "Price calculation failed");
    }
  }
}
