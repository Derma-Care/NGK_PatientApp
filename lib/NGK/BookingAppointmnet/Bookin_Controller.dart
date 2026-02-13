import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Booking_Model.dart';
import 'BookingService.dart';

class BookingController extends GetxController {
  RxList<BookingModel> bookings = <BookingModel>[].obs;

  RxBool isLoading = true.obs;
  RxString error = ''.obs;
  RxInt currentPage = 1.obs;
  // PAGINATION
  RxInt itemsPerPage = 5.obs;
  RxInt pendingPage = 1.obs;
  RxInt completedPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt pendingTotalPages = 1.obs;
  RxInt completedTotalPages = 1.obs;

  // 🔹 Fetch bookings from backend
  Future<void> fetchBookings() async {
    print("🔥 fetchBookings() CALLED");

    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customer_Id') ?? "";

    print("🔥 customerId = $customerId");

    if (customerId.isEmpty) {
      print("❌ customerId is EMPTY. API will NOT be called");
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      print("🔥 Calling API now...");
      final data = await BookingService.getBookingsByCustomer(customerId);

      print("🔥 API returned ${data.length} bookings");

      bookings.assignAll(data);
      print("🔥 Stored bookings length: ${bookings.length}");
      print(
          "🔥 Stored bookings length: ${bookings.first.procedures?.first.procedureName}");
    } catch (e) {
      print("❌ fetchBookings error: $e");
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 Filter + pagination
  List<BookingModel> getFiltered(String tabStatus) {
    List<BookingModel> filtered;

    if (tabStatus == "Pending") {
      filtered =
          bookings.where((b) => b.status.toUpperCase() == "CONFIRMED").toList();
    } else {
      filtered =
          bookings.where((b) => b.status.toUpperCase() == "COMPLETED").toList();
    }

    if (filtered.isEmpty) return [];

    final int perPage = itemsPerPage.value;
    final int totalItems = filtered.length;

    int page = tabStatus == "Pending" ? pendingPage.value : completedPage.value;

    final int total = (totalItems / perPage).ceil();
    page = page.clamp(1, total);

    final int start = (page - 1) * perPage;
    final int end = (start + perPage).clamp(0, totalItems);

    if (start >= totalItems) return [];

    return filtered.sublist(start, end);
  }

  void nextPage(String status) {
    if (status == "Pending") {
      if (pendingPage.value < totalPages.value) pendingPage.value++;
    } else {
      if (completedPage.value < totalPages.value) completedPage.value++;
    }
  }

  void prevPage(String status) {
    if (status == "Pending") {
      if (pendingPage.value > 1) pendingPage.value--;
    } else {
      if (completedPage.value > 1) completedPage.value--;
    }
  }

  void resetPage(String status) {
    if (status == "Pending") {
      pendingPage.value = 1;
    } else {
      completedPage.value = 1;
    }

    updateTotalPages(status);
  }

  void refreshData(String status) async {
    // reset page
    if (status == "Pending") {
      pendingPage.value = 1;
    } else {
      completedPage.value = 1;
    }

    // simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    fetchBookings(); // or API call
  }

  void changeItemsPerPage(int value, String status) {
    itemsPerPage.value = value;

    if (status == "Pending") {
      pendingPage.value = 1;
    } else {
      completedPage.value = 1;
    }

    updateTotalPages(status);
  }

  void goToPage(String status, int page) {
    if (status == "Pending") {
      pendingPage.value = page;
    } else {
      completedPage.value = page;
    }
  }

  void updateTotalPages(String status) {
    List<BookingModel> filtered;

    if (status == "Pending") {
      filtered =
          bookings.where((b) => b.status.toUpperCase() == "CONFIRMED").toList();
    } else {
      filtered =
          bookings.where((b) => b.status.toUpperCase() == "COMPLETED").toList();
    }

    final int total =
        filtered.isEmpty ? 1 : (filtered.length / itemsPerPage.value).ceil();

    totalPages.value = total;
  }
}
