import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiProvider>(ApiProvider(), permanent: true);
  }
}
