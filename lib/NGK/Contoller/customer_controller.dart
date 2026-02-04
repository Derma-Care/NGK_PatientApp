import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:cutomer_app/NGK/service/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerGetController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<CustomerProfileModel?> customer = Rx<CustomerProfileModel?>(null);

  Future<void> fetchCustomer(String mobileNumber) async {
    try {
      isLoading.value = true;
      final result = await CustomerService.getCustomer(mobileNumber);

      debugPrint("👤 Customer API result: $result");

      customer.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}
