import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicSlotModel.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'package:cutomer_app/Utils/Constant.dart';

class ClinicSlotService {
  static Future<List<ClinicSlotModel>> getClinicSlots(String clinicId) async {
    final endpoint = "$registerUrl/clinic/slots?clinicId=$clinicId";
    final api = Get.find<ApiProvider>().dio;

    debugPrint("📤 [CLINIC SLOTS API] URL: ${api.options.baseUrl}$endpoint");

    final response = await api.get(endpoint);

    debugPrint("📥 [CLINIC SLOTS API] STATUS: ${response.statusCode}");
    debugPrint("📥 [CLINIC SLOTS API] RAW BODY: ${response.data}");

    if (response.statusCode == 200) {
      final body = response.data;

      debugPrint("🕒 Slots response: $body");

      if (body['success'] == true) {
        final List slots = body['data']['slots'];

        return slots
            .map<ClinicSlotModel>((e) => ClinicSlotModel.fromJson(e))
            .toList();
      } else {
        throw Exception(body['message']);
      }
    } else {
      throw Exception("Failed to load clinic slots");
    }
  }
}
