import 'package:cutomer_app/NGK/BookingAppointmnet/Bookin_Controller.dart';
import 'package:cutomer_app/NGK/BookingAppointmnet/Booking_Model.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
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
    controller.loadDummyData();
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
            child: ListView.builder(
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
                              Text(b.title,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              Text("Clinic: ${b.clinicName}",
                                  style:
                                      TextStyle(color: Colors.grey.shade700)),
                              Text("Date: ${b.bookingDate}",
                                  style:
                                      TextStyle(color: Colors.grey.shade700)),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(b.status),
                          backgroundColor: b.status == "Pending"
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

          // PAGINATION BAR
          Obx(() {
            return CommonPaginationBar(
              showPagination: ValueNotifier<bool>(true),
              itemsPerPage: ValueNotifier<int>(controller.itemsPerPage.value),
              currentPage: ValueNotifier<int>(controller.currentPage.value),
              totalPages: ValueNotifier<int>(controller.totalPages.value),
              onItemsPerPageChanged: (val) {
                controller.changeItemsPerPage(val);
              },
              onNext: controller.nextPage,
              onPrev: controller.prevPage,
              onPageSelected: controller.goToPage,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Center(
                  child: Text(
                    b.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                // ALL DETAILS
                _detailRow("Booking ID", b.bookingId),
                _detailRow("Booking Type", b.bookingType),
                if (b.serviceId != null) _detailRow("Service ID", b.serviceId!),
                if (b.subServiceId != null)
                  _detailRow("Subservice ID", b.subServiceId!),

                _detailRow("Customer ID", b.customerId),
                _detailRow("Mobile", b.mobileNumber),

                _detailRow("Clinic", b.clinicName),
                _detailRow("Clinic Address", b.clinicAddress),
                _detailRow("Booking Date", b.bookingDate),

                const Divider(height: 25),

                _detailRow("Price", "₹${b.price}"),
                _detailRow("Discount", "${b.discountPercentage}%"),
                _detailRow("Discount Amount", "₹${b.discountAmount}"),
                _detailRow("Final Amount", "₹${b.finalAmount}"),

                const Divider(height: 25),

                _detailRow("Payment Method", b.paymentMethod),
                _detailRow("Status", b.status),

                const SizedBox(height: 25),

                // SHOW BOOK AGAIN ONLY FOR PENDING BOOKINGS
                if (b.status.toLowerCase() == "completed")
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.snackbar("Booking", "Rebooking action here");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Book Again",
                        style: TextStyle(fontSize: 18)),
                  ),

                const SizedBox(height: 15),
              ],
            ),
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
