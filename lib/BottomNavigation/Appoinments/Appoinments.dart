import 'package:cutomer_app/NGK/BookingAppointmnet/Bookin_Controller.dart';
import 'package:cutomer_app/NGK/BookingAppointmnet/Booking_Model.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/Review/hospital_rating_screen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
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
                                "₹${(b.finalAmount.toStringAsFixed(0)) ?? 0}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: mainColor,
                                ),
                              ),
                              Text(
                                "${b.serviceType.toLowerCase()}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _statusChip(b.status),
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
