import 'dart:convert';
import 'package:cutomer_app/APIs/FetchServices.dart';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureController.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';
import 'package:cutomer_app/NGK/Procedures/procedure_details_modal.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/NGK/Widgets/FiltterButtons.dart';
import 'package:cutomer_app/NGK/Widgets/PackageBookingSheet.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class SubServiceListScreen extends StatefulWidget {
  final bool hideHeader;
  final bool isClinic;
  final ProcedureNameModel? mainProcedures;
  SubServiceListScreen(
      {this.hideHeader = false, this.isClinic = false, this.mainProcedures});
  @override
  State<SubServiceListScreen> createState() => _SubServiceListScreenState();
}

class _SubServiceListScreenState extends State<SubServiceListScreen> {
  final Procedurecontroller controller = Procedurecontroller();
  late ScrollController scrollController;
  ValueNotifier<bool> showPagination = ValueNotifier(true);
  final TextEditingController searchController = TextEditingController();

  double lastOffset = 0;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    controller.fetchSubServices();
  }

  void _onScroll() {
    double offset = scrollController.offset;

    if (offset > lastOffset) {
      // USER SCROLLED DOWN → HIDE PAGINATION
      if (showPagination.value == true) showPagination.value = false;
    } else {
      // USER SCROLLED UP → SHOW PAGINATION
      if (showPagination.value == false) showPagination.value = true;
    }

    lastOffset = offset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: widget.hideHeader
          ? null
          : CommonHeader(title: widget.mainProcedures?.procedureName),
      body: Column(
        children: [
          SizedBox(height: 10),
          // ---------------------- SEARCH BAR ----------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                controller.applySearch(value);
                setState(() {}); // to update clear button visibility
              },
              decoration: InputDecoration(
                hintText: "Search procedures...",
                prefixIcon: Icon(Icons.search),

                // ------- CLEAR BUTTON --------
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          searchController.clear(); // clear text
                          controller.applySearch(""); // reset search
                          setState(() {}); // refresh UI
                        },
                      )
                    : null,

                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(height: 10),

          // ---------------------- FILTER BUTTONS ----------------------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                !widget.isClinic
                    ? filterButton("Near Me", controller)
                    : const SizedBox(),
                filterButton("High Discount", controller),
                filterButton("Low Price", controller),
                filterButton("High Price", controller),
                !widget.isClinic
                    ? filterButton("Rating", controller)
                    : const SizedBox(),
              ],
            ),
          ),

          SizedBox(height: 10),

          // ---------------------- MAIN LIST ----------------------
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: controller.loading,
              builder: (context, loading, _) {
                if (loading)
                  return Center(
                    child: SpinKitFadingCircle(
                      color: mainColor,
                      size: 40.0,
                    ),
                  );

                return ValueListenableBuilder(
                  valueListenable: controller.procedureList,
                  builder: (context, list, _) {
                    if (list.isEmpty) {
                      return Center(child: Text("No procedures found"));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.all(12),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final service = list[index];

                        return InkWell(
                          onTap: () {
                            Get.to(
                                () => ProcedureDetailsPage(service: service));
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // 🔥 OFFER RIBBON
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(16),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "${service.discountPercentage}% OFF",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),

                                // MAIN CONTENT
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 🔥 Gradient header with icon
                                      SizedBox(height: 10),
                                      Container(
                                        padding: EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.healing,
                                                color: mainColor, size: 26),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                service.subServiceName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Clinic name + rating
                                      widget.isClinic
                                          ? SizedBox(
                                              // child: Center(
                                              //     child: Text(
                                              //       "Hurry! Offer ends on 12 Dec 2025",
                                              //       style: TextStyle(
                                              //         fontSize: 15,
                                              //         fontWeight: FontWeight.w600,
                                              //         color: Colors.grey[700],
                                              //       ),
                                              //     ),
                                              //   ),
                                              )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .local_hospital_sharp,
                                                        color: Colors.amber,
                                                        size: 18),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      "Pragna Advanced Skin Care",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(Icons.star,
                                                        color: Colors.amber,
                                                        size: 18),
                                                    SizedBox(width: 3),
                                                    Text(
                                                      "4.5",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                      SizedBox(height: 12),

                                      // 🔥 OFFER PRICE BOX
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.pink.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.pink.shade100),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Original price
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Original Price",
                                                        style: TextStyle(
                                                            fontSize: 13)),
                                                    Text(
                                                      "₹${service.price}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Colors.redAccent,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // Final price
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text("Now",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                    Text(
                                                      "₹${service.finalCost.toStringAsFixed(0)}",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .pink.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Center(
                                              child: Text(
                                                "ends on 12 Dec 2025",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 12),

                                      // Address + distance
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          !widget.isClinic
                                              ? Row(
                                                  children: [
                                                    Icon(Icons.map,
                                                        color: Colors.red,
                                                        size: 18),
                                                    SizedBox(width: 5),
                                                    Text("Jubilee Hills",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700])),
                                                  ],
                                                )
                                              : SizedBox(),
                                          !widget.isClinic
                                              ? Row(
                                                  children: [
                                                    Icon(Icons.location_on,
                                                        color: Colors.red,
                                                        size: 18),
                                                    Text("2.5 KM"),
                                                  ],
                                                )
                                              : SizedBox()
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          CommonPaginationBar(
            showPagination: showPagination,
            itemsPerPage: controller.itemsPerPage,
            currentPage: controller.currentPage,
            totalPages: controller.totalPages,
            onItemsPerPageChanged: controller.changeItemsPerPage,
            onNext: controller.nextPage,
            onPrev: controller.prevPage,
            onPageSelected: controller.goToPage,
          ),
        ],
      ),
    );
  }

  // ---------------- MODAL BOTTOM SHEET ----------------
  // void openServiceModal(ProcedureListmodel svc) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return DraggableScrollableSheet(
  //         initialChildSize: 0.88,
  //         minChildSize: 0.50,
  //         maxChildSize: 0.95,
  //         expand: false,
  //         builder: (context, scrollController) {
  //           // ----------------- DYNAMIC TABS -----------------
  //           List<Tab> tabs = [];
  //           List<Widget> tabViews = [];

  //           if (svc.preProcedureQA.isNotEmpty) {
  //             tabs.add(Tab(text: "Pre-Procedure"));
  //             tabViews.add(_qaList(svc.preProcedureQA));
  //           }

  //           if (svc.procedureQA.isNotEmpty) {
  //             tabs.add(Tab(text: "Procedure"));
  //             tabViews.add(_qaList(svc.procedureQA));
  //           }

  //           if (svc.postProcedureQA.isNotEmpty) {
  //             tabs.add(Tab(text: "Post-Procedure"));
  //             tabViews.add(_qaList(svc.postProcedureQA));
  //           }

  //           bool hasTabs = tabs.isNotEmpty;

  //           return DefaultTabController(
  //             length: hasTabs ? tabs.length : 1,
  //             child: Padding(
  //               padding: const EdgeInsets.all(16),
  //               child: ListView(
  //                 controller: scrollController,
  //                 children: [
  //                   // TOP BAR
  //                   Center(
  //                     child: Container(
  //                       width: 55,
  //                       height: 5,
  //                       margin: EdgeInsets.only(bottom: 20),
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey.shade400,
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                   ),

  //                   // Title
  //                   Text(
  //                     svc.subServiceName,
  //                     style:
  //                         TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                   ),

  //                   SizedBox(height: 14),

  //                   // Image
  //                   ClipRRect(
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: Image.memory(
  //                       base64Decode(svc.subServiceImage),
  //                       height: 180,
  //                       width: double.infinity,
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),

  //                   SizedBox(height: 20),

  //                   // DESCRIPTION
  //                   Text("Description",
  //                       style: TextStyle(
  //                           fontSize: 16, fontWeight: FontWeight.bold)),
  //                   SizedBox(height: 6),
  //                   Text(
  //                     svc.viewDescription,
  //                     style: TextStyle(fontSize: 14, height: 1.4),
  //                   ),

  //                   // ------------------ TABS ONLY IF DATA EXISTS ------------------
  //                   if (hasTabs) ...[
  //                     SizedBox(height: 20),
  //                     TabBar(
  //                       labelColor: Colors.pink,
  //                       unselectedLabelColor: Colors.grey,
  //                       indicatorColor: Colors.pink,
  //                       tabs: tabs,
  //                     ),
  //                     SizedBox(height: 10),
  //                     SizedBox(
  //                       height: 250,
  //                       child: TabBarView(children: tabViews),
  //                     ),
  //                   ],

  //                   SizedBox(height: 20),

  //                   // Payment Section
  //                   // Text(
  //                   //   "Payment Details",
  //                   //   style:
  //                   //       TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //                   // ),

  //                   // SizedBox(height: 12),
  //                   // _priceRow("Base Price", "₹${svc.price.toStringAsFixed(0)}"),
  //                   // _priceRow("Discount (${svc.discountPercentage}%)",
  //                   //     "-₹${svc.discountAmount.toStringAsFixed(0)}"),
  //                   // _priceRow("GST (${svc.taxPercentage}%)",
  //                   //     "₹${svc.gstAmount.toStringAsFixed(0)}"),
  //                   // _priceRow("Consultation Fee",
  //                   //     "₹${svc.consultationFee.toStringAsFixed(0)}"),
  //                   // _priceRow("Platform Fee",
  //                   //     "₹${svc.platformFee.toStringAsFixed(0)}"),
  //                   // Divider(),
  //                   // _priceRow("Final Cost", "₹${svc.finalCost}",
  //                   //     bold: true, highlight: true),

  //                   SizedBox(height: 20),

  //                   // BUTTON
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       final paymentModal = PaymentModal(
  //                           price: svc.price.toDouble(),
  //                           discountPercentage: svc.discountPercentage);
  //                       showModalBottomSheet(
  //                           context: context,
  //                           isScrollControlled: true,
  //                           shape: const RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.vertical(
  //                                 top: Radius.circular(20)),
  //                           ),
  //                           builder: (_) =>
  //                               PackageBookingSheet(payment: paymentModal));
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.pink,
  //                       minimumSize: Size(double.infinity, 55),
  //                     ),
  //                     child: Text("Book Now", style: TextStyle(fontSize: 18)),
  //                   ),

  //                   SizedBox(height: 20),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _priceRow(String title, String value,
      {bool bold = false, bool highlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qaList(List<Map<String, dynamic>> qaData) {
    if (qaData.isEmpty) {
      return Center(child: Text("No information available."));
    }

    return ListView.builder(
      itemCount: qaData.length,
      itemBuilder: (context, index) {
        final item = qaData[index];

        return Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: item.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    ...List<String>.from(entry.value)
                        .map(
                            (v) => Text("- $v", style: TextStyle(fontSize: 14)))
                        .toList(),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
