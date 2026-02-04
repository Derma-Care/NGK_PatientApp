import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class CustomerService {

  static Future<CustomerProfileModel?> getCustomer(String mobile) async {
    debugPrint("📤 calling getCustomer: $mobile");

    final endpoint = "/api/customer/$mobile";
    final api = Get.find<ApiProvider>().dio;

    final response = await api.get(endpoint);

    debugPrint("📥 getCustomer response status: ${response.statusCode}");
    debugPrint("📥 getCustomer response body: ${response.data}");

    if (response.statusCode == 200) {
      final body = response.data;

      if (body["success"] == true && body["data"] != null) {
        return CustomerProfileModel.fromJson(body["data"]);
      }
    }

    return null;
  }
}
