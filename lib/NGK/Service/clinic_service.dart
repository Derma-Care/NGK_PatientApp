import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/Modals/clinic_model.dart';
import 'package:cutomer_app/NGK/Packges/PackageModel.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class ClinicService {
  // ---------------- NEARBY CLINICS ----------------
  static Future<List<ClinicModelWithLocation>> fetchNearbyClinics({
    required double lat,
    required double lng,
    required String state,
  }) async {
    final endpoint =
        "$registerUrl/clinics/nearby?latitude=$lat&longitude=$lng&state=$state";
    final api = Get.find<ApiProvider>().dio;

    try {
      final response = await api.get(endpoint);

      debugPrint("CLINIC API STATUS: ${response.statusCode}");
      debugPrint("CLINIC API BODY: ${response.data}");

      if (response.statusCode == 200) {
        final body = response.data;
        final data = body['data'];

        if (data == null || data is! List) return [];

        return data
            .map<ClinicModelWithLocation>(
                (e) => ClinicModelWithLocation.fromJson(e))
            .toList();
      }

      // 🔴 BACKEND BUG CASE (distance = "4 KM")
      if (response.statusCode == 400) {
        final body = response.data;
        final msg = body['message'] ?? "";

        if (msg.toString().contains("KM")) {
          debugPrint("Backend distance format error ignored");
          return [];
        }
      }

      return [];
    } catch (e) {
      debugPrint("Clinic API Exception: $e");
      return [];
    }
  }

  static Future<List<PackageModel>> fetchPackagesByClinicId({
    required String clinicId,
  }) async {
    final endpoint = "/clinic-admin/packages/clinic/$clinicId";
    final api = Get.find<ApiProvider>().dio;

    try {
      final response = await api.get(endpoint);

      debugPrint("PACKAGE API STATUS: ${response.statusCode}");
      debugPrint("PACKAGE API BODY: ${response.data}");

      if (response.statusCode == 200) {
        final body = response.data;
        final data = body['data'];
        debugPrint("PACKAGE API BODY INSIDE: ${data}");

        if (data == null || data is! List) return [];

        return data
            .map<PackageModel>((e) => PackageModel.fromDirectApi(e))
            .toList();
      }

      // 🔴 BACKEND BUG CASE (distance = "4 KM")
      if (response.statusCode == 400) {
        final body = response.data;
        final msg = body['message'] ?? "";

        if (msg.toString().contains("KM")) {
          debugPrint("Backend distance format error ignored");
          return [];
        }
      }

      return [];
    } catch (e) {
      debugPrint("Clinic API Exception: $e");
      return [];
    }
  }

  // ---------------- CLINIC BY ID ----------------
  static Future<ClinicModelWithLocation> fetchClinicById(
      String clinicId) async {
    final endpoint = "/admin/clinics/get/$clinicId";
    final api = Get.find<ApiProvider>().dio;

    final response = await api.get(endpoint);

    if (response.statusCode != 200) {
      throw Exception("Failed to load clinic details");
    }

    final body = response.data;
    return ClinicModelWithLocation.fromJson(body['data']);
  }

  // ---------------- CLINIC SERVICES ----------------
  static Future<ClinicServicesResponse> fetchClinicServices(
      String clinicId) async {
    final endpoint = "/api/customer/clinics/$clinicId/details";
    final api = Get.find<ApiProvider>().dio;

    final response = await api.get(endpoint);

    if (response.statusCode == 200) {
      final body = response.data;
      return ClinicServicesResponse.fromJson(body['data']);
    }

    throw Exception("Failed to load services");
  }

  // ---------------- CLINIC SERVICES OFFERS ----------------
  static Future<ClinicServicesResponse> fetchClinicServicesOffers(
      String clinicId) async {
    final endpoint = "/api/customer/offers/clinics/$clinicId";
    final api = Get.find<ApiProvider>().dio;

    final response = await api.get(endpoint);

    if (response.statusCode == 200) {
      final body = response.data;
      return ClinicServicesResponse.fromJson(body['data']);
    }

    throw Exception("Failed to load services");
  }

  // ---------------- NEARBY CLINICS WITH OFFERS ----------------
  static Future<List<ClinicModelWithLocation>> fetchNearbyClinicsWithOffers({
    required double lat,
    required double lng,
    required String state,
  }) async {
    final endpoint =
        "$registerUrl/offers/clinics/nearby?latitude=$lat&longitude=$lng&state=$state";
    final api = Get.find<ApiProvider>().dio;

    try {
      final response = await api.get(endpoint);

      debugPrint("CLINIC API STATUS: ${response.statusCode}");
      debugPrint("CLINIC API BODY: ${response.data}");

      if (response.statusCode == 200) {
        final body = response.data;
        final data = body['data'];

        if (data == null || data is! List) return [];

        return data
            .map<ClinicModelWithLocation>(
                (e) => ClinicModelWithLocation.fromJson(e))
            .toList();
      }

      // 🔴 BACKEND BUG CASE (distance = "4 KM")
      if (response.statusCode == 400) {
        final body = response.data;
        final msg = body['message'] ?? "";

        if (msg.toString().contains("KM")) {
          debugPrint("Backend distance format error ignored");
          return [];
        }
      }

      return [];
    } catch (e) {
      debugPrint("Clinic API Exception: $e");
      return [];
    }
  }

  // ---------------- PROCEDURE PRICING ----------------
  static Future<ProcedureListModal> getProcedurePricingWithClinicId({
    required String clinicId,
    required String procedureId,
  }) async {
    final endpoint = "$clinicUrl/procedure-pricing/get/$procedureId/$clinicId";
    final api = Get.find<ApiProvider>().dio;

    debugPrint(
        "📤 URL getProcedurePricingWithClinicId: ${api.options.baseUrl}$endpoint");

    final response = await api.get(endpoint);

    if (response.statusCode == 200) {
      final body = response.data;
      final data = body['data'] ?? body;
      return ProcedureListModal.fromJson(data);
    } else {
      throw Exception(
        "Failed to fetch procedure pricing (${response.statusCode})",
      );
    }
  }

  // ---------------- PACKAGE PRICING ----------------
  static Future<PackageModel> getPackagePricingWithClinicId({
    required String clinicId,
    required String packageId,
  }) async {
    final endpoint = "$clinicUrl/packages/clinic/$clinicId/$packageId";
    final api = Get.find<ApiProvider>().dio;

    debugPrint(
        "📤 URL getPackagePricingWithClinicId: ${api.options.baseUrl}$endpoint");

    final response = await api.get(endpoint);

    if (response.statusCode == 200) {
      final body = response.data;
      final data = body['data'] ?? body;

      debugPrint("📦 Package pricing data: $data");

      return PackageModel.fromDirectApi(data);
    } else {
      throw Exception(
        "Failed to fetch procedure pricing (${response.statusCode})",
      );
    }
  }
}
