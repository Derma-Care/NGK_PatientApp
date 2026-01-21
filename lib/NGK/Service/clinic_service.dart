import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/Modals/clinic_model.dart';
import 'package:cutomer_app/NGK/Packges/PackageModel.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';
import 'package:http/http.dart' as http;

class ClinicService {
  static Future<List<ClinicModelWithLocation>> fetchNearbyClinics({
    required double lat,
    required double lng,
  }) async {
    final url = "${registerUrl}/clinics/nearby?latitude=$lat&longitude=$lng";

    try {
      final response = await http.get(Uri.parse(url));

      print("CLINIC API STATUS: ${response.statusCode}");
      print("CLINIC API BODY: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final data = body['data'];

        if (data == null || data is! List) {
          return [];
        }

        return data
            .map<ClinicModelWithLocation>(
                (e) => ClinicModelWithLocation.fromJson(e))
            .toList();
      }

      // 🔴 BACKEND BUG CASE (distance = "4 KM")
      if (response.statusCode == 400) {
        final body = jsonDecode(response.body);
        final msg = body['message'] ?? "";

        if (msg.toString().contains("KM")) {
          print("Backend distance format error ignored");
          return [];
        }
      }

      return [];
    } catch (e) {
      print("Clinic API Exception: $e");
      return [];
    }
  }

  static Future<ClinicModelWithLocation> fetchClinicById(
      String clinicId) async {
    final url = "$wifiUrl/admin/clinics/get/$clinicId";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Failed to load clinic details");
    }

    final body = jsonDecode(response.body);

    return ClinicModelWithLocation.fromJson(body['data']);
  }

  static Future<ClinicServicesResponse> fetchClinicServices(
      String clinicId) async {
    final url = Uri.parse("${wifiUrl}/api/customer/clinics/$clinicId/details");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return ClinicServicesResponse.fromJson(body['data']);
    }

    throw Exception("Failed to load services");
  }

  static Future<ClinicServicesResponse> fetchClinicServicesOffers(
      String clinicId) async {
    final url = Uri.parse("${wifiUrl}/api/customer/offers/clinics/$clinicId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return ClinicServicesResponse.fromJson(body['data']);
    }

    throw Exception("Failed to load services");
  }

  static Future<List<ClinicModelWithLocation>> fetchNearbyClinicsWithOffers({
    required double lat,
    required double lng,
  }) async {
    final url =
        "${registerUrl}/offers/clinics/nearby?latitude=$lat&longitude=$lng";

    try {
      final response = await http.get(Uri.parse(url));

      print("CLINIC API STATUS: ${response.statusCode}");
      print("CLINIC API BODY: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final data = body['data'];

        if (data == null || data is! List) {
          return [];
        }

        return data
            .map<ClinicModelWithLocation>(
                (e) => ClinicModelWithLocation.fromJson(e))
            .toList();
      }

      // 🔴 BACKEND BUG CASE (distance = "4 KM")
      if (response.statusCode == 400) {
        final body = jsonDecode(response.body);
        final msg = body['message'] ?? "";

        if (msg.toString().contains("KM")) {
          print("Backend distance format error ignored");
          return [];
        }
      }

      return [];
    } catch (e) {
      print("Clinic API Exception: $e");
      return [];
    }
  }

//Rebooking TODO:Provide customer Url

  static Future<ProcedureListModal> getProcedurePricingWithClinicId({
    required String clinicId,
    required String procedureId,
  }) async {
    final url = Uri.parse(
      "$clinicUrl/procedure-pricing/get/$procedureId/$clinicId",
    );

    print("📤 URL getProcedurePricingWithClinicId: $url");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      /// If API wraps data inside "data"
      final data = body['data'] ?? body;

      return ProcedureListModal.fromJson(data);
    } else {
      throw Exception(
        "Failed to fetch procedure pricing (${response.statusCode})",
      );
    }
  }

  static Future<PackageModel> getPackagePricingWithClinicId({
    required String clinicId,
    required String packageId,
  }) async {
    final url = Uri.parse(
      "$clinicUrl/packages/clinic/$clinicId/$packageId",
    );

    print("📤 URL getProcedurePricingWithClinicId: $url");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      /// If API wraps data inside "data"
      final data = body['data'] ?? body;
      print("📤 URL getProcedurePricingWithClinicId: $data");

      return PackageModel.fromDirectApi(data);
    } else {
      throw Exception(
        "Failed to fetch procedure pricing (${response.statusCode})",
      );
    }
  }
}
