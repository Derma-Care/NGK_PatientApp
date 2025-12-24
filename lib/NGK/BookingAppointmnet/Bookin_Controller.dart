import 'package:cutomer_app/NGK/BookingAppointmnet/Booking_Model.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  RxList<BookingModel> bookings = <BookingModel>[].obs;

  // PAGINATION
  // RxInt itemsPerPage = 5.obs;
  RxInt currentPage = 1.obs;
  // RxInt totalPages = 1.obs;

  void loadDummyData() {
    bookings.value = [
      BookingModel(
        bookingId: "BKG001",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "procedure",
        serviceId: "SVC001",
        subServiceId: "SUB001",
        title: "Glow Facial",
        clinicId: "CL001",
        clinicName: "Derma Clinic Madhapur",
        clinicAddress: "Madhapur, Hyderabad",
        bookingDate: "2025-12-01",
        price: 2000,
        discountPercentage: 10,
        discountAmount: 200,
        finalAmount: 1800,
        paymentMethod: "Razorpay",
        status: "Pending",
        isRated: false,
      ),
      BookingModel(
        bookingId: "BKG002",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "package",
        serviceId: "SVC002",
        subServiceId: "SUB002",
        title: "Advanced Skin Care Package",
        clinicId: "CL002",
        clinicName: "Advanced Derma Clinic",
        clinicAddress: "Kondapur, Hyderabad",
        bookingDate: "2025-12-03",
        price: 15000,
        discountPercentage: 30,
        discountAmount: 4500,
        finalAmount: 10500,
        paymentMethod: "Razorpay",
        status: "Completed",
        isRated: true,
        procedures: [
          ProcedureSittingModel(procedureName: "Chemical Peel", sittings: 2),
          ProcedureSittingModel(procedureName: "PRP Treatment", sittings: 3),
        ],
      ),
      BookingModel(
        bookingId: "BKG003",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "procedure",
        serviceId: "SVC003",
        subServiceId: "SUB003",
        title: "Acne Treatment",
        clinicId: "CL003",
        clinicName: "Skin Care Clinic",
        clinicAddress: "Gachibowli, Hyderabad",
        bookingDate: "2025-12-05",
        price: 6000,
        discountPercentage: 15,
        discountAmount: 900,
        finalAmount: 5100,
        paymentMethod: "Cash",
        status: "Pending",
        isRated: false,
      ),
      BookingModel(
        bookingId: "BKG004",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "package",
        serviceId: "SVC004",
        subServiceId: "SUB004",
        title: "Hair Regrowth Package",
        clinicId: "CL004",
        clinicName: "Hair Care Clinic",
        clinicAddress: "Ameerpet, Hyderabad",
        bookingDate: "2025-12-06",
        price: 18000,
        discountPercentage: 20,
        discountAmount: 3600,
        finalAmount: 14400,
        paymentMethod: "UPI",
        status: "Pending",
        isRated: false,
        procedures: [
          ProcedureSittingModel(procedureName: "PRP Hair Therapy", sittings: 3),
          ProcedureSittingModel(procedureName: "Scalp Treatment", sittings: 1),
        ],
      ),
      BookingModel(
        bookingId: "BKG005",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "procedure",
        serviceId: "SVC005",
        subServiceId: "SUB005",
        title: "Hydra Facial",
        clinicId: "CL001",
        clinicName: "Derma Clinic Madhapur",
        clinicAddress: "Madhapur, Hyderabad",
        bookingDate: "2025-12-07",
        price: 3500,
        discountPercentage: 10,
        discountAmount: 350,
        finalAmount: 3150,
        paymentMethod: "UPI",
        status: "Completed",
        isRated: true,
      ),
      BookingModel(
        bookingId: "BKG006",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "package",
        serviceId: "SVC006",
        subServiceId: "SUB006",
        title: "Anti Aging Package",
        clinicId: "CL005",
        clinicName: "Glow Skin Clinic",
        clinicAddress: "HiTech City, Hyderabad",
        bookingDate: "2025-12-08",
        price: 22000,
        discountPercentage: 25,
        discountAmount: 5500,
        finalAmount: 16500,
        paymentMethod: "Razorpay",
        status: "Completed",
        isRated: false,
        procedures: [
          ProcedureSittingModel(procedureName: "Botox", sittings: 1),
          ProcedureSittingModel(procedureName: "Fillers", sittings: 1),
        ],
      ),
      BookingModel(
        bookingId: "BKG007",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "procedure",
        serviceId: "SVC007",
        subServiceId: "SUB007",
        title: "Pigmentation Treatment",
        clinicId: "CL006",
        clinicName: "Derma Skin Clinic",
        clinicAddress: "Begumpet, Hyderabad",
        bookingDate: "2025-12-09",
        price: 7000,
        discountPercentage: 10,
        discountAmount: 700,
        finalAmount: 6300,
        paymentMethod: "Cash",
        status: "Pending",
        isRated: false,
      ),
      BookingModel(
        bookingId: "BKG008",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "package",
        serviceId: "SVC008",
        subServiceId: "SUB008",
        title: "Bridal Glow Package",
        clinicId: "CL007",
        clinicName: "Rejuvenate Clinic",
        clinicAddress: "Banjara Hills, Hyderabad",
        bookingDate: "2025-12-10",
        price: 25000,
        discountPercentage: 30,
        discountAmount: 7500,
        finalAmount: 17500,
        paymentMethod: "Razorpay",
        status: "Pending",
        isRated: false,
        procedures: [
          ProcedureSittingModel(
              procedureName: "Laser Hair Removal", sittings: 3),
          ProcedureSittingModel(procedureName: "Glow Facial", sittings: 2),
        ],
      ),
      BookingModel(
        bookingId: "BKG009",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "procedure",
        serviceId: "SVC009",
        subServiceId: "SUB009",
        title: "Dark Circle Treatment",
        clinicId: "CL008",
        clinicName: "Eye Care Clinic",
        clinicAddress: "Kukatpally, Hyderabad",
        bookingDate: "2025-12-11",
        price: 5000,
        discountPercentage: 20,
        discountAmount: 1000,
        finalAmount: 4000,
        paymentMethod: "UPI",
        status: "Completed",
        isRated: true,
      ),
      BookingModel(
        bookingId: "BKG010",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "package",
        serviceId: "SVC010",
        subServiceId: "SUB010",
        title: "Complete Skin Care Package",
        clinicId: "CL009",
        clinicName: "Care Plus Clinic",
        clinicAddress: "Miyapur, Hyderabad",
        bookingDate: "2025-12-12",
        price: 28000,
        discountPercentage: 35,
        discountAmount: 9800,
        finalAmount: 18200,
        paymentMethod: "Razorpay",
        status: "Pending",
        isRated: false,
        procedures: [
          ProcedureSittingModel(procedureName: "Laser Treatment", sittings: 3),
          ProcedureSittingModel(procedureName: "PRP Treatment", sittings: 2),
          ProcedureSittingModel(procedureName: "Glow Facial", sittings: 2),
        ],
      ),
      BookingModel(
        bookingId: "BKG011",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "procedure",
        serviceId: "SVC011",
        subServiceId: "SUB011",
        title: "Skin Polishing",
        clinicId: "CL010",
        clinicName: "Urban Skin Clinic",
        clinicAddress: "Jubilee Hills, Hyderabad",
        bookingDate: "2025-12-13",
        price: 3000,
        discountPercentage: 10,
        discountAmount: 300,
        finalAmount: 2700,
        paymentMethod: "Cash",
        status: "Completed",
        isRated: true,
      ),
      BookingModel(
        bookingId: "BKG012",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "package",
        serviceId: "SVC012",
        subServiceId: "SUB012",
        title: "Hair + Skin Combo Package",
        clinicId: "CL011",
        clinicName: "Elite Care Clinic",
        clinicAddress: "LB Nagar, Hyderabad",
        bookingDate: "2025-12-14",
        price: 20000,
        discountPercentage: 20,
        discountAmount: 4000,
        finalAmount: 16000,
        paymentMethod: "UPI",
        status: "Pending",
        isRated: false,
        procedures: [
          ProcedureSittingModel(procedureName: "PRP Hair Therapy", sittings: 3),
          ProcedureSittingModel(procedureName: "Hydra Facial", sittings: 1),
        ],
      ),
      BookingModel(
        bookingId: "BKG013",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "procedure",
        serviceId: "SVC013",
        subServiceId: "SUB013",
        title: "Skin Brightening",
        clinicId: "CL012",
        clinicName: "Glow Aesthetics",
        clinicAddress: "Secunderabad",
        bookingDate: "2025-12-15",
        price: 4500,
        discountPercentage: 15,
        discountAmount: 675,
        finalAmount: 3825,
        paymentMethod: "Razorpay",
        status: "Pending",
        isRated: false,
      ),
      BookingModel(
        bookingId: "BKG014",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "package",
        serviceId: "SVC014",
        subServiceId: "SUB014",
        title: "Ultimate Hair Care Package",
        clinicId: "CL013",
        clinicName: "Hair Plus Clinic",
        clinicAddress: "Mehdipatnam, Hyderabad",
        bookingDate: "2025-12-16",
        price: 24000,
        discountPercentage: 30,
        discountAmount: 7200,
        finalAmount: 16800,
        paymentMethod: "Razorpay",
        status: "Completed",
        isRated: true,
        procedures: [
          ProcedureSittingModel(procedureName: "PRP Hair Therapy", sittings: 3),
          ProcedureSittingModel(procedureName: "Scalp Treatment", sittings: 2),
        ],
      ),
      BookingModel(
        bookingId: "BKG015",
        customerId: "CUS001",
        mobileNumber: "7842243333",
        bookingType: "package",
        serviceId: "SVC015",
        subServiceId: "SUB015",
        title: "Premium Glow Package",
        clinicId: "CL014",
        clinicName: "Premium Derma Clinic",
        clinicAddress: "Film Nagar, Hyderabad",
        bookingDate: "2025-12-17",
        price: 26000,
        discountPercentage: 35,
        discountAmount: 9100,
        finalAmount: 16900,
        paymentMethod: "Razorpay",
        status: "Pending",
        isRated: false,
        procedures: [
          ProcedureSittingModel(procedureName: "Laser Treatment", sittings: 3),
          ProcedureSittingModel(procedureName: "Glow Facial", sittings: 2),
        ],
      ),
    ];

    _updateTotalPages();
  }

  // FILTER + PAGINATION
  RxInt pendingPage = 1.obs;
  RxInt completedPage = 1.obs;

  RxInt itemsPerPage = 5.obs;
  RxInt totalPages = 1.obs;

  // List<BookingModel> bookings = [];

  void refreshData(String status) async {
    // reset page
    if (status == "Pending") {
      pendingPage.value = 1;
    } else {
      completedPage.value = 1;
    }

    // simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    loadDummyData(); // or API call
  }

  List<BookingModel> getFiltered(String status) {
    final filtered = bookings.where((b) => b.status == status).toList();

    final currentPage =
        status == "Pending" ? pendingPage.value : completedPage.value;

    totalPages.value = (filtered.length / itemsPerPage.value).ceil();

    final start = (currentPage - 1) * itemsPerPage.value;
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

  void goToPage(String status, int page) {
    if (status == "Pending") {
      pendingPage.value = page;
    } else {
      completedPage.value = page;
    }
  }

  void resetPage(String status) {
    if (status == "Pending") {
      pendingPage.value = 1;
    } else {
      completedPage.value = 1;
    }
  }

  void changeItemsPerPage(int value) {
    itemsPerPage.value = value;
    currentPage.value = 1;
    _updateTotalPages();
  }

  void _updateTotalPages([int? length]) {
    final count = length ?? bookings.length;
    totalPages.value = (count / itemsPerPage.value).ceil();
  }
}
