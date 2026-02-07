import 'dart:typed_data';
 
import 'BaseUrl.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class ServiceFetcher {
 
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
