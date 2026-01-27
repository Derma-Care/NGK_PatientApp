import 'package:cutomer_app/NGK/BookingAppointmnet/Bookin_Controller.dart';
import 'package:cutomer_app/NGK/BookingAppointmnet/Booking_Model.dart';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Service/clinic_service.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/NGK/Widgets/PackageBookingSheet.dart';
import 'package:cutomer_app/Review/hospital_rating_screen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/FirstLatterCap.dart';
import 'package:cutomer_app/Utils/MapOnGoogle.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingListScreen extends StatefulWidget {
  final int initialTabIndex; // ✅ NEW
  const BookingListScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final BookingController controller = Get.put(BookingController());
  // late String fullname;

  @override
  void initState() {
    super.initState();
    // _loadCustomerNameFromPrefs();
    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        if (tabController.index == 0) {
          controller.resetPage("Pending");
        } else {
          controller.resetPage("Completed");
        }
      }
    });

    controller.fetchBookings();
    ;
  }

  // Future<void> _loadCustomerNameFromPrefs() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final savedName = prefs.getString('customer_full_name');

  //   if (savedName != null) {
  //     setState(() {
  //       fullname = savedName;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: mainColor,
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildList("Pending"),
          _buildList("Completed"),
        ],
      ),
    );
  }

  Widget _buildList(String status) {
    return Obx(() {
      /// 🔄 SHOW LOADER FIRST
      if (controller.isLoading.value) {
        return const Center(
          child: const Center(
            child: SpinKitFadingCircle(
              color: mainColor,
              size: 40,
            ),
          ),
        );
      }
      final paginatedList = controller.getFiltered(status);

      if (paginatedList.isEmpty) {
        return Center(
          child: Text(
            "No $status Appointments",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: mainColor,
              onRefresh: () async => controller.refreshData(status),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: paginatedList.length,
                itemBuilder: (context, index) {
                  final b = paginatedList[index];
                  double getDisplayAmount() {
                    // If fully paid → always show final amount
                    if (b.paymentStatus == "PAID") {
                      return b.finalAmount ?? 0;
                    }

                    // If payment is due
                    if (b.paymentStatus == "DUE") {
                      // Full payment selected
                      if (b.paymentType == "FULL_PAYMENT") {
                        return b.finalAmount ?? 0;
                      }

                      // Partial payment selected and percentage valid
                      if (b.paymentType == "PARTIAL_PAYMENT" &&
                          (b.partialPaymentPercentage ?? 0) > 0) {
                        return b.partialAmount ?? 0;
                      }
                    }

                    // Fallback
                    return b.finalAmount ?? 0;
                  }

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showBookingDetails(context, b),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _getStatusBorderColor(b.status),
                          width: 1.3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusBorderColor(b.status)
                                .withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ICON
                          // Container(
                          //   padding: const EdgeInsets.all(12),
                          //   decoration: BoxDecoration(
                          //     color: Colors.pink.shade50,
                          //     borderRadius: BorderRadius.circular(14),
                          //   ),
                          //   child: Icon(
                          //     Icons.calendar_month,
                          //     color: mainColor,
                          //     size: 26,
                          //   ),
                          // ),
                          // const SizedBox(width: 12),

                          /// DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.fullName ?? '',
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.healing,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        b.serviceName ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.local_hospital,
                                        size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        b.clinicName ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.event,
                                        size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      b.appointmentDate ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: 1,
                            height: 90, // 👈 adjust if needed
                            color: Colors.grey.shade300,
                          ),

                          /// PRICE + STATUS
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₹${getDisplayAmount().toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: mainColor,
                                ),
                              ),
                              Text(
                                capitalizeFirst(b.serviceType),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _statusChip(b.status),
                              const SizedBox(height: 8),
                              Text(
                                "${capitalizeFirst(b.paymentStatus)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          /// PAGINATION BAR
          Obx(() {
            return CommonPaginationBar(
              showPagination: ValueNotifier<bool>(true),
              itemsPerPage: ValueNotifier<int>(controller.itemsPerPage.value),
              currentPage: ValueNotifier<int>(
                status == "Pending"
                    ? controller.pendingPage.value
                    : controller.completedPage.value,
              ),
              totalPages: ValueNotifier<int>(controller.totalPages.value),
              onNext: () => controller.nextPage(status),
              onPrev: () => controller.prevPage(status),
              onPageSelected: (page) => controller.goToPage(status, page),
              onItemsPerPageChanged: (val) {
                controller.changeItemsPerPage(val);
              },
            );
          }),
        ],
      );
    });
  }

  Widget _statusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "CONFIRMED":
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case "COMPLETED":
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case "CANCELLED":
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case "CONFIRMED":
        return Colors.orange;
      case "COMPLETED":
        return Colors.green;
      case "CANCELLED":
        return Colors.red;
      case "PENDING":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showBookingDetails(BuildContext context, BookingModel b) {
    Future<void> handleBookAgain(BuildContext context, BookingModel b) async {
      if (b.clinicId == null || b.serviceId == null) {
        Get.snackbar("Error", "Invalid booking data");
        return;
      }

      try {
        /// 🔹 PROCEDURE FLOW
        if (b.serviceType.toLowerCase() == "procedure") {
          final pricing = await ClinicService.getProcedurePricingWithClinicId(
            clinicId: b.clinicId!, // make sure this exists in BookingModel
            procedureId: b.serviceId!, // serviceId = procedureId
          );

          /// ✅ Convert API response → PaymentModal
          final payment = PaymentModal.fromProcedure(pricing);

          debugPrint("========== PROCEDURE PAYMENT ==========");
          debugPrint(payment.toJson().toString());
          debugPrint("======================================");

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => PackageBookingSheet(
              payment: payment,
              info:
                  "The price shown is the latest price as of today and may differ from your earlier appointment.",
            ),
          );
        }

        /// 🔹 PACKAGE FLOW
        else if (b.serviceType.toLowerCase() == "package") {
          final pricing = await ClinicService.getPackagePricingWithClinicId(
            clinicId: b.clinicId!, // make sure this exists in BookingModel
            packageId: b.serviceId!, // serviceId = procedureId
          );
          debugPrint("%%%%  : ${pricing.consultationFee.toString()}");
          final payment = PaymentModal.fromPackage(pricing);

          debugPrint("========== PACKAGE PAYMENT ==========");
          debugPrint(payment.toJson().toString());
          debugPrint("====================================");

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => PackageBookingSheet(
              payment: payment,
              info:
                  "The price shown is the latest price as of today and may differ from your earlier appointment.",
            ),
          );
        }
        print("PACKAGE PAYMENT ${b.serviceType}");
      } catch (e) {
        debugPrint("BOOK AGAIN ERROR: $e");
        Get.snackbar("Error", "Unable to rebook. Please try again");
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8, // ✅ 80% height
          child: Column(
            children: [
              // 🔹 Drag Handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // 🔹 Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          b.serviceName ?? "",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _detailRow("Booking ID", b.bookingId),
                      _detailRow(
                          "Booking Type", capitalizeFirst(b.serviceType)),
                      // if (b.serviceId != null)
                      //   _detailRow("Service ID", b.serviceId!),

                      // _detailRow("Customer ID", b.customerId),
                      _detailRow("Mobile", b.mobileNumber),

                      _detailRow("Clinic", b.clinicName),
                      _detailRow(
                        "Clinic Address",
                        b.clinicAddress,
                        onTap: () {
                          if (b.clinicAddress.isNotEmpty) {
                            MapUtils.openMapByAddress(b.clinicAddress);
                          }
                        },
                      ),

                      _detailRow("Booking Date", b.appointmentDate),

                      const Divider(height: 25),

                      _detailRow("Price", "₹${b.price.toStringAsFixed(0)}"),

                      _detailRow("consultation Fee",
                          "₹ ${b.consultationFee?.toStringAsFixed(0)}"),
                      _detailRow("Gst(${b.gst?.toStringAsFixed(0)}%)",
                          "₹ ${b.gstAmount?.toStringAsFixed(0)}"),
                      if ((b.taxAmount ?? 0) > 0)
                        _detailRow(
                          "Tax (${b.taxPercentage}%)",
                          "₹ ${b.taxAmount?.toStringAsFixed(0)}",
                        ),

                      _detailRow(
                        "Platform Fee",
                        "₹ ${b.platformFee.toStringAsFixed(0)}",
                      ),

                      if ((b.discountAmount ?? 0) > 0)
                        _detailRow(
                          "Discount (${b.totalDiscountPercentage}%)",
                          "-₹ ${b.discountAmount.toStringAsFixed(0)}",
                        ),

                      if ((b.redeemedPoints ?? 0) > 0)
                        _detailRow(
                          "Used Coins",
                          "₹ ${b.redeemedPoints}",
                        ),

                      _detailRow("Final Amount",
                          "₹ ${b.finalAmount.toStringAsFixed(0)}"),

                      if (b.paymentType == "PARTIAL_PAYMENT")
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Partial Payment Details",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _detailRow(
                                "You Paid",
                                "₹ ${b.partialAmount.toStringAsFixed(0)}",
                              ),
                              _detailRow(
                                "Amount to Pay",
                                "₹ ${b.dueAmount.toStringAsFixed(0)}",
                              ),
                            ],
                          ),
                        ),

                      const Divider(height: 25),

                      _detailRow("Payment Type", b.paymentType),
                      _detailRow("Payment Method", b.paymentMode ?? "_"),
                      _detailRow("Payment Staus", b.paymentStatus),
                      _detailRow("Status", b.status),

                      const Divider(height: 25),

                      // 🔹 Package Procedures Accordion
                      // if (b.serviceType.toLowerCase() == "package" &&
                      //     b.procedures != null)
                      if (b.serviceType.toLowerCase() == "package" &&
                          b.procedures != null &&
                          b.procedures!.isNotEmpty)
                        ExpansionTile(
                          title: const Text(
                            "Package Procedures",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          leading: const Icon(
                            Icons.medical_services_outlined,
                            color: mainColor,
                          ),
                          children: b.procedures!.map((p) {
                            return ListTile(
                              leading: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 18,
                              ),
                              title: Text(
                                p.procedureName,
                                style: const TextStyle(fontSize: 13),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: mainColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${p.noOfSittings} sittings",
                                  style: const TextStyle(
                                    color: mainColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 80), // 🔥 space for fixed buttons
                    ],
                  ),
                ),
              ),

              // 🔹 FIXED BOTTOM BUTTONS
              if (b.status == "COMPLETED")
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            handleBookAgain(context, b);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            minimumSize: const Size(0, 50),
                          ),
                          child: const Text(
                            "Book Again",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (b.isRated ?? false)
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HospitalRatingScreen(
                                        hospitalName: b.clinicName,
                                        bookingId: b.bookingId,
                                        hospitalLogo: b.hospitalLogo ?? "",
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (b.isRated ?? false)
                                ? Colors.grey.shade400
                                : Colors.pink,
                            minimumSize: const Size(0, 50),
                          ),
                          child: Text(
                            (b.isRated ?? false) ? "Rated" : "Rate",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onTap, // 👈 ONLY triggers on user click
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 15,
                  color: onTap != null ? Colors.blue : Colors.black,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
