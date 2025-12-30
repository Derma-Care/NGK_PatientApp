import 'package:cutomer_app/NGK/BookingAppointmnet/Bookin_Controller.dart';
import 'package:cutomer_app/NGK/BookingAppointmnet/Booking_Model.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/Review/hospital_rating_screen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final BookingController controller = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
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
              onRefresh: () async =>
                  controller.refreshData(status), // 👈 key line
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(), // REQUIRED
                padding: const EdgeInsets.all(12),
                itemCount: paginatedList.length,
                itemBuilder: (context, index) {
                  final b = paginatedList[index];

                  return GestureDetector(
                    onTap: () => _showBookingDetails(context, b),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.calendar_month,
                                color: mainColor, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.serviceName ?? '',
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold)),
                                Text("Clinic: ${b.clinicName}",
                                    style:
                                        TextStyle(color: Colors.grey.shade700)),
                                Text("Date: ${b.appointmentDate}",
                                    style:
                                        TextStyle(color: Colors.grey.shade700)),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(b.status),
                            backgroundColor: b.status == "CONFIRMED"
                                ? Colors.orange.shade100
                                : Colors.green.shade100,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // PAGINATION BAR
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
          })
        ],
      );
    });
  }

  void _showBookingDetails(BuildContext context, BookingModel b) {
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
                      _detailRow("Booking Type", b.serviceType),
                      if (b.serviceId != null)
                        _detailRow("Service ID", b.serviceId!),

                      // _detailRow("Customer ID", b.customerId),
                      _detailRow("Mobile", b.mobileNumber),

                      _detailRow("Clinic", b.clinicName),
                      _detailRow("Clinic Address", b.clinicAddress),
                      _detailRow("Booking Date", b.appointmentDate),

                      const Divider(height: 25),

                      _detailRow("Price", "₹${b.price}"),

                      _detailRow("consultation Fee", "₹ ${b.consultationFee}"),
                      _detailRow("Gst(${b.gst}%)", "₹ ${b.gstAmount}"),
                      if ((b.taxAmount ?? 0) > 0)
                        _detailRow(
                          "Tax (${b.taxPercentage}%)",
                          "₹ ${b.taxAmount}",
                        ),

                      if ((b.discountAmount ?? 0) > 0)
                        _detailRow(
                          "Discount (${b.discount}%)",
                          "₹ ${b.discountAmount}",
                        ),

                      _detailRow("Final Amount", "₹ ${b.finalAmount}"),

                      const Divider(height: 25),

                      _detailRow("Payment Method", b.paymentType),
                      _detailRow("Status", b.status),

                      const Divider(height: 25),

                      // 🔹 Package Procedures Accordion
                      if (b.serviceType == "package" && b.procedures != null)
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
                                  "${p.sittings} sittings",
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
                            Get.snackbar("Booking", "Rebooking action here");
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
                                      builder: (_) =>
                                          const HospitalRatingScreen(
                                        hospitalName:
                                            "Neeha Skin & Hair Clinic",
                                        hospitalLogo:
                                            "https://marketplace.canva.com/EAGFJn_CyD4/2/0/1600w/canva-green-and-white-modern-medical-logo-Tl9mfMCsEVQ.jpg",
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

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
