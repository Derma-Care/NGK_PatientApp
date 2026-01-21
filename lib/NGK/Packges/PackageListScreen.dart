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
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: Row(
          //     children: [
          //       widget.isClinic ? SizedBox() : filterButton("All", controller),
          //       filterButton("Near Me", controller),
          //       filterButton("High Discount", controller),
          //       filterButton("Low Price", controller),
          //       widget.isClinic
          //           ? SizedBox()
          //           : filterButton("Rating", controller),
          //       filterButton("High Price", controller),
          //     ],
          //   ),
          // ),

          // SizedBox(height: 10),

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
                    return Column(
                      children: [
                        /// ✅ SHOW FILTERS ONLY IF DATA EXISTS
                        if (list.isNotEmpty)
                          Column(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    widget.isClinic
                                        ? const SizedBox()
                                        : filterButton("All", controller),
                                    filterButton("Near Me", controller),
                                    filterButton("High Discount", controller),
                                    filterButton("Low Price", controller),
                                    widget.isClinic
                                        ? const SizedBox()
                                        : filterButton("Rating", controller),
                                    filterButton("High Price", controller),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),

                        /// 📦 LIST / EMPTY STATE
                        Expanded(
                          child: list.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No packages found",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  color: mainColor,
                                  onRefresh: _onRefresh,
                                  child: ListView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final pkg = list[index];
                                      return _buildPackageCard(pkg);
                                    },
                                  ),
                                ),
                        ),
                      ],
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

  Widget _buildPackageCard(PackageModel pkg) {
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
            openCard = openCard == pkg.packageId ? null : pkg.packageId;
          });
        },
        child: Stack(
          children: [
            if (pkg.offerActive)
              // 🔥 OFFER RIBBON
              Positioned(
                top: 0,
                left: 0,
                right: 0, // 👈 THIS IS THE KEY
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

                      Expanded(
                        child: Text(
                          formatOfferDate(pkg.offerValidDate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
              padding: EdgeInsets.only(
                top: pkg.offerActive ? 24 : 0, // ✅ KEY FIX
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  // CLINIC NAME + RATING

                  widget.isClinic
                      ? SizedBox()
                      : // ===== COLLAPSED HEADER =====
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT INFO (70%)
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // PACKAGE NAME
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_offer,
                                        color: mainColor,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          pkg.packageName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  // HOSPITAL NAME + CITY
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pkg.clinicName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            pkg.city,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 28,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Get.to(() => AboutClinicScreen(
                                                  clinicId: pkg.clinicId,
                                                  distanceInKm: pkg.distance,
                                                ));
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            side: const BorderSide(
                                                color: Colors.deepOrange),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            "About",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // RIGHT DISCOUNT (30%)
                          ],
                        ),

                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(" ${pkg.clinicRating}"),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 3),
                          Text(
                            pkg.distance,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  Text(
                    "tap to view more details",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.redAccent),
                  ),
                  // ▼ EXPANDABLE PROCEDURES
                  if (openCard == pkg.packageId) ...[
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: openCard == pkg.packageId ? 0 : 1,
                      child: const Text(
                        "tap to view more details",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),

                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      firstChild: const SizedBox(),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 📍 ADDRESS (SHOW ONCE)
                          if (!widget.isClinic)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.map,
                                    color: Colors.red, size: 18),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    pkg.clinicAddress,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),

                          const SizedBox(height: 12),

                          // 🧪 PROCEDURES + SITTINGS (LOOP ONLY HERE)
                          ...pkg.procedures.map((p) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  // 70% – Procedure Name (max 2 lines)
                                  Expanded(
                                    flex: 7,
                                    child: Text(
                                      p.procedureName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),

                                  // 30% – Sittings (right aligned)
                                  Expanded(
                                    flex: 3,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "${p.noOfSittings} sittings",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 12),

                          // 💰 PRICE CARD (ONLY ONCE)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.pink.shade100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Original Price",
                                        style: TextStyle(fontSize: 13)),
                                    Column(
                                      children: [
                                        Text(
                                          "₹${pkg.price.toStringAsFixed(0)}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        Text(
                                          "Save ₹${pkg.totalDiscountAmount.toStringAsFixed(0)}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("Now",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                      "₹${pkg.totalDiscountedAmount.toStringAsFixed(0)}",
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.pink.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      crossFadeState: openCard == pkg.packageId
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                    ),

                    const SizedBox(height: 12),

                    // 🔘 BOOK BUTTON (ONCE)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final paymentModal = PaymentModal.fromPackage(pkg);
                        showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) =>
                              PackageBookingSheet(payment: paymentModal),
                        );
                      },
                      child: const Text(
                        "Book Package",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
