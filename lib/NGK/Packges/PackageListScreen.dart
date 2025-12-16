import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Packges/PackageController.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/NGK/Widgets/FiltterButtons.dart';
import 'package:cutomer_app/NGK/Widgets/PackageBookingSheet.dart';
import 'package:cutomer_app/NGK/Widgets/common_pagination.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'PackageModel.dart';

class PackageListScreen extends StatefulWidget {
  final bool hideHeader;

  final bool isClinic;
  PackageListScreen({this.hideHeader = false, this.isClinic = false});
  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  late PackageController controller;
  int? openCard;
  late ScrollController scrollController;
  ValueNotifier<bool> showPagination = ValueNotifier(true);
  final TextEditingController searchController = TextEditingController();
  double lastOffset = 0;

  @override
  void initState() {
    super.initState();
    controller = PackageController();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
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
      appBar: widget.hideHeader ? null : CommonHeader(title: "Packages"),
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
                widget.isClinic
                    ? SizedBox()
                    : filterButton("Near Me", controller),
                filterButton("High Discount", controller),
                filterButton("Low Price", controller),
                widget.isClinic
                    ? SizedBox()
                    : filterButton("Rating", controller),
                filterButton("High Price", controller),
              ],
            ),
          ),

          SizedBox(height: 10),

          // ---------------------- PACKAGE LIST ----------------------
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: controller.loading,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return Center(
                    child: SpinKitFadingCircle(
                      color: mainColor,
                      size: 40,
                    ),
                  );
                }

                return ValueListenableBuilder<List<PackageModel>>(
                  valueListenable: controller.packageList,
                  builder: (context, list, _) {
                    if (list.isEmpty) {
                      return Center(child: Text("No packages found"));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final pkg = list[index];

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                openCard = openCard == pkg.packageId
                                    ? null
                                    : pkg.packageId;
                              });
                            },
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
                                      "${pkg.discountPercentage}% OFF",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),

                                      // 🌈 Gradient Header
                                      Row(
                                        children: [
                                          Icon(Icons.local_offer,
                                              color: mainColor, size: 26),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              pkg.packageName,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),

                                      // CLINIC NAME + RATING
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
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(pkg.clinicName,
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors
                                                                .grey[600])),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(Icons.star,
                                                        color: Colors.amber,
                                                        size: 18),
                                                    Text(
                                                        " ${pkg.clinicRating}"),
                                                  ],
                                                ),
                                              ],
                                            ),

                                      SizedBox(height: 12),

                                      // 💰 PRICE BOX (Offer Style)
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
                                                      "₹${pkg.price}",
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

                                                // Final price highlighted
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
                                                      "₹${pkg.finalPrice}",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        color: Colors
                                                            .pink.shade700,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 12),

                                      // ADDRESS + DISTANCE
                                      widget.isClinic
                                          ? SizedBox()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.map,
                                                        color: Colors.red,
                                                        size: 18),
                                                    SizedBox(width: 5),
                                                    Text(pkg.clinicAddress,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700])),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(Icons.location_on,
                                                        color: Colors.red,
                                                        size: 18),
                                                    Text(pkg.distance),
                                                  ],
                                                ),
                                              ],
                                            ),

                                      // ▼ EXPANDABLE PROCEDURES
                                      AnimatedCrossFade(
                                        duration: Duration(milliseconds: 300),
                                        firstChild: SizedBox(),
                                        secondChild: Column(
                                          children: pkg.procedures.map((p) {
                                            return Container(
                                              margin: EdgeInsets.only(top: 10),
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(p.procedureName,
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                                  Text(
                                                      "${p.noOfSittings} sittings",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        crossFadeState:
                                            openCard == pkg.packageId
                                                ? CrossFadeState.showSecond
                                                : CrossFadeState.showFirst,
                                      ),

                                      if (openCard == pkg.packageId) ...[
                                        SizedBox(height: 12),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.pink,
                                            minimumSize:
                                                const Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            final paymentModal = PaymentModal(
                                                price: pkg.price.toDouble(),
                                                discountPercentage:
                                                    pkg.discountPercentage);

                                            showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              20)),
                                                ),
                                                builder: (_) =>
                                                    PackageBookingSheet(
                                                        payment: paymentModal));
                                          },
                                          child: const Text(
                                            "Book Package",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        )
                                      ]
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
}
