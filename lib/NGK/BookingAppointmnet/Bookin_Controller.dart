import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Booking_Model.dart';
import 'BookingService.dart';

class BookingController extends GetxController {
  RxList<BookingModel> bookings = <BookingModel>[].obs;

  RxBool isLoading = false.obs;
  RxString error = ''.obs;
  RxInt currentPage = 1.obs;
  // PAGINATION
  RxInt itemsPerPage = 5.obs;
  RxInt pendingPage = 1.obs;
  RxInt completedPage = 1.obs;
  RxInt totalPages = 1.obs;

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

      _updateTotalPages(data.length);
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
    print("tabStatus ${tabStatus}");
    if (tabStatus == "Pending") {
      // Upcoming / confirmed bookings
      print("filtered Bookings1 ${bookings}");

      filtered =
          bookings.where((b) => b.status.toUpperCase() == "CONFIRMED").toList();

      print("filtered Bookings ${filtered}");
    } else {
      // Will show only AFTER backend sends COMPLETED
      filtered =
          bookings.where((b) => b.status.toUpperCase() == "COMPLETED").toList();
    }

    final page =
        tabStatus == "Pending" ? pendingPage.value : completedPage.value;

    final start = (page - 1) * itemsPerPage.value;
    final end = start + itemsPerPage.value;

    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
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
    _updateTotalPages(bookings.length);
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

  void changeItemsPerPage(int value) {
    itemsPerPage.value = value;
    pendingPage.value = 1;
    completedPage.value = 1;
    _updateTotalPages(bookings.length);
  }

  void goToPage(String status, int page) {
    if (status == "Pending") {
      pendingPage.value = page;
    } else {
      completedPage.value = page;
    }
  }

  void _updateTotalPages(int length) {
    totalPages.value = (length / itemsPerPage.value).ceil();
  }
}
