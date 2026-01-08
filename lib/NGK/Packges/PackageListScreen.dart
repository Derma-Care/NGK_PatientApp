import 'package:cutomer_app/NGK/ClinicManagement/AboutClinicScreen.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicControllerLocation.dart';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Packges/PackageController.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/NGK/Widgets/FiltterButtons.dart';
import 'package:cutomer_app/NGK/Widgets/PackageBookingSheet.dart';
import 'package:cutomer_app/NGK/Widgets/common_pagination.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/DateConverter.dart';
import 'package:cutomer_app/Utils/FormatOfferDate.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? openCard;
  late ScrollController scrollController;
  ValueNotifier<bool> showPagination = ValueNotifier(true);
  final TextEditingController searchController = TextEditingController();
  double lastOffset = 0;
  double? lat;
  double? long;

  final ClinicControllerLocation ccontroller =
      Get.put(ClinicControllerLocation());

  @override
  void initState() {
    super.initState();
    controller = PackageController();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    // ✅ LOAD BACKEND DATA
    loadCoordinates();
  }

  Future<void> loadCoordinates() async {
    final prefs = await SharedPreferences.getInstance();

    lat = prefs.getDouble('latitude');
    long = prefs.getDouble('longitude');

    // ✅ Fallback safety (optional)
    if (lat == null || long == null) {
      debugPrint("❌ Location not found in storage");
      return;
    }

    // ✅ Call backend API with stored coordinates
    controller.loadPackages(
      latitude: lat!,
      longitude: long!,
    );
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
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    openCard = null; // collapse expanded card

    await loadCoordinates(); // reload backend data
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
                widget.isClinic ? SizedBox() : filterButton("All", controller),
                filterButton("Near Me", controller),
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

                      return RefreshIndicator(
                        color: mainColor,
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final pkg = list[index];
                            // final clinic = ccontroller.paginatedList[index];

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
                                      left: 0,
                                      right: 0, // 👈 THIS IS THE KEY
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(16),
                                            topLeft: Radius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // ⏳ OFFER DATE (LEFT)
                                            if (pkg.offerActive)
                                              Expanded(
                                                child: Text(
                                                  formatOfferDate(
                                                      pkg.offerValidDate),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),

                                            // 💯 DISCOUNT (RIGHT)
                                            Text(
                                              "${pkg.totalDiscountPercentage.toStringAsFixed(0)}% OFF",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 20),

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
                                                                color:
                                                                    Colors.grey[
                                                                        600])),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 28,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          Get.to(() =>
                                                              AboutClinicScreen(
                                                                clinicId: pkg
                                                                    .clinicId,
                                                                distanceInKm:
                                                                    pkg.distance,
                                                              ));
                                                        },
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12),
                                                          side: const BorderSide(
                                                              color: Colors
                                                                  .deepOrange),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          "About",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .deepOrange,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          Row(
                                            children: [
                                              Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 18),
                                              Text(" ${pkg.clinicRating}"),
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text("Original Price",
                                                            style: TextStyle(
                                                                fontSize: 13)),
                                                        Text(
                                                          "₹${pkg.price.toStringAsFixed(0)}",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            color: Colors
                                                                .redAccent,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    // Final price highlighted
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text("Now",
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                        Text(
                                                          "₹${pkg.totalDiscountedAmount.toStringAsFixed(0)}",
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
                                                // Center(
                                                //   child: Text(
                                                //     "ends on ${formatDateOnly(
                                                //       pkg.offerValidDate != null
                                                //           ? "${pkg.offerValidDate}T00:00:00"
                                                //           : null,
                                                //     )}",
                                                //     style: TextStyle(
                                                //       fontSize: 15,
                                                //       fontWeight: FontWeight.w600,
                                                //       color: Colors.grey[700],
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(height: 12),

                                          // ADDRESS + DISTANCE
                                          widget.isClinic
                                              ? const SizedBox()
                                              : Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // 📍 ADDRESS (2 lines, flexible)
                                                    Expanded(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Icon(Icons.map,
                                                              color: Colors.red,
                                                              size: 18),
                                                          const SizedBox(
                                                              width: 5),
                                                          Expanded(
                                                            child: Text(
                                                              pkg.clinicAddress,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[700],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    const SizedBox(width: 10),

                                                    // 📏 DISTANCE (right aligned)
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                            Icons.location_on,
                                                            color: Colors.red,
                                                            size: 18),
                                                        const SizedBox(
                                                            width: 3),
                                                        Text(
                                                          pkg.distance,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                          // ▼ EXPANDABLE PROCEDURES
                                          AnimatedCrossFade(
                                            duration:
                                                Duration(milliseconds: 300),
                                            firstChild: SizedBox(),
                                            secondChild: Column(
                                              children: pkg.procedures.map((p) {
                                                return Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
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
                                                                  FontWeight
                                                                      .w500)),
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
                                                minimumSize: const Size(
                                                    double.infinity, 50),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                final paymentModal =
                                                    PaymentModal.fromPackage(
                                                        pkg);
                                                showModalBottomSheet(
                                                    backgroundColor:
                                                        Colors.white,
                                                    context: context,
                                                    isScrollControlled: true,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      20)),
                                                    ),
                                                    builder: (_) =>
                                                        PackageBookingSheet(
                                                            payment:
                                                                paymentModal));
                                              },
                                              child: const Text(
                                                "Book Package",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
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
                        ),
                      );
                    });
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
