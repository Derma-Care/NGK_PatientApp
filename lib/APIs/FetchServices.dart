import 'dart:convert';
import 'dart:typed_data';

import '../Modals/ServiceModal.dart';
import 'BaseUrl.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class ServiceFetcher {
  // ---------------- FETCH SERVICES ----------------
  Future<List<Service>> fetchServices(String categoryId) async {
    debugPrint("🔄 Sending request to categoryId: $categoryId");

    final endpoint = '$getServiceByCategoriesID/$categoryId';
    final api = Get.find<ApiProvider>().dio;

    try {
      debugPrint("🔄 Sending request to URL: ${api.options.baseUrl}$endpoint");

      final response = await api.get(endpoint);

      debugPrint("📦 API response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 302) {
        final decodedResponse = response.data;
        debugPrint("🧩 Decoded JSON: $decodedResponse");

        if (decodedResponse['data'] is List) {
          final List<dynamic> data = decodedResponse['data'];
          debugPrint("✅ Data length: ${data.length}");

          return data.map<Service>((json) {
            try {
              return Service.fromJson(json);
            } catch (e) {
              debugPrint("❌ Error parsing service: $e");
              return Service(
                serviceId: '',
                serviceName: '',
                categoryName: '',
                categoryId: '',
                description: '',
                serviceImage: Uint8List(0),
              );
            }
          }).toList();
        } else {
          debugPrint('❗ Error: "data" is not a list');
          return [];
        }
      } else {
        debugPrint('❗ Error: ${response.statusMessage}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Exception fetching services: $e');
      return [];
    }
  }

  // ---------------- FETCH SUB SERVICES ----------------
  Future<List<SubServiceAdmin>> fetchsubServices(String serviceId) async {
    final endpoint = '$getSubServiceByServiceID/$serviceId';
    final api = Get.find<ApiProvider>().dio;

    debugPrint("🔄 Sending request to URL: ${api.options.baseUrl}$endpoint");

    try {
      final response = await api.get(endpoint);
      debugPrint("📦 Response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 302) {
        final decodedResponse = response.data;
        final List<dynamic> data = decodedResponse['data'];

        if (data is List) {
          final allSubServices = data
              .expand((category) => category['subServices'] as List<dynamic>)
              .map((json) {
                try {
                  return SubServiceAdmin.fromJson(json);
                } catch (e) {
                  debugPrint("❌ Parse error: $e");
                  return null;
                }
              })
              .whereType<SubServiceAdmin>()
              .toList();

          return allSubServices;
        } else {
          debugPrint("❗ 'data' is not a list");
          return [];
        }
      } else {
        debugPrint("❗ HTTP error: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Exception during fetch: $e");
      return [];
    }
  }

  // ---------------- FETCH ALL PROCEDURES ----------------
  static Future<List<ProcedureNameModel>> fetchAllProcedures() async {
    final api = Get.find<ApiProvider>().dio;
    final endpoint = "/api/customer/procedures";

    try {
      final response = await api.get(endpoint);

      if (response.statusCode == 200) {
        final decoded = response.data;
        final List data = decoded['data'] ?? [];

        return data
            .map<ProcedureNameModel>((e) => ProcedureNameModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("❌ Error fetching procedures: $e");
    }

    return [];
  }

  // ---------------- FETCH PROCEDURE OFFERS ----------------
  static Future<List<ProcedureOffer>> fetchAllProceduresOffers() async {
    final api = Get.find<ApiProvider>().dio;
    final endpoint = "/api/customer/procedures/offers";

    try {
      final response = await api.get(endpoint);

      if (response.statusCode == 200) {
        final decoded = response.data;
        final List data = decoded['data'];

        debugPrint("📦 Procedures offers count: ${data.length}");

        return data
            .map<ProcedureOffer>((e) => ProcedureOffer.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("❌ Error fetching procedure offers: $e");
    }

    return [];
  }
}

class ProcedureNameModel {
  final String procedureId;
  final String procedureName;

  ProcedureNameModel({
    required this.procedureId,
    required this.procedureName,
  });

  factory ProcedureNameModel.fromJson(Map<String, dynamic> json) {
    return ProcedureNameModel(
      procedureId: json['procedureId']?.toString() ?? '',
      procedureName: json['procedureName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'procedureId': procedureId,
      'procedureName': procedureName,
    };
  }
}

class ProcedureOffer {
  final String procedureId;
  final String name;
  final int minOffer;
  final int maxOffer;

  ProcedureOffer({
    required this.procedureId,
    required this.name,
    required this.minOffer,
    required this.maxOffer,
  });

  factory ProcedureOffer.fromJson(Map<String, dynamic> json) {
    return ProcedureOffer(
      procedureId: json['procedureId'],
      name: json['procedureName'],
      minOffer: json['minOffer'],
      maxOffer: json['maxOffer'],
    );
  }
}
