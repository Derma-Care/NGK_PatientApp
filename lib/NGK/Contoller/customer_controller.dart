import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:cutomer_app/NGK/Service/customer_service.dart';
import 'package:get/get.dart';

class CustomerGetController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<CustomerProfileModel?> customer = Rx<CustomerProfileModel?>(null);

  Future<void> fetchCustomer(String mobileNumber) async {
    try {
      isLoading.value = true;
      final result = await CustomerService.getCustomer(mobileNumber);
      customer.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}
