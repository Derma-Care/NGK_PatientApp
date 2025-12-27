import 'package:cutomer_app/NGK/ClinicManagement/ClinicSlotModel.dart';
import 'package:cutomer_app/NGK/ClinicManagement/clinic_slot_service.dart';
import 'package:get/get.dart';

class ClinicSlotController extends GetxController {
  var slots = <ClinicSlotModel>[].obs;
  var isLoading = false.obs;
  var selectedIndex = (-1).obs;

  void fetchSlots(String clinicId) async {
    try {
      isLoading(true);
      slots.value = await ClinicSlotService.getClinicSlots(clinicId);

      // ✅ Auto select today's date
      final today = DateTime.now();

      final todayIndex = slots.indexWhere((slot) {
        final slotDate = DateTime.parse(slot.date);
        return slotDate.year == today.year &&
            slotDate.month == today.month &&
            slotDate.day == today.day &&
            slot.workingHours; // only working day
      });

      if (todayIndex != -1) {
        selectedIndex.value = todayIndex;
      }
    } finally {
      isLoading(false);
    }
  }

  void selectSlot(int index) {
    if (!slots[index].workingHours) return;
    selectedIndex.value = index;
  }
}
