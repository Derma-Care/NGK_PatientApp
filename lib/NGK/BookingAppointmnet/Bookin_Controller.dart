import 'package:cutomer_app/NGK/BookingAppointmnet/Booking_Model.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  RxList<BookingModel> bookings = <BookingModel>[].obs;

  // PAGINATION
  RxInt itemsPerPage = 5.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;

  void loadDummyData() {
    bookings.value = List.generate(20, (index) {
      return BookingModel(
        bookingId: "BKG$index",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: index % 2 == 0 ? "procedure" : "package",
        serviceId: "SVC$index",
        subServiceId: "SUB$index",
        title: "Glow Facial $index",
        clinicId: "CL$index",
        clinicName: "Derma Clinic $index",
        clinicAddress: "Madhapur, Hyderabad",
        bookingDate: "2025-12-${(index % 28) + 1}",
        price: 2000,
        discountPercentage: 20,
        discountAmount: 400,
        finalAmount: 1600,
        paymentMethod: "Razorpay",
        status: index % 2 == 0 ? "Pending" : "Completed",
      );
    });

    _updateTotalPages();
  }

  // FILTER + PAGINATION
  List<BookingModel> getFiltered(String status) {
    final list = bookings
        .where((b) => b.status.toLowerCase() == status.toLowerCase())
        .toList();

    _updateTotalPages(list.length);

    int start = (currentPage.value - 1) * itemsPerPage.value;
    int end = start + itemsPerPage.value;

    if (start >= list.length) return [];

    return list.sublist(start, end > list.length ? list.length : end);
  }

  void changeItemsPerPage(int value) {
    itemsPerPage.value = value;
    currentPage.value = 1;
    _updateTotalPages();
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    currentPage.value = page;
  }

  void _updateTotalPages([int? length]) {
    final count = length ?? bookings.length;
    totalPages.value = (count / itemsPerPage.value).ceil();
  }
}
