import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/ClinicManagement/clinic_service_Location.dart';
import 'package:get/get.dart';
 

class ClinicControllerLocation extends GetxController {
  RxList<ClinicModelWithLocation> clinicList = <ClinicModelWithLocation>[].obs;
  RxBool isLoading = false.obs;

  int currentPage = 1;
  int itemsPerPage = 10;
  int totalPages = 1;

  Future<void> loadClinics({
    required double latitude,
    required double longitude,
    required String procedureId,
  }) async {
    try {
      isLoading.value = true;
      final clinics = await ClinicServiceLocation.fetchClinics(
        latitude: latitude,
        longitude: longitude,
        procedureId: procedureId,
      );
      clinicList.assignAll(clinics);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
