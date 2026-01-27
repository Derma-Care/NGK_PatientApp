import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class PackageService {
  static Future<List<dynamic>> fetchPackages({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      "$registerUrl/procedures/packages"
      "?latitude=$latitude&longitude=$longitude",
    );
    debugPrint("response package url ${url}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['data'] ?? [];
    } else {
      throw Exception("Failed to fetch packages");
    }
  }
}
